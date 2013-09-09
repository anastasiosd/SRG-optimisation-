%% Introduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script for calculating an SRG flux linkage over a rotor pole pitch.
% 
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 02-07-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta_=0:45;                            %rotor pole pitch period.
psi_=zeros(1,length(theta_));            
I_=zeros(1,length(theta_));
T_=zeros(1,length(theta_));

sum1=0;

    for i=1:length(theta_)

       if (theta_(i)<=theta_on)
           psi_(i)=0;
       end

       if ((theta_(i)>theta_on) && (theta_(i)<=theta_off))
          PSI=sum1;
          PSI0=0;
          PSI1=100;
          while  (abs(f1(sum1,theta_(i),theta_on,Omega,R(2,2),PSI,psi,Current(:,1),theta,V)) >1e-5 )

              PSI=PSI1-f1(sum1,theta_(i),theta_on,Omega,R(2,2),PSI1,psi,Current(:,1),theta,V)*(PSI1-PSI0)/(f1(sum1,theta_(i),theta_on,Omega,R(2,2),PSI1,psi,Current(:,1),theta,V)-f1(sum1,theta_(i),theta_on,Omega,R(2,2),PSI0,psi,Current(:,1),theta,V))
              PSI0=PSI1;
              PSI1=PSI;
          end
           
          psi_(i)=PSI;
          theta_on=theta_(i);
          sum1=PSI;     
           

       end

       if ((theta_(i)>theta_off) && psi_(i-1)>0)
           PSI=sum1;
           PSI0=psi(i-2);
           PSI1=psi(i-1);
          while  (abs(f2(sum1,theta_(i),theta_off,Omega,R(2,2),PSI,psi,Current(:,1),theta,V)) >1e-5 )
              
              PSI=PSI1-f2(sum1,theta_(i),theta_off,Omega,R(2,2),PSI1,psi,Current(:,1),theta,V)*(PSI1-PSI0)/(f2(sum1,theta_(i),theta_off,Omega,R(2,2),PSI1,psi,Current(:,1),theta,V)-f2(sum1,theta_(i),theta_off,Omega,R(2,2),PSI0,psi,Current(:,1),theta,V))
              PSI0=PSI1;
              PSI1=PSI;
          end
           psi_(i)=PSI;
           theta_off=theta_(i);
           sum1=PSI;

       end

       if psi_(i)<0
           psi_(i)=0;
       end

    end
