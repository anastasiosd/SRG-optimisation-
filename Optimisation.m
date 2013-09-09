%% Introduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimisation script for a SR Machine.
% Choose non-parametrically the variables domain (rpa,spa).
% Namely: only constrain (4.7) has been applied, the rest ones (4.8-4.9)
% need to be applied manually in the variables domain assignment.
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 26-06-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear all;

%Parameters
Stat_Poles=24;       % Ns
Rot_Poles =16;       % Nr
J_=5;                % Current Density in A/mm^2.
Rate_of_F=0.99;      % percentage of angle f to rotor pole pitch: 360/Nr.
Omega=2*pi/3;        % Anglular mechanical velocity of SRG.

%Assign variables domain

rpa_2=2:2:20;
spa_2=2:2:14;
theta_2=0:2.5:(360/Rot_Poles);

%Assign empty multi-dimensional matrices.
Tq=zeros(length(theta_2),length(spa_2),length(rpa_2));
psi=zeros(length(theta_2),length(spa_2),length(rpa_2));
L=zeros(length(theta_2),length(spa_2),length(rpa_2));
P=zeros(length(theta_2),length(spa_2),length(rpa_2));
Vstator=zeros(length(theta_2),length(spa_2),length(rpa_2));
Vrotor=zeros(length(theta_2),length(spa_2),length(rpa_2));
Bstator=zeros(length(theta_2),length(spa_2),length(rpa_2));
Brotor=zeros(length(theta_2),length(spa_2),length(rpa_2));

for rpa_= 1:length(rpa_2)
    for spa_= 1:length(spa_2)
        
        if ((Design(Stat_Poles, Rot_Poles, spa_2(spa_), rpa_2(rpa_), J_, Rate_of_F)==1) && (rpa_2(rpa_)+spa_2(spa_)<=360/Rot_Poles))
             
        for theta=1:length(theta_2)
                    
        openfemm;
        opendocument(sprintf('SR %d %d_%d %d.fem',Stat_Poles,Rot_Poles,spa_2(spa_),rpa_2(rpa_)));
        mi_selectgroup(2);  
        mi_moverotate(0,0,theta_2(theta));
        mi_clearselected;
        mi_saveas('test.fem');
        mi_analyze(1);
        mi_loadsolution;
        meta=mo_getcircuitproperties('A');
        psi(theta,spa_,rpa_)=meta(3);
        L(theta,spa_,rpa_)=meta(3)/meta(1);
        P(theta,spa_,rpa_)=meta(2)*meta(1);
        mo_groupselectblock(2);
        Tq(theta,spa_,rpa_)=mo_blockintegral(22);
        Vrotor(theta,spa_,rpa_)=mo_blockintegral(10);
        Brotor(theta,spa_,rpa_)=sqrt(mo_blockintegral(8)^2 + mo_blockintegral(9)^2)/Vrotor(theta,spa_,rpa_);
        mo_clearblock;
        mo_groupselectblock(1);
        Vstator(theta,spa_,rpa_)=mo_blockintegral(10);
        Bstator(theta,spa_,rpa_)=sqrt(mo_blockintegral(8)^2 + mo_blockintegral(9)^2)/Vstator(theta,spa_,rpa_);
        mo_close;
        mi_close;
        closefemm;
        delete('test.fem');
        delete('test.ans');
        
        end
        delete(sprintf('SR %d %d_%d %d.fem',Stat_Poles,Rot_Poles,spa_2(spa_),rpa_2(rpa_)));
        end
        
    end
end
        


%% Post processing part.

for i=1:length(spa_2)
for j=1:length(rpa_2)
Tpeak(i,j)=max(Tq(:,i,j));
V(i,j)=Vstator(1,i,j)+Vrotor(1,i,j);
P_cu(i,j)=P(1,i,j);
Brpeak(i,j)=mean(Brotor(:,i,j));
Bspeak(i,j)=mean(Bstator(:,i,j));
Obj(i,j)=(Tpeak(i,j)*Omega-P_cu(i,j))/V(i,j);       % Objective function (to be maximised).
IndRatio(i,j)=max(L(:,i,j))/min(L(:,i,j));
end
end

[maxObj,ind] = max(Obj(:));
[m,n] = ind2sub(size(Obj),ind);
sprintf('A good design for a %d/%d SRG should be with spa=%d and rpa=%d degrees respectively.',Stat_Poles,Rot_Poles,spa_2(m),rpa_2(n))


%% Output figure of results.

figure;
subplot(2,2,1);
grid on;
surf(rpa_2,spa_2,IndRatio);
xlabel('rotor pole angle (Deg)');
ylabel('stator pole angle (Deg)');
zlabel('Inductance Ratio');
subplot(2,2,2);
grid on;
surf(rpa_2,spa_2,Obj);
xlabel('rotor pole angle (Deg)');
ylabel('stator pole angle (Deg)');
zlabel('Power per Volume (W/m^3)');
subplot(2,2,3);
grid on;
surf(rpa_2,spa_2,Bspeak);
xlabel('rotor pole angle (Deg)');
ylabel('stator pole angle (Deg)');
zlabel('Mean Flux Density in Stator (T)');
subplot(2,2,4);
grid on;
surf(rpa_2,spa_2,Brpeak);
xlabel('rotor pole angle (Deg)');
ylabel('stator pole angle (Deg)');
zlabel('Mean Flux Density in Rotor (T)');


