%% Introduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steady State script for an SR Machine (part I).
%
% Calculation of psi(i,theta), T(i,theta) Look-up Tables.
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 01-07-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%Parameters
Stat_Poles=12;       % Ns
Rot_Poles =8;        % Nr
Rate_of_F=0.99;      % percentage of angle f to rotor pole pitch: 360/Nr.
spa=20;
rpa=20;


%Assign range of variables
J=[0 2 4 6 8 10 12 14 16 18 20];               % Current Density in A/mm^2.
theta=0:5:360/Rot_Poles;

%Assign empty multi-dimensional matrices.
psi=zeros(length(J),length(theta));
L=zeros(length(J),length(theta));
R=zeros(length(J),length(theta));
Torque=zeros(length(J),length(theta));
Current=zeros(length(J),length(theta));
Bstator=zeros(length(J),length(theta));
Brotor=zeros(length(J),length(theta));
Vstator=zeros(length(J),length(theta));
Vrotor=zeros(length(J),length(theta));
iterations=length(theta)*length(J);
iteration=1;


for i= 1:length(J)
    
    Design(Stat_Poles, Rot_Poles, spa, rpa, J(i), Rate_of_F);

    for j= 1:length(theta)
        
        starttime=clock;
        openfemm;
        opendocument(sprintf('SR %d %d_%d %d.fem',Stat_Poles,Rot_Poles,spa,rpa));
        mi_selectgroup(2);  
        mi_moverotate(0,0,theta(j));
        mi_clearselected;
        mi_saveas('test.fem');
        mi_analyze(1);
        mi_loadsolution;
        meta=mo_getcircuitproperties('A');
        psi(i,j)=meta(3);
        L(i,j)=meta(3)/meta(1);
        R(i,j)=meta(2)/meta(1);
        Current(i,j)=meta(1);
        mo_groupselectblock(2);
        Torque(i,j)=mo_blockintegral(22);
        
        Vrotor(i,j)=mo_blockintegral(10);
        Brotor(i,j)=sqrt(mo_blockintegral(8)^2 + mo_blockintegral(9)^2)/Vrotor(i,j);
        
        mo_clearblock;
        mo_groupselectblock(1);
        Vstator(i,j)=mo_blockintegral(10);
        Bstator(i,j)=sqrt(mo_blockintegral(8)^2 + mo_blockintegral(9)^2)/Vstator(i,j);

        mo_close;
        mi_close;
        closefemm;
        delete('test.fem');
        delete('test.ans');
        disp(sprintf('%i of %i :: %f seconds',iteration,iterations,etime(clock,starttime)));
        iteration=iteration+1;

        
    end
    delete(sprintf('SR %d %d_%d %d.fem',Stat_Poles,Rot_Poles,spa,rpa));
end


