!====================================================================
module m_SetVelocity
    
use m_DataStructures
use m_UtilityLib
use m_OutputData                                                              !2018/10/11  change name
implicit none
contains

subroutine set_velocity( X, vel, omega, simParameters )    !2018/12/01  change

type(simulationParameters)   :: simParameters            !2018/12/01 add

integer(8)                   :: flow_case
real(8), dimension (3)       :: X, vel, omega
real(8)                      :: b, gamma_dot, epsilon_dot

flow_case   = simParameters%flow_case       !2018/12/01  change
gamma_dot   = simParameters%gamma_dot       !2018/12/01  change
epsilon_dot = simParameters%epsilon_dot     !2018/12/01  change

vel=   0
omega= 0

if( flow_case==3 ) then 
	b = 1
else
    b = 0
end if


if( flow_case==1 ) then
    
      vel(1)=    X(2)*gamma_dot*simParameters%coo_velocity   !2018/12/16 修正
      
      omega(3)=  -0.5*gamma_dot*simParameters%coo_omega      !2018/12/16 修正

else if( flow_case==1848 ) then  !2018/10/27
    
      vel(1)=    X(2)*gamma_dot
      
      omega(3)=  -0.5*gamma_dot !CORRECTED TS

      ! END - HAKAN Shearrate over TIME
      ! This is written by Hakan Celik  
      ! 06/07/2017      
else if( flow_case==61 ) then
            
        ! Step Constant Step  0.3
        ! Ramp Constant       0.2
        ! Constant            0.1    
        ! Interval 1
        ! Constant Velocity
        
        if (X(1) <= 20.00E-03 ) then
            vel(1)= 0.1

        ! Interval 2
        ! Ramp Velocity
        
        else if (X(1) > 20.00E-03 .AND. X(1) <= 40.00E-03) then
             vel(1) = ((0.2-0.1)/(40.00E-03 - 20.00E-03))*(X(1)-20.00E-03)+0.1

        ! Interval 3
        ! Constant Velocity
        
        else if (X(1) > 40.00E-03 .AND. X(1) <= 60.00E-03) then
             vel(1) = 0.2
             
        ! Interval 4
        ! Step Constant Step Velocity
        
        else if (X(1) > 60.00E-03 .AND. X(1) <= 80.00E-03) then
             vel(1) = 0.3

        ! Interval 5
        ! Constant Velocity
        
        else if (X(1) > 80.00E-03 .AND. X(1) <= 100.00E-03) then
             vel(1)= 0.2

        ! Interval 6
        ! Ramp Velocity 
        
        else if (X(1) > 100.00E-03 .AND. X(1) <= 120.00E-03) then
             vel(1)= ((0.1-0.2)/(120.00E-03 - 100.00E-03))*(X(1)-100.00E-03)+0.2

        ! Interval 7
        
        else
            vel(1) = 0.1
        end if
        
else if( flow_case==34 ) then 
   
        if (X(1) <= 20.00E-03 ) then
            vel(1)= 0.1
        
        ! Ramp Velocity
        else if (X(1) > 20.00E-03 .AND. X(1) <= 40.00E-03) then
             vel(1) = ((0.2-0.1)/(40.00E-03 - 20.00E-03))*(X(1)-20.00E-03)+0.1

        else
            vel(1) = 0.1
        end if
        vel(1) = 1
        
else if( flow_case==1461 ) then 
        vel(1) = epsilon_dot
   
        if (X(1) <= 0 ) then
            vel(1)= -epsilon_dot
        else
            vel(1)= epsilon_dot
        end if
        
! START - HAKAN Shearrate over TIME
else
	vel(1)= -0.5*epsilon_dot*(1+b)*X(1)
    vel(2)= -0.5*epsilon_dot*(1-b)*X(2)
    vel(3)=      epsilon_dot*X(3)
end if
		
end subroutine set_velocity  !2018/10/27 change 

!=============================================================================

subroutine set_velocity_1848( flowcase_1848, simParameters )   !2018/12/01

type(simulationParameters)                 :: simParameters    !2018/12/01 add
type(DynamicP), dimension(:), allocatable  :: flowcase_1848                   !2018/10/11  add

integer(8)                                 :: h                               !2018/10/11 

    h= simParameters%h

    simParameters%Controltime = flowcase_1848(h)%Duration                     !2018/10/11 增加

    if( simParameters%time > simParameters%Controltime ) then                 !2018/10/11 增加
        
        simParameters%h = simParameters%h + 1                                 !2018/10/11 增加
        
        if( simParameters%h .GT. simParameters%nbr_Dynamic ) then             !2018/10/11 增加
            simParameters%h = simParameters%nbr_Dynamic                       !2018/10/11 增加
        end if                                                                !2018/10/11 增加
        
        h= simParameters%h                                                    !2018/10/11 增加
        
        call output_DynamicP_1848( flowcase_1848, simParameters )             !2018/10/11 增加

    end if

    simParameters%Controltime = flowcase_1848(h)%Duration                     !2018/10/11 增加
    simParameters%gamma_dot   = flowcase_1848(h)%Shearrate                    !2018/10/11 增加
    simParameters%viscosity   = flowcase_1848(h)%Viscosity                    !2018/10/11  add
    

end subroutine set_velocity_1848  !2018/10/10 change name

end module m_SetVelocity     !2018/10/27 change 
!=============================================================================