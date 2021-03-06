************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
*                                                                      *
* Copyright (C) 1990-1992, Roland Lindh                                *
*               1995, Anders Bernhardsson                              *
************************************************************************
      SubRoutine Drvk2_mck(mdede,New_Fock)
************************************************************************
*                                                                      *
*  Object: to precompute all pair entites as zeta, kappa, P.           *
*                                                                      *
*     Author: Roland Lindh, IBM Almaden Research Center, San Jose, CA  *
*             March '90                                                *
*                                                                      *
*             June '91, modified for k2 loop.                          *
*             January '92, modified to gradient calculations.          *
*             April '92, modified to use the Cauchy-Schwarz inequality *
*              to estimate the integral derivatives.                   *
*              Modified 1995 for 2nd derivatives by AB                 *
************************************************************************
      use k2_setup
      use k2_arrays
      use iSD_data
      use Basis_Info
      use Symmetry_Info, only: nIrrep, iOper
      use Sizes_of_Seward, only: S
      Implicit Real*8 (A-H,O-Z)
#include "Molcas.fh"
#include "ndarray.fh"
#include "real.fh"
#include "disp.fh"
#include "disp2.fh"
#include "stdalloc.fh"
#include "nsd.fh"
#include "setup.fh"
      Real*8  Coor(3,2)
      Integer iDCRR(0:7), iShllV(2), iAngV(4), iCmpV(4)
      Logical New_fock
      Real*8, Allocatable :: Data_k2_local(:), Con(:), Wrk(:)
*                                                                      *
************************************************************************
*                                                                      *
*-----Statement functions
*
      nElem(ixyz) = (ixyz+1)*(ixyz+2)/2
*                                                                      *
************************************************************************
*                                                                      *
      Call CWTime(TCpu1,TWall1)
      Call mma_MaxDBLE(Maxk2)
      maxk2 = maxk2 / 2
      Call mma_allocate(Data_k2_local,Maxk2)
      jpk2 = 1
      nk2 = 0
      mdede=0
      mk2 = 0
*
      DoGrad_=.False.
      DoHess_=.True.
*                                                                      *
************************************************************************
*                                                                      *
      Call Nr_Shells(nSkal)
*                                                                      *
************************************************************************
*                                                                      *
      Call mma_allocate(Con,S%m2Max,Label='Con')
*                                                                      *
************************************************************************
*                                                                      *
      MemTmp=0
      Do iAng = 0, S%iAngMx
         MemTmp=Max(MemTmp,(S%MaxPrm(iAng)*nElem(iAng))**2)
      End Do
*                                                                      *
************************************************************************
*                                                                      *
      Call mma_MaxDBLE(MaxMem)
      Call mma_allocate(Wrk,MaxMem,Label='Wrk')
      ipM001=1
*                                                                      *
************************************************************************
*                                                                      *
      Do iS = 1, nSkal
         iShll  = iSD( 0,iS)
         iAng   = iSD( 1,iS)
         iCmp   = iSD( 2,iS)
         iBas   = iSD( 3,iS)
         iPrim  = iSD( 5,iS)
         iAO    = iSD( 7,iS)
         mdci   = iSD(10,iS)
         iShell = iSD(11,iS)
         iCnttp = iSD(13,iS)
         iCnt   = iSD(14,iS)
         Coor(1:3,1)=dbsc(iCnttp)%Coor(1:3,iCnt)
*
         iAngV(1) = iAng
         iShllV(1) = iShll
         iCmpV(1) = (iAng+1)*(iAng+2)/2
*
         Do jS = 1, iS
            jShll  = iSD( 0,jS)
            jAng   = iSD( 1,jS)
            jCmp   = iSD( 2,jS)
            jBas   = iSD( 3,jS)
            jPrim  = iSD( 5,jS)
            jAO    = iSD( 7,jS)
            mdcj   = iSD(10,jS)
            jShell = iSD(11,jS)
            jCnttp = iSD(13,jS)
            jCnt   = iSD(14,jS)
            Coor(1:3,2)=dbsc(jCnttp)%Coor(1:3,jCnt)
*
            iAngV(2) = jAng
            iShllV(2) = jShll
            iCmpV(2) = (jAng+1)*(jAng+2)/2
*
*-------Compute FLOP's for the transfer equation.
*
            Call mHrr(iAng  ,jAng  ,nHrrab,nMemab)
            ijCmp = nElem(iAng)*nElem(jAng)
*
            iPrimi   = iPrim
            jPrimj   = jPrim
            nBasi    = Shells(iShllV(1))%nBasis
            nBasj    = Shells(iShllV(2))%nBasis
*
            kPrimk = 1
            lPriml = 1
            iBasi = iPrimi
            jBasj = jPrimj
            kBask = 1
            lBasl = 1
*
            nZeta = iPrimi * jPrimj
*
            Call ConMax(Con,iPrimi,jPrimj,
     &                  Shells(iShll)%pCff,nBasi,
     &                  Shells(jShll)%pCff,nBasj)
*
            Call ICopy(2,iAngV,1,iAngV(3),1)
            Call ICopy(2,iCmpV,1,iCmpV(3),1)
*
            If (iShell.ge.jShell) Then
               ijShll = iShell*(iShell-1)/2 + jShell
            Else
               ijShll = jShell*(jShell-1)/2 + iShell
            End If
*
            nSO = 1
*
*-----------Compute memory request for the primitives, i.e.
*           how much memory is needed up to the transfer
*           equation.
*
            Call MemRys(iAngV,MemPrm)
*
*-----------Decide on the partioning of the shells based on
*           the available memory and the requested memory.
*
            Call PSOAO0_h(nSO,nMemab,nMemab,MemPrm,
     &                    MaxMem,iAngV,iCmpV,
     &                    iBasi,iBsInc,jBasj,jBsInc,
     &                    kBask,kBsInc,lBasl,lBsInc,
     &                    iPrimi,iPrInc,jPrimj,jPrInc,
     &                    kPrimk,kPrInc,lPriml,lPrInc,
     &                    ipM001,ipM002,ipM003,ipM004, ipM00d,
     &                    M001,  M002,  M003,  M004,     M00d)
            If (iBasi.ne.iBsInc .or.jBasj.ne.jBsInc) Then
                Write (6,*)
     &             'Drvk2: iBasi.ne.iBsInc .or.jBasj.ne.jBsInc'
                Write (6,*) 'iBasi,iBsInc=',iBasi,iBsInc
                Write (6,*) 'jBasj,jBsInc=',jBasj,jBsInc
                Call Abend()
            End If
*
*-----------Find the Double Coset Representatives
*           for center A and B.
*
            iDCRR(0:nIrrep-1)=iOper(0:nIrrep-1)
            nDCRR=nIrrep
*
*---------- Compute all pair entities (zeta, kappa, Px, Py,
*           Pz, ZInv, alpha, beta, [nm|nm] and derivative
*           entity, a total of ten different entities) for
*           all possible unique pairs of centers generated
*           for the symmetry unique centers A and B.
*
            Call k2Loop_mck(Coor,
     &                      iAngV,iCmpV,
     &                      iDCRR,nDCRR,Data_k2_local(jpk2),
     &                      ijCmp,
     &                      Shells(iShllV(1))%Exp,iPrimi,
     &                      Shells(iShllV(2))%Exp,jPrimj,
     &                      Shells(iShllV(1))%pCff,iBas,
     &                      Shells(iShllV(2))%pCff,jBas,
     &                      nMemab,Con,
     &                      Wrk(ipM002),M002,Wrk(ipM003),M003,
     &                      Wrk(ipM004),M004,
     &                      mdci,mdcj)
*
            Indk2(1,ijShll) = jpk2
            Indk2(2,ijShll) = nDCRR
            nk2 = nk2 + (nZeta*nDArray+nDScalar)*nDCRR
            mk2 = mk2 + nDCRR
*
            If (New_Fock) Then
               iDeSiz = 1 + iPrim*jPrim + iCmp*jCmp
            Else
               iDeSiz = 1 + iPrim*jPrim
     &                + (iBas*jBas+1)*iCmp*jCmp
            End If
            iSmLbl = 1
            nSO = MemSO1(iSmLbl,iCmp,jCmp,iShell,jShell,iAO,jAO)
            If (nSO.gt.0) mDeDe = mDeDe + iDeSiz*nDCRR

            jpk2 = 1 + nk2
*
         End Do
      End Do
*                                                                      *
************************************************************************
*                                                                      *
      Call mma_deallocate(Wrk)
      Call mma_deallocate(Con)
*                                                                      *
************************************************************************
*                                                                      *
*     Resize the memory to the actual size
*
      Call mma_allocate(Data_k2,nk2)
      Call dCopy_(nk2,Data_k2_local,1,Data_k2,1)
      Call mma_deallocate(Data_k2_local)
*                                                                      *
************************************************************************
*                                                                      *
#ifdef _DEBUGPRINT_
      Write (6,*)
      Write (6,'(20X,A)')
     &  ' *** The k2 entities has been precomputed ***'
      Write (6,'(I7,A,I7,A)')
     &                   mk2,' blocks of k2 data were computed and',
     &                   nk2,' Word(*8) of memory is used for storage.'
      Write (6,'(A,A)')
     &   ' The presceening is based on the ',
     &   ' integral estimates.'
#endif
*
      Call CWTime(TCpu2,TWall2)
      Call SavTim(2,TCpu2-TCpu1,TWall2-TWall1)
      Return
      End
