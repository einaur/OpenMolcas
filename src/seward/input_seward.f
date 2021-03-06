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
* Copyright (C) 1990,1991,1993, Roland Lindh                           *
*               1990, IBM                                              *
************************************************************************
      SubRoutine Input_Seward(lOPTO)
************************************************************************
*                                                                      *
*     Object: to read the input to the integral package.               *
*                                                                      *
*     Author: Roland Lindh, IBM Almaden Research Center, San Jose, CA  *
*             January '90                                              *
*                                                                      *
*             January '91 additional input for property calculations.  *
*             October '93 split up to RdCtl and SoCtl.                 *
************************************************************************
      use Sizes_of_Seward, only: S
      use Basis_Info, only: nBas
      use Temporary_Parameters, only: Test, PrPrt, Primitive_Pass
      use Logical_Info, only: Do_GuessOrb
      use Symmetry_Info, only: nIrrep
      Implicit Real*8 (A-H,O-Z)
#include "Molcas.fh"
#include "real.fh"
#include "SysDef.fh"
#include "print.fh"
#include "stdalloc.fh"
      Parameter (nMamn=MaxBfn+MaxBfn_Aux)
      Character*(LENIN8), Allocatable :: Mamn(:)
      Logical Show_Save, lOPTO
      Logical Reduce_Prt
      External Reduce_Prt
      Save Show_Save
*                                                                      *
************************************************************************
*                                                                      *
      iRout=2
*                                                                      *
************************************************************************
*                                                                      *
      LuWr=6
*
      If (Primitive_Pass) Then
         Show_Save=Show
      Else ! .Not.Primitive
         Show=Show_Save
      End If
*                                                                      *
************************************************************************
************************************************************************
*                                                                      *
*
*     Adjust the print level and some other parameters depending on
*     if we are iterating or not.
*
*     Set Show to false if Seward is run in property mode.
      Show=Show.and..Not.Prprt
*
      If ((Reduce_Prt().and.nPrint(iRout).lt.6).and..Not.Prprt) Then
         Show=.False.
         Do_GuessOrb=.False.
      End If
*
      Show=Show.and..Not.Primitive_Pass
      Show = Show .or. Test
*                                                                      *
************************************************************************
*                                                                      *
*     Modify storage of basis functions to be in accordance with a
*     calculation in the primitive or contracted basis.
*
      Call Flip_Flop(Primitive_Pass)
*                                                                      *
************************************************************************
*                                                                      *
*     Start of output, collect all output to this routine!
*
      If (Show) Call Output1_Seward(lOPTO)
*                                                                      *
************************************************************************
*                                                                      *
*-----Generate the SO or AO basis set
*
      Call mma_allocate(Mamn,nMamn,label='Mamn')
      Call SOCtl_Seward(Mamn,nMamn)
*                                                                      *
************************************************************************
*                                                                      *
      If (Test) Then
         Return
      End If
*                                                                      *
************************************************************************
*                                                                      *
*     Write information on the run file.
*
      If (Primitive_Pass) Then
         Call Put_iArray('nBas_Prim',nBas,nIrrep)
         Call Info2Runfile()
      End If
      Call Put_cArray('Unique Basis Names',Mamn(1),(LENIN8)*S%nDim)
      Call Put_iArray('nBas',nBas,nIrrep)
      Call mma_deallocate(Mamn)
*                                                                      *
************************************************************************
*                                                                      *
      Return
      End
