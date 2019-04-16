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
      SUBROUTINE VNEG_CHT3(VEC1,IST1,VEC2,IST2,NS)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION VEC1(*),VEC2(*)
      IF(IST1.EQ.1.AND.IST2.EQ.1)THEN
      DO 2 I=1,NS
 2    VEC2(I  )=-VEC1(I  )
      ELSE
      IS1=1
      IS2=1
      DO 1 I=1,NS
      VEC2(IS2)=-VEC1(IS1)
      IS1=IS1+IST1
 1     IS2=IS2+IST2
      ENDIF
      RETURN
      END
