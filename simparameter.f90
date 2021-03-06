module m_SimulationParameter
    
use m_DataStructures
use m_UtilityLib

implicit none
contains

subroutine simulation_parameter( hinges, simParams )  !2018/12/01  �ץ�

type(simulationParameters)  :: simParams
type (rod),   dimension(:)  :: hinges
type (rod)                  :: hinge1, hinge2

real(8), dimension(3)       :: r
real(8)                     :: segment_length, r_e, e_, L, r_fiber, gamma_dot, epsilon_dot
integer(8)                  :: Id, j, i, k, l_, aa  !error 2018/07/12  integer(8) flow case

r_fiber    = simParams%r_fiber         !2018/10/08  add
gamma_dot  = simParams%gamma_dot       !2018/10/08  add
epsilon_dot= simParams%epsilon_dot     !2018/10/08  add

hinge1 = hinges(1)
hinge2 = hinges(2)

r = hinge2%X_i-hinge1%X_i
segment_length  = sqrt(dot_product(r,r))

r_e= segment_length/(2.d0*r_fiber)     !2018/12/01 aspect ratio

r_e= 1.14d0 * r_e **0.884d0  !2018/07/31 p.12 equation (2.10)  adjust aspect ratio

e_= (1-r_e**-2)**0.5d0;     !2018/07/31  P.89 equation (A.5)
L = log((1+e_)/(1-e_));   !2018/07/31  P.89 equation (A.5)

!error 2018/12/01 origional
! for the force  we need 2 Constants
! for the Torque we need 3 Constants
!simParams%X_A = 8.0/3.0 * e_**3*(-2*e_ + (1+e_**2)*L)**-1             !2018/07/31 p.89 equation (A.4)
!simParams%Y_A = 16.0/3.0 * e_**3*(2*e_ + (3*e_**2-1)*L)**-1           !2018/07/31 p.89 equation (A.4)
!simParams%X_C = 4.0/3.0 * e_**3*(1-e_**2)*(2*e_ - (1-e_**2)*L)**-1    !2018/07/31 p.89 equation (A.4)
!simParams%Y_C = 4.0/3.0 * e_**3*(2-e_**2)*(-2*e_ + (1+e_**2)*L)**-1   !2018/07/31 p.89 equation (A.4)
!simParams%Y_H = 4.0/3.0 * e_**5*(-2*e_ + (1+e_**2)*L)**-1             !2018/07/31 p.89 equation (A.4)

!2018/12/01 new 
simParams%X_A = ( 8.0d0/3.0d0)*(e_**3.d0)/(-2.d0*e_+(1.d0+e_**2.d0)*L)        !2018/07/31 p.89 equation (A.4)
simParams%Y_A = (16.0d0/3.0d0)*(e_**3.d0)/( 2.d0*e_+(3.d0*e_**2.d0-1.d0)*L)   !2018/07/31 p.89 equation (A.4)
simParams%X_C = ( 4.0d0/3.0d0)*(e_**3.d0)*( 1.d0-e_**2.d0)/( 2.d0*e_-(1.d0-e_**2.d0)*L)        !2018/07/31 p.89 equation (A.4)
simParams%Y_C = ( 4.0d0/3.0d0)*(e_**3.d0)*( 2.d0-e_**2.d0)/(-2.d0*e_+(1.d0+e_**2.d0)*L)        !2018/07/31 p.89 equation (A.4)
simParams%Y_H = ( 4.0d0/3.0d0)*(e_**5.d0)/(-2.d0*e_+(1.d0+e_**2.d0)*L)        !2018/07/31 p.89 equation (A.4)


! for a shear rate the rate of strain tensor is:
simParams%E_oo = 0                                   
simParams%E_oo(1,2)= 0.5 *gamma_dot
simParams%E_oo(2,1)= 0.5 *gamma_dot

! generate permutation tensor

do i=1,3
    do j=1,3
        do k =1,3
            if( (i .eq. j) .or. (j.eq.k) .or. (k .eq. i)) then
               simParams%eps(i,j,k) =0
            else
                aa = (k-j) + (j-i);
                if ( (aa.eq.2) .or. (aa.eq.-1)) then
                    simParams%eps(i,j,k) = 1
                else
                    simParams%eps(i,j,k) = -1
                endif              
            endif          
        enddo
    enddo
enddo

end subroutine simulation_parameter   !2018/07/21 �ץ��r��


end module m_SimulationParameter        !2018/07/21 change name
