************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
************************************************************************
*----------------------------------------------------------------------*
      Subroutine GiveMeInfo(nBB,nntyp,natyp,BasCoo,iCon,nPrim,nBA,nCBoA,
     &                      nBona,ipExpo,ipCont,nSh,nfSh,nSize,iPrint,
     &                      MxAtQ,MxPrCon,MxBasQ,MxAngqNr,ipAcc,
     &                      nACCSize)
      use Basis_Info
      use Her_RW
      use Real_Spherical
      Implicit Real*8 (a-h,o-z)

*------------------------------------------------------------------------*
* Include files that got to do with the info-file generated by seward.   *
*------------------------------------------------------------------------*
#include "itmax.fh"
#include "info.fh"
#include "numbers.fh"
#include "WrkSpc.fh"
#include "stdalloc.fh"
*------------------------------------------------------------------------*
* Ordinary variables.                                                    *
*------------------------------------------------------------------------*
      Dimension BasCoo(3,MxBasQ),nBona(MxAtQ)
      Dimension nSh(MxAtQ),nFSh(MxAtQ,MxAngqNr),iCon(MxAtQ,MxPrCon)
      Dimension natyp(MxAtQ),nPrim(MxBasQ),nBA(MxAtQ)
      Dimension nCBoA(MxAtQ,MxAngqNr)
      Real*8, Allocatable:: TEMP1(:), TEMP2(:)
      Logical DoRys

      Call QEnter('GiveMeInfo')

*------------------------------------------------------------------------*
* Initialize in order to read properly from the info file.               *
*------------------------------------------------------------------------*
      Call Seward_Init

*------------------------------------------------------------------------*
* GetInf reads everything in the info file and put it in variables       *
* in the info.fh include file. Look in the header of info.fh to see the  *
* plethora of numbers you can fetch there.                               *
*------------------------------------------------------------------------*
      nDiff=0
      DoRys=.false.
      Call GetInf(Info,nInfo,DoRys,nDiff,idum)

*------------------------------------------------------------------------*
* Set nntyp.                                                             *
*------------------------------------------------------------------------*
      nntyp=nCnttp

*------------------------------------------------------------------------*
* Compute what we came here for. iBasAng will contain nBas elements with *
* integers, such that 1=s-orbitals, 2=p-orbitals, 3=d-orbitals, ...      *
*------------------------------------------------------------------------*
C     ii=0  !ii is number of basis sets.
C10   Continue
C       ii=ii+1
C     If(dbsc(ii)%nCntr.ne.0) Go To 10
C     ii=ii-1
C     If(ii.eq.0) then
C       Write(6,*)
C       Write(6,*)'ERROR in GiveMeInfo. No atoms?'
C     Endif
      ii=nCnttp
*
      kaunta=0
      kaunt=0
      kaunter=0
      krekna=0
      MaxAng=0
      Do 20, i=1,ii
        kauntSav=kaunt
        Do 25, ioio=1,dbsc(i)%nCntr
          krekna=krekna+1
          krekna2=0
          kaunt=kauntSav
          kaunterPrev=kaunter
          nBA(krekna)=nTot_Shells(i)
          If(nBA(krekna).gt.MaxAng)MaxAng=nBA(krekna)
          Do 30, j=1,nTot_Shells(i)
            kaunt=kaunt+1
            krekna2=krekna2+1
            nCBoA(krekna,krekna2)=nBasis(kaunt)
            Do 40, jj=1,nBasis(kaunt)
              kaunter=kaunter+1
40          Continue
30        Continue
          kaunta=kaunta+1
          nBonA(kaunta)=kaunter-kaunterPrev  !Number of bases on each,
25      Continue                         !atom used below.
20    Continue

*--------------------------------------------------------------------------*
* And now coordinates of each basis.                                       *
*--------------------------------------------------------------------------*
      kaunter=0
      kaunt=0
      Do 101, i=1,ii
        Do 111, j=1,dbsc(i)%nCntr
          kaunt=kaunt+1
          Do 121, kk=1,nBonA(kaunt)
            kaunter=kaunter+1
            Do 131, k=1,3
              BasCoo(k,kaunter)=Work(dbsc(i)%ipCntr+(j-1)*3+k-1)
131         Continue
121       Continue
111     Continue
101   Continue

*--------------------------------------------------------------------------*
* Now get info regarding the contraction. Icon is an array that for each   *
* basis type contain n1+n2+...+nx elements where n1 is the number of       *
* contracted basis functions of s-type, n2 the same number for p-type etc. *
* The value of the first n1 elements is the number of primitive basis      *
* functions of s-type, etc. So a contraction 7s3p.4s1p generates the vector*
* 7,7,7,7,3. We also compute natyp and also collect all exponents and      *
* contraction coefficients. These are stored dynamically and then we return*
* the pointers only.                                                       *
*--------------------------------------------------------------------------*
      kaunt=0
      Do 201, i=1,ii
        kaunter=0
        Do 203, k=1,nTot_Shells(i)
          kaunt=kaunt+1
          Do 205, ll=1,nBasis(kaunt)
            kaunter=kaunter+1
            Icon(i,kaunter)=nExp(kaunt)
205       Continue
203     Continue
201   Continue

      ndc=0
      iAngSav=1
      nSize=0
      kaunt=0
      Do 2101, kk=1,ii   !Just to get size of vector
        Do 2102, kkk=1,nTot_Shells(kk)
          kaunt=kaunt+1
          nSize=nSize+nBasis(kaunt)*nExp(kaunt)
2102    Continue
2101  Continue
      Call GetMem('Exponents','Allo','Real',ipExpo,nSize*MxAtQ)
      Call GetMem('ContrCoef','Allo','Real',ipCont,nSize*MxAtQ)

      Do 211, iCnttp=1,nCnttp  !Here we set NaTyp.
        jSum=0
        iTemp=0
        nVarv=nTot_Shells(iCnttp)
        nSh(iCnttp)=nVarv
        M=iCnttp-1
        Do 212, iCnt=1,dbsc(iCnttp)%nCntr
          ndc=ndc+1
          iTemp=iTemp+nStab(ndc)
212     Continue
        NaTyp(iCnttp)=iTemp
        Do 213, iAng=0,nVarv-1  !And in this loop we get hold of the
                          !contraction coefficients and the exponents.
          iCount=iAng+iAngSav
          iCff=ipCff(iCount)
          iExp=ipExp(iCount)
          iPrim=nExp(iCount)
          iBas=nBasis(iCount)
          nfSh(iCnttp,iAng+1)=iBas
          Do 214, i=1,iBas
            Call dCopy_(iPrim,Work(iExp),1,Work(ipExpo+jSum*MxAtQ+M)
     &                ,MxAtQ)
            Call dCopy_(iPrim,Work(iCff),1,Work(ipCont+jSum*MxAtQ+M)
     &                ,MxAtQ)
            jSum=jSum+iPrim
            iCff=iCff+iPrim
214       Continue
213     Continue
        iAngSav=iAngSav+iAng
211   Continue
      If(iPrint.ge.30) then
        Write(6,*)'Exp.'
        Write(6,'(10F13.4)')(Work(ipExpo+k),k=0,nSize*MxAtQ-1)
        Write(6,*)'Contr.'
        Write(6,'(10F13.4)')(Work(ipCont+k),k=0,nSize*MxAtQ-1)
      Endif

*---------------------------------------------------------------------------*
* Contruct the nPrim vector.                                                *
*---------------------------------------------------------------------------*
      iBas=0
      Do 301, i=1,nntyp
        na=natyp(i)
        Do 302, j=1,na
          ind=0
          nshj=nsh(i)
          Do 303, k=1,nshj
            nnaa=nfsh(i,k)
            Do 304, l=1,nnaa
              iBas=iBas+1
              ind=ind+1
              nPrim(iBas)=iCon(i,ind)
304         Continue
303       Continue
302     Continue
301   Continue
*
*-- Then since overlap integrations are in cartesian coordinates while
*   the AO-basis is spherical, we need transformation matrix for this.
*   To our great joy, old reliable Seward computes this matrix of any
*   order (within Molcas limits). Due to conflicting order conventions,
*   some numbers gymnastics are required.
*
      MaxAng=MaxAng-1
      nSize=(2*MaxAng+1)*(MaxAng+1)*(MaxAng+2)/2
      nACCSize=0
      Do i=2,MaxAng
        nACCSize=nACCSize+(2*i+1)*(i+1)*(i+2)/2
      End Do
      nSumma=0
      Call mma_allocate(TEMP1,nSize,Label='TEMP1')
      Call mma_allocate(TEMP2,nSize,Label='TEMP2')
      Call GetMem('AccTransa','Allo','Real',ipAcc,nACCSize)
*
      Do i=2,MaxAng
         ind1=(i+1)*(i+2)/2
         ind2=2*i+1
         iHowMuch=ind1*ind2
         Call DCopy_(iHowMuch,RSph(ipSph(i)),iONE,TEMP1,iONE)
         ind3=1
         Do jj=1,ind1
            call dcopy_(ind2,TEMP1(jj),ind1,TEMP2(ind3),iONE)
            ind3=ind3+ind2
         End Do
*        Call recprt('FFF',' ',TEMP1,(i+1)*(i+2)/2,2*i+1)
*        Call recprt('GGG',' ',TEMP2,ind2,ind1)
         call dcopy_(iHowMuch,TEMP2,iONE,Work(ipAcc+nSumma),iONE)
         nSumma=nSumma+iHowMuch
      End Do
*
      Call mma_deallocate(TEMP1)
      Call mma_deallocate(TEMP2)
*----------------------------------------------------------------------*
* Make deallocations. They are necessary because of the getinf.        *
*----------------------------------------------------------------------*
      Call ClsSew()
      Call QEXit('GiveMeInfo')

      Return
c Avoid unused argument warnings
      If (.False.) Call Unused_integer(nBB)
      End
