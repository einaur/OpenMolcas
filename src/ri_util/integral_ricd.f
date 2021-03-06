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
      SubRoutine Integral_RICD(iCmp,iShell,MapOrg,
     &                         iBas,jBas,kBas,lBas,kOp,
     &                         Shijij,IJeqKL,iAO,iAOst,ijkl,
     &                         AOInt,SOInt,nSOint,
     &                         iSOSym,nSkal,nSOs,
     &                         TInt,nTInt,iTOffs,nSym)
      Implicit Real*8 (A-H,O-Z)
*
      Real*8 AOInt(*), SOInt(*), TInt(nTInt)
      Integer iCmp(4), iShell(4), iAO(4),
     &        iAOst(4), kOp(4), iSOSym(2,nSOs),
     &        iTOffs(0:7,0:7,0:7), MapOrg(4)
      Logical Shijij,IJeqKL
*
      If (nSym==1) Then
        Call PLF_RICD(AOInt,ijkl,iCmp(1),iCmp(2),iCmp(3),iCmp(4),
     &                iShell,iAO,iAOst,Shijij.and.IJeqKL,
     &                iBas,jBas,kBas,lBas,kOp,TInt,
     &                iTOffs(1,0,0),iTOffs(2,0,0),iTOffs(0,0,0),
     &                iTOffs(3,0,0),iTOffs(4,0,0))
      Else
         Write (6,*) 'Integral_RICD: fatal error!'
         Call Abend()
      End If
*
      Return
c Avoid unused argument warnings
      If (.False.) Then
         Call Unused_integer_array(MapOrg)
         Call Unused_real_array(SOInt)
         Call Unused_integer(nSOint)
         Call Unused_integer_array(iSOSym)
         Call Unused_integer(nSkal)
         Call Unused_integer(nSym)
      End If
      End
