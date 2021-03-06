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
      subroutine cartoneX(L,Lmax,onecontr,ncontrac,
     *MxcontL,onecartX)
      implicit real*8 (a-h,o-z)
      dimension onecontr(MxcontL,MxcontL,-Lmax:Lmax,3),
     *onecartX(MxcontL,MxcontL,(Lmax+Lmax+1)*(Lmax+1))
cbs   arranges the cartesian one-elctron-integrals for X  on a
cbs   quadratic matrix
      ipnt(I,J)=(max(i,j)*(max(i,j)-1))/2+min(i,j)
cbs   - + Integrals    m || mprime     mprime=m+1
      do Mprime=2,L
      M=mprime-1
      iaddr=ipnt(Mprime+L+1,-M+L+1)
      do jcont=1,ncontrac
      do icont=1,ncontrac
      onecartX(icont,jcont,iaddr)=
     *onecartX(icont,jcont,iaddr)
     *-0.25d0*(
     *onecontr(icont,jcont,Mprime,1)+
     *onecontr(icont,jcont,-Mprime,3))
      enddo
      enddo
      enddo
cbs   - + Integrals    m || mprime     mprime=m-1
      do Mprime=1,L-1
      M=mprime+1
      iaddr=ipnt(Mprime+L+1,-M+L+1)
      do jcont=1,ncontrac
      do icont=1,ncontrac
      onecartX(icont,jcont,iaddr)=
     *onecartX(icont,jcont,iaddr)
     *-0.25d0*(
     *onecontr(icont,jcont,Mprime,3)+
     *onecontr(icont,jcont,-Mprime,1))
      enddo
      enddo
      enddo
cbs   -1 || 0 integrals
      pre=sqrt(0.125d0)
      iaddr=ipnt(L,L+1)
      do jcont=1,ncontrac
      do icont=1,ncontrac
      onecartX(icont,jcont,iaddr)=
     *onecartX(icont,jcont,iaddr)
     *-pre* (onecontr(icont,jcont,0,3)+
     *onecontr(icont,jcont,0,1) )
      enddo
      enddo
      return
      end
