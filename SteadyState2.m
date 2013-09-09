%% Introduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steady State script for a SR Machine (part II).
%
% Interpolation and numerical method in order to obtain the flux linkage
% over a rotor pole pitch. Also, current and torque are calculated
% subsequently over the same region.
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 02-07-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Omega=2*pi/3;                                  % SRG desired (constant) speed.
Pe=1000000;                                    % SRG desired power output.         
ON=20;                                         % theta on
OFF=30;                                        % theta off
theta_on=ON;
theta_off=OFF;
V=400;                                         % initial guess for voltage.
e=2*pi/lcm(Stat_Poles,Rot_Poles);              % Stroke angle in radians.

find_psi_;
      
for i=1:length(theta_)
I_(i)=Imap(psi_(i),theta_(i),psi,Current(:,1),theta);
end

for i=1:length(theta_)
   
T_(i)=Tmap(I_(i),theta_(i),Torque,Current(:,1),theta);
end


if abs(trapz(I_,psi_)*Omega/e-Pe)>10000
    sprintf('Sorry, need to rearrange Voltage; Output power is not equal to the desired one.')
end