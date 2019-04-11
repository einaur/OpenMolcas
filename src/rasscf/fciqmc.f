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
* Copyright (C) 2014, Giovanni Li Manni                                *
*               2019, Oskar Weser                                      *
************************************************************************
      module fciqmc
      implicit none
      private
      public :: FCIQMC_CTL, DoNECI, DoEmbdNECI, DumpOnly, ReOrFlag,
     &  ReOrInp
      logical ::
     &  DoEmbdNECI = .false.,
     &  DoNECI = .false.,
     &  DumpOnly = .false.
      integer ::
! n==0: Don't reorder.
! n>=2: User defined permutation with n non-fixed point elements.
! n==-1: Use GAS sorting scheme.
     &  ReOrFlag = 0
      integer, allocatable :: ReOrInp(:)
      save
      contains
      subroutine FCIQMC_Ctl(CMO,DIAF,DMAT,DSPN,PSMAT,PAMAT,F_IN,D1I,D1A,
     &                      TUVX)
* ***********************************************************
*
*      <Arguments>
*        \Argument{CMO}{MO coefficients}{Real*8 array (NTOT2)}.......................{in}
*        \Argument{DIAF}{DIAGONAL of Fock matrix useful for NECI}{Real*8 array (NTOT)}{in}
*        \Argument{DMAT}{Average 1-dens matrix}{Real*8 array (NACPAR)}...............{out}
*        \Argument{DSPN}{Average spin 1-dens matrix}{Real*8 array (NACPAR)}..........{out}
*        \Argument{PSMAT}{Average symm. 2-dens matrix}{Real*8 array (NACPR2)}........{out}
*        \Argument{PAMAT}{Average antisymm. 2-dens matrix}{Real*8 array (NACPR2)}....{out}
*        \Argument{F_IN}{Fock matrix from inactive density}{Real*8 array (NTOT1)}....{in/out}
*        \Argument{D1I}{Inactive 1-dens matrix}{Real*8 array (NTOT2)}................{inout}
*        \Argument{D1A}{Active 1-dens matrix}{Real*8 array (NTOT2)}..................{inout}
*        \Argument{TUVX}{Active 2-el integrals}{Real*8 array (NACPR2)}...............{in}
*      </Arguments>
*
*      <Purpose> FCIQMC Control </Purpose>
*      <Description>
*
*        For meaning of global variables NTOT1, NTOT2, NACPAR
*        and NACPR2, see src/Include/general.inc and src/Include/rasscf.inc.
*
*        This routine will replace CICTL in FCIQMC regime.
*        Density matrices are generated via double-run procedure in NECI.
*        They are then dumped on arrays DMAT, DSPN, PSMAT, PAMAT to replace
*        what normally would be done in DavCtl if NECI is not used.
*
*        F_In is still generated by SGFCIN... in input contains only two-electron terms as computed in TRA_CTL2. In output it contains also the one-electron contribution
*
*      </Description>
*
#ifdef _MOLCAS_MPP_
      use MPI
#endif
      use filesystem, only : chdir_, getcwd_, get_errno_, strerror_
      use fortran_strings, only : str
      use fciqmc_tables, only : OrbitalTable, FockTable, TwoElIntTable,
     &    fill_orbitals, fill_fock, fill_2ElInt, reorder,
! The different names for the overloaded procedure is necessary because
! of the stupid PGI compiler.
!     &    table_alloc => mma_allocate, table_dealloc => mma_deallocate,
     &    mma_allocate, mma_deallocate,
     &    get_P_GAS, get_P_inp
      use fciqmc_dump, only : dump_ascii, dump_hdf5
      use fciqmc_make_inp, only : make_inp
      use rasscf_data, only : iter, lRoots, nRoots, S, KSDFT, NAC, EMY,
     &    rotmax, ener, iAdr15, iRoot, Weight, nacpr2, nacpar
      use fciqmc_read_RDM, only : read_neci_RDM
      use general_data, only : nSym, nBas, iSpin, nAsh, LuInta, nactel,
     &    jobIph, ntot, ntot1, ntot2
      use gugx_data, only : IfCAS
      use gas_data, only : ngssh, iDoGas
      implicit none
#include "output_ras.fh"
#include "rctfld.fh"
#include "timers.fh"
#include "para_info.fh"
#ifdef _MOLCAS_MPP_
#include "global.fh"
#include "mafdecls.fh"
      integer(kind=4) :: ierror
#endif
      real(kind=8), intent(in) :: CMO(nTot2), DIAF(nTot), TUVX(nAcpr2)
      real(kind=8), intent(out) :: DMAT(nAcpar), DSPN(nAcpar),
     & PSMAT(nAcpr2), PAMAT(nAcpr2)
      real(kind=8), intent(inout) :: F_IN(nTot1), D1I(nTot2), D1A(nTot2)
      type(OrbitalTable) :: orbital_table
      type(FockTable) :: fock_table
      type(TwoElIntTable) :: two_el_table
      logical :: Do_ESPF, WaitForNECI
      real(kind=8) :: NECIen, Scal
      integer :: LuNewC, iPRLEV, iOff, iSym, iBas, i, j,
     & jRoot, iDisk, jDisk, kRoot, permutation(sum(nAsh(:nSym)))
      real(kind=8), allocatable :: TmpD1S(:), TmpDS(:), CICtl1(:),
     &  DTMP(:), DStmp(:), Ptmp(:), PAtmp(:)
      integer :: err
      character(1024) :: path

      parameter(ROUTINE = 'FCIQMC_clt')
!      integer :: IDXCI(mxAct), IDXSX(mxAct)
!      common /IDSXCI/ IDXCI, IDXSX
      call qEnter(routine)

C Local print level (if any)
      IPRLEV = IPRLOC(1)
      IF(IPRLEV.ge.DEBUG) THEN
        Write(LF,*)
        Write(LF,*) ' ===================='
        WRITE(LF,*) ' Entering FCIQMC_Ctl'
        Write(LF,*) ' ===================='
        Write(LF,*)
        Write(LF,*) ' iteration count =',ITER
        Write(LF,*) ' IFCAS value     =',IFCAS
        Write(LF,*) ' lroots,nroots   =',lroots,nroots
        Write(LF,*)
      END IF
* set up flag 'IFCAS' for GAS option, which is set up in gugatcl originally.
* IFCAS = 0: This is a CAS calculation
* IFCAS = 1: This is a RAS calculation
* IFCAS = 2: This is a GAS calculation
      IF(IPRLEV.ge.DEBUG) THEN
        Write(LF,*)
        Write(LF,*) ' CMO in FCIQMC_CTL'
        Write(LF,*) ' ---------------------'
        Write(LF,*)
        ioff=1
        Do iSym = 1,nSym
          iBas = nBas(iSym)
          if(iBas.ne.0) then
            write(6,*) 'Sym =', iSym
            do i= 1,iBas
              write(6,*) (CMO(ioff+iBas*(i-1)+j),j=0,iBas-1)
            end do
            iOff = iOff + (iBas*iBas)
          end if
        End Do
      END IF

* SOME DIRTY SETUPS
*
      S=0.5D0*DBLE(ISPIN-1)
*
**************************************************************************************
**************** FCIQMC not interfaced to State Average CAS         ******************
**************************************************************************************
      if (lroots > 1) then
        write(6,*)' FCIQMC does not support State Average yet!'
        write(6,*)' See you later ;)'
        call QTrace()
        call Abend()
      end if
**************************************************************************************
**************** FCIQMC not interfaced to RAS or GAS for now        ******************
**************************************************************************************
c      IF(IFCAS.ge.1) then
c       write(6,*)' FCIQMC does not support RAS or GAS wf yet!'
c       write(6,*)' See you later ;)'
c       call QTrace()
c       call Abend()
c      end if
**************************************************************************************
****************             Reaction Field calculation             ******************
**************************************************************************************
      call DecideOnESPF(Do_ESPF)
      if ( lRf .or. KSDFT /= 'SCF' .or. Do_ESPF) then
        write(6,*)' FCIQMC does not support Reaction Field yet!'
        write(6,*)' See you later ;)'
        call QTrace()
        call Abend()
      else
**************************************************************************************
****************                     Normal Case                    ******************
**************************************************************************************
* LW1 : Inactive Fock MATRIX IN MO-BASIS computed via SGFCIN containing both one and two-electron contribution.
* F_In: Inactive Fock MATRIX IN AO-BASIS containing both one and two-electron contribution (latest computed in TRA_CTL2)
        call mma_allocate(CICtl1, nAcPar)
        call mma_allocate(TmpD1S, nTot2)
        call mma_allocate(TmpDS, nAcPar)
        TmpDS(:) = DSPN(:)
        if (NASH(1) /= NAC ) call DBLOCK(TmpDS)
        call Get_D1A_RASSCF(CMO, TmpDS, TmpD1S)
        call SGFCIN(CMO, CICtl1, F_In, D1I, D1A, TmpD1S)
        call mma_deallocate(TmpDS)
        call mma_deallocate(TmpD1S)
      end if
**************************************************************************************
*****************              Produce a working FCIDUMP file       ******************
**************************************************************************************
      call mma_allocate(fock_table, nacpar)
      call mma_allocate(two_el_table, size(TUVX))
      call mma_allocate(orbital_table, sum(nAsh))

      call fill_orbitals(orbital_table, DIAF, iter)
      call fill_fock(fock_table, CICtl1, EMY)
      call fill_2ElInt(two_el_table, TUVX)

      if (ReOrFlag /= 0) then
        if (ReOrFlag >= 2) then
          permutation = get_P_inp(ReOrInp)
          call mma_deallocate(ReOrInp)
          call reorder(orbital_table, fock_table,
     &               two_el_table, permutation)
        else if (ReOrFlag == -1) then
          permutation = get_P_GAS(nGSSH)
          call reorder(orbital_table, fock_table,
     &               two_el_table, permutation)
        end if
      end if

      call dump_ascii(EMY, orbital_table, fock_table, two_el_table)
      call dump_hdf5(EMY, orbital_table, fock_table, two_el_table)

      call mma_deallocate(fock_table)
      call mma_deallocate(two_el_table)
      call mma_deallocate(orbital_table)

**************************************************************************************
*****************              Produce an INPUT file for NECI       ******************
**************************************************************************************
      call make_inp()
**************************************************************************************
*****************      Run NECI                                     ******************
**************************************************************************************
* In case we wish to dump the FCIDUMP file only we do not need to wait for NECI run.
      if(DumpOnly) goto 999
          call Timing(Rado_1, Swatch, Swatch, Swatch)
#ifdef _MOLCAS_MPP_
      IF (Is_Real_Par()) THEN
        call MPI_Barrier(MPI_COMM_WORLD, ierror)
      END IF
#endif

      if(DoEmbdNECI) then
#ifdef _NECI_
        write(6,*) 'NECI called automatically within Molcas!'
        if (myrank /= 0) call chdir_('..')
        call necimain(NECIen)
        if (myrank /= 0) call chdir_('tmp_'//str(myrank))
#else
        call WarningMessage(2, 'EmbdNECI is given in input, '//
     &'so the embedded NECI should be used. Unfortunately MOLCAS was '//
     &'not compiled with embedded NECI. Please use -DNECI=ON '//
     &'for compiling or use an external NECI.')
#endif
      else
        call getcwd_(path, err)
        if (err /= 0) write(6, *) strerror_(get_errno_())
        write(6,'(A)')'(1) Run NECI externally using '//
     & '$Project.FciDmp or $Project.FciDmp.h5 and $Project.FciInp '//
     & 'which can be found in'//trim(path)//'.'
        write(6,'(A)')'(2) cp TwoRDM_aaaa.1 into $WorkDir'
        write(6,'(A)')'(3) cp TwoRDM_abab.1 into $WorkDir'
        write(6,'(A)')'(4) cp TwoRDM_abba.1 into $WorkDir'
        write(6,'(A)')'(2) cp TwoRDM_bbbb.1 into $WorkDir'
        write(6,'(A)')'(3) cp TwoRDM_baba.1 into $WorkDir'
        write(6,'(A)')'(4) cp TwoRDM_baab.1 into $WorkDir'
        write(6,'(A)')'(6) Type: echo ''your_RDM_Energy'' > NEWCYCLE'
        call xflush(6)
        waitForNECI = .false.
        do while(.not. waitForNECI)
          call sleep(1)
          call f_Inquire('NEWCYCLE', waitForNECI)
        end do
        write(6, *) 'NEWCYCLE file found. Proceding with SuperCI'
        LuNewC = 12
        call molcas_open(LuNewC, 'NEWCYCLE')
        read(LuNewC,*) NECIen
        write(6,*) 'I read the following energy:'
        write(6,*) NECIen
        close (LuNewC, status='delete')
      end if
* NECIen so far is only the energy for the GS. Next step it will be an array containing energies
* for all the optimized states.
      do jRoot = 1, lRoots
        ENER(jRoot, ITER) = NECIen
      end do
**************************************************************************************
*****************        Generate density matrices for Molcas       ******************
**************************************************************************************
* Neci density matrices are stored in Files TwoRDM_**** (in spacial orbital basis).
* I will be reading them from those formatted files for the time being.
* Next it will be nice if NECI prints them out already in Molcas format.
! ONE-BODY DENSITY
      call mma_allocate(DTMP, nAcPar, label='Dtmp ')
! ONE-BODY SPIN DENSITY
      call mma_allocate(DStmp, nAcPar, label='DStmp')
! SYMMETRIC TWO-BODY DENSITY
      call mma_allocate(Ptmp, nAcPr2, label='Ptmp ')
! ANTISYMMETRIC TWO-BODY DENSITY
      call mma_allocate(PAtmp, nAcPr2, label='PAtmp')

#ifdef _MOLCAS_MPP_
      IF (Is_Real_Par()) THEN
        call MPI_Barrier(MPI_COMM_WORLD,ierror)
      END IF
#endif

      if (DoNECI) then
        call read_neci_RDM(DTMP, DStmp, Ptmp, PAtmp)
      end if
#ifdef _MOLCAS_MPP_
      if (Is_Real_Par()) call MPI_Barrier(MPI_COMM_WORLD, ierror)
#endif
* COMPUTE AVERAGE DENSITY MATRICES
      do jRoot = 1, lRoots
        Scal = 0.0d0
        do kRoot = 1, nRoots
          if (iRoot(kRoot) == jRoot) Scal = Weight(kRoot)
        end do
        DMAT(:) = SCAL * DTMP(:)
        DSPN(:) = SCAL * PSMAT(:)
        PSMAT(:) = SCAL * Ptmp(:)
        PAMAT(:) = SCAL * PAtmp(:)
! Put it on the RUNFILE
        call Put_D1MO(DTMP,NACPAR)
        call Put_P2MO(Ptmp,NACPR2)
! Save density matrices on disk
        iDisk = IADR15(4)
        jDisk = IADR15(3)
        call DDafile(JOBIPH, 1, DTMP, NACPAR, jDisk)
        call DDafile(JOBIPH, 1, DStmp, NACPAR, jDisk)
        call DDafile(JOBIPH, 1, Ptmp, NACPR2, jDisk)
        call DDafile(JOBIPH, 1, PAtmp, NACPR2, jDisk)
      end do

      call mma_deallocate(DTMP)
      call mma_deallocate(DStmp)
      call mma_deallocate(Ptmp)
      call mma_deallocate(PAtmp)

* print matrices
      if (IPRLEV >= DEBUG) then
        call TRIPRT('Averaged one-body density matrix, DMAT',
     &              ' ',DMAT,NAC)
        call TRIPRT('Averaged one-body spin density matrix, DS',
     &              ' ',DSPN,NAC)
        call TRIPRT('Averaged two-body density matrix, P',
     &              ' ',PSMAT,NACPAR)
        call TRIPRT('Averaged antisymmetric two-body density matrix,PA',
     &              ' ',PAMAT,NACPAR)
      end if
c
      IF (NASH(1) /= NAC) call DBLOCK(DMAT)
      call Timing(Rado_2, Swatch, Swatch, Swatch)
      Rado_2 = Rado_2 - Rado_1
      Rado_3 = Rado_3 + Rado_2
**************************************************************
**************************************************************

999   continue
      call mma_deallocate(CICtl1)
*
      call qExit('FCIQMC_CTL')
      Return
      end subroutine fciqmc_ctl
      end module fciqmc
