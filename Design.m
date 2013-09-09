%% Introduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program for creating an SR Machine geometry in its unaligned position.
% Also, only phase A is energised, with the according current density.
%
% The user needs to select: Stator poles number, Rotor poles number, spa,
% rpa, Current Density, and percentage of angle 'f' (see main script for
% details).
%
% Function returns a zero output, whenever the inserted parameters do not
% make sense. On every other occasion, it returns "1" as output, and at the
% same time a .fem file is created and saved at the current directory. 
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 08-06-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

function De = Design(StatorPoles, RotorPoles, SPA, RPA, CurrentDensity, Percentage_of_angle_f)
%% Parameters

%independent variables 
Ns=StatorPoles;                     %Stator Poles
Nr=RotorPoles;                      %Rotor Poles

di=1.7;                             %outer rotor diameter (m)
l=3;                                %corelength (m)
g=0.001;                            %airgap (m)
ff=0.6;                             %usually 0.4-0.6

%dependent variables
spp=360/Ns;                         %stator pole pitch (deg)
rpp=360/Nr;                         %rotor pole pitch (deg)

spa=SPA;                            %stator pole angle (deg)
rpa=RPA;                            %rotor pole angle (deg)
f=Percentage_of_angle_f*360/Nr;     %angle f used in machine design (deg)

do=(2*di*sind(spa/2)+di/2+g)*2;     %outer stator diameter (m)
sc=di*sind(spa/2);                  %stator back core (m)
rc=(di/2)*sind(rpa/2)/sind(f/2);    %distance from center to rotor inner radius (m)
sh=2*0.3*rc;                        %shaft diameter (m)
rcc=0.7*rc;                         %rotor back core (m)
phases=lcm(Ns,Nr)/Nr;               %number of phases
turns=1;                            %number of initial turns.

CoilCurrent=zeros(1,phases);        %initial coil current


if ((f>=360/Nr) || (f<=rpa))        %A zero output means the input parameters are wrong.
    De=0;
    return;
end

%% Create femm file
openfemm;
newdocument(0);
mi_probdef(0,'meters','planar',1E-8,l,30,0);

%% Nodes in outer stator diameter
mi_addnode(do*cosd(90)/2,do*sind(90)/2);
mi_addnode(do*cosd(-90)/2,do*sind(-90)/2);
mi_addarc(do*cosd(90)/2,do*sind(90)/2,do*cosd(-90)/2,do*sind(-90)/2,180,1);
mi_addarc(do*cosd(-90)/2,do*sind(-90)/2,do*cosd(90)/2,do*sind(90)/2,180,1);
mi_addboundprop('A=0',0,0,0,0,0,0,0,0,0);
mi_selectarcsegment(do/2,0);
mi_selectarcsegment(-do/2,0);
mi_setarcsegmentprop(1,'A=0',0,1)
mi_clearselected;

%Add nodes and segments in stator
x=asind((g+di/2)*sind(spa/2)/(do/2-sc));

mi_drawline( (g+di/2)*cosd(0), (g+di/2)*sind(0), (do/2-sc)*cosd(spa/2-x), (do/2-sc)*sind(spa/2-x) );

mi_drawline( (g+di/2)*cosd(spa), (g+di/2)*sind(spa), (do/2-sc)*cosd(spa/2+x), (do/2-sc)*sind(spa/2+x) );

mi_addarc( (g+di/2)*cosd(0), (g+di/2)*sind(0), (g+di/2)*cosd(spa), (g+di/2)*sind(spa), spa, 1);

mi_selectnode((g+di/2)*cosd(0), (g+di/2)*sind(0));
mi_selectnode((do/2-sc)*cosd(spa/2-x), (do/2-sc)*sind(spa/2-x));
mi_selectnode((g+di/2)*cosd(spa), (g+di/2)*sind(spa));
mi_selectnode((do/2-sc)*cosd(spa/2+x), (do/2-sc)*sind(spa/2+x));
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;

la=spp-2*x;
mid_x=(do/2-sc)*cosd(spa/2+x+la/2);
mid_y=(do/2-sc)*sind(spa/2+x+la/2);
mid_x1=(di/2+g)*cosd(spa/2+x+la/2);
mid_y1=(di/2+g)*sind(spa/2+x+la/2);
mi_addnode(mid_x,mid_y);
mi_addnode(mid_x1, mid_y1);
mi_addarc((do/2-sc)*cosd(spa/2+x), (do/2-sc)*sind(spa/2+x), mid_x, mid_y, la/2, 1);
mi_addarc(mid_x, mid_y, (do/2-sc)*cosd(spa/2+x+la), (do/2-sc)*sind(spa/2+x+la),la/2,1);

mi_selectsegment((g+di/2)*cosd(0), (g+di/2)*sind(0));
mi_selectsegment((g+di/2)*cosd(spa), (g+di/2)*sind(spa));
mi_selectarcsegment((g+di/2)*cosd(spa), (g+di/2)*sind(spa));
mi_selectarcsegment((do/2-sc)*cosd(spa/2+x), (do/2-sc)*sind(spa/2+x));
mi_selectarcsegment((do/2-sc)*cosd(spa/2+x+la), (do/2-sc)*sind(spa/2+x+la));
mi_setgroup(1);
mi_clearselected;
mi_selectgroup(1);
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;


% create winding slots
mi_selectnode(mid_x1, mid_y1);
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;
mi_addsegment(mid_x, mid_y, mid_x1, mid_y1);
mi_selectsegment(mid_x1, mid_y1);
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;
mi_addarc((di/2+g)*cosd(spa),(di/2+g)*sind(spa),mid_x1, mid_y1,(spp-spa)/2,1);
mi_addarc(mid_x1, mid_y1,(di/2+g)*cosd(spp),(di/2+g)*sind(spp),(spp-spa)/2,1);
mi_selectarcsegment((di/2+g)*cosd((3*spa+spp)/4),(di/2+g)*sind((3*spa+spp)/4));
mi_selectarcsegment((di/2+g)*cosd((spa+3*spp)/4),(di/2+g)*sind((spa+3*spp)/4));
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;

%add empty block labels in the winding slots
Rblock=((di+do)/4+(g-sc)/2);
thetabl1=3*spa/4+x/2+la/4;
thetabl2=spp/2+spa/4+x/2+la/4;
blockx1=Rblock*cosd(thetabl1);
blocky1=Rblock*sind(thetabl1);
blockx2=Rblock*cosd(thetabl2);
blocky2=Rblock*sind(thetabl2);
mi_addblocklabel(blockx1,blocky1);
mi_addblocklabel(blockx2,blocky2);
mi_selectlabel(blockx1,blocky1);
mi_selectlabel(blockx2,blocky2);
mi_copyrotate(0,0,spp,Ns);
mi_clearselected;


%% add nodes and segments in rotor 

% shaft
mi_addnode(sh*cosd(90)/2,sh*sind(90)/2);
mi_addnode(sh*cosd(-90)/2,sh*sind(-90)/2);
mi_addarc(sh*cosd(90)/2,sh*sind(90)/2,sh*cosd(-90)/2,sh*sind(-90)/2,180,10);
mi_addarc(sh*cosd(-90)/2,sh*sind(-90)/2,sh*cosd(90)/2,sh*sind(90)/2,180,10);
   

% rotor

mi_drawline( rc*cosd(0), rc*sind(0), (di/2)*cosd((f-rpa)/2), (di/2)*sind((f-rpa)/2) );

mi_drawline( rc*cosd(f), rc*sind(f), (di/2)*cosd((f+rpa)/2), (di/2)*sind((f+rpa)/2) );

mi_addarc( (di/2)*cosd((f-rpa)/2), (di/2)*sind((f-rpa)/2), (di/2)*cosd((f+rpa)/2), (di/2)*sind((f+rpa)/2),  rpa, 1);

mi_selectnode(rc*cosd(0), rc*sind(0));
mi_selectnode(rc*cosd(f), rc*sind(f));
mi_selectnode((di/2)*cosd((f-rpa)/2), (di/2)*sind((f-rpa)/2));
mi_selectnode((di/2)*cosd((f+rpa)/2), (di/2)*sind((f+rpa)/2));
mi_copyrotate(0,0,rpp,Nr);
mi_clearselected;

mi_addarc(rc*cosd(f), rc*sind(f), rc*cosd(rpp), rc*sind(rpp), rpp-f, 1);
mi_selectsegment(rc*cosd(0), rc*sind(0));
mi_selectsegment(rc*cosd(f), rc*sind(f));
mi_selectarcsegment(rc*cosd(f), rc*sind(f));
mi_selectarcsegment((di/2)*cosd((f-rpa)/2), (di/2)*sind((f-rpa)/2));
mi_setgroup(2);
mi_clearselected;
mi_selectgroup(2);
mi_copyrotate(0,0,rpp,Nr);
mi_clearselected;

% zoom in natural dimensions
main_maximize;
mi_zoomnatural;


%% add materials/properties/group numbers

mi_getmaterial('Air');
mi_getmaterial('M-19 Steel');
mi_getmaterial('Aluminum, 1100');
mi_getmaterial('Copper');
mi_getmaterial('10 SWG');

mi_seteditmode('blocks');
mi_addblocklabel(0,(di+g)/2);
mi_selectlabel(0,(di+g)/2);
mi_setblockprop('Air',1,1,'<None>',0,0,0);
mi_clearselected;

mi_addblocklabel(0,(do-sc)/2);
mi_selectlabel(0,(do-sc)/2);
mi_setblockprop('M-19 Steel',1,1,'<None>',0,1,0);
mi_clearselected;

mi_addblocklabel(0,(sh+rcc)/2);
mi_selectlabel(0,(sh+rcc)/2);
mi_setblockprop('M-19 Steel',1,1,'<None>',0,2,0);
mi_clearselected;

mi_addblocklabel(0,sh/4);
mi_selectlabel(0,sh/4);
mi_setblockprop('Aluminum, 1100',1,1,'<None>',0,2,0);
mi_clearselected;


%% add Phases in the winding slots

% create phases from alphabet
Alphabet=char('A'+(1:phases)-1)';
turns1=turns;
turns2=-turns;

% create circuits
for i=1:phases
mi_addcircprop(Alphabet(i), CoilCurrent(i), 1);
end

%assign windings (1/2)
for i=1:Ns
    
   mi_selectlabel(Rblock*cosd(thetabl1+(i-1)*spp),Rblock*sind(thetabl1+(i-1)*spp));
   
   if (mod(i,phases)==0)
   mi_setblockprop('Copper',1,5,Alphabet(phases),0,3,turns1);
   else
   mi_setblockprop('Copper',1,5,Alphabet(mod(i,phases)),0,3,turns1);
   end
   
   if (mod(i,phases)==0)
   turns1=-1*turns1;
   end
   
   mi_clearselected;
    
end

%assign windings (2/2)
for i=2:(Ns+1)
    
   mi_selectlabel(Rblock*cosd(thetabl2+(i-2)*spp),Rblock*sind(thetabl2+(i-2)*spp));
   
   if (mod(i,phases)==0)
   mi_setblockprop('Copper',1,5,Alphabet(phases),0,3,turns2);
   else
   mi_setblockprop('Copper',1,5,Alphabet(mod(i,phases)),0,3,turns2);
   end
   
   if (mod(i,phases)==0)
   turns2=-1*turns2;
   end
   
   mi_clearselected;
    
end

%% Set geometry in unaligned position

mi_selectgroup(2);
if (f>=spa)
    mi_moverotate(0,0,(spa-f-rpp)/2);
else
    mi_moverotate(0,0,(f-spa-rpp)/2);
end
mi_clearselected;

%% save file as

filename = sprintf('SR %d %d_%d %d.fem',Ns,Nr,spa,rpa);
mi_saveas(filename);


%% perform simulation for computing slot surface

mi_analyze(1);
mi_loadsolution;
mo_groupselectblock(3); 
S_slot=mo_blockintegral(5)*1000000/(Ns*2);                    %Convert S_slot to mm^2.
S_cu=ff*S_slot;
mo_close;
turns=floor(4*S_cu/(pi*3.2512*3.2512));                       % 3.2512mm is the diameter of 10 SWG cable.
CoilCurrent(1)=CurrentDensity*S_cu/turns;                     %coil current in Amps. Density in A/mm^2.
mi_modifycircprop(Alphabet(1), 1, CoilCurrent(1));            %put the correct current in phase A.

turns1=turns;
turns2=-turns;
%reassign windings (1/2)
for i=1:Ns
    
   mi_selectlabel(Rblock*cosd(thetabl1+(i-1)*spp),Rblock*sind(thetabl1+(i-1)*spp));
   
   if (mod(i,phases)==0)
   mi_setblockprop('10 SWG',1,5,Alphabet(phases),0,3,turns1);
   else
   mi_setblockprop('10 SWG',1,5,Alphabet(mod(i,phases)),0,3,turns1);
   end
   
   if (mod(i,phases)==0)
   turns1=-1*turns1;
   end
   
   mi_clearselected;
    
end

%reassign windings (2/2)
for i=2:(Ns+1)
    
   mi_selectlabel(Rblock*cosd(thetabl2+(i-2)*spp),Rblock*sind(thetabl2+(i-2)*spp));
   
   if (mod(i,phases)==0)
   mi_setblockprop('10 SWG',1,5,Alphabet(phases),0,3,turns2);
   else
   mi_setblockprop('10 SWG',1,5,Alphabet(mod(i,phases)),0,3,turns2);
   end
   
   if (mod(i,phases)==0)
   turns2=-1*turns2;
   end
   
   mi_clearselected;
    
end

mi_saveas(filename);                                          %final save.
delete(sprintf('SR %d %d_%d %d.ans',Ns,Nr,spa,rpa));          %clean up.
closefemm;                                                    %Adios.


%% output results
De=1;

end
    

