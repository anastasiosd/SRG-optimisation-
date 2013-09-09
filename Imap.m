function Interpolation = Imap(i, j, k, l, m)
%Interpolation Function for inverting psi(i,theta) matrix.
%   i : flux linkage psi
%   j : theta position
%   k : psi(I, theta) matrix
%   l : current vector
%   m : theta vector
%   Objective is to calculate the inverse values of psi(I,theta) matrix
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 02-07-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[row, col]=size(k);
dist_col=zeros(1,col);
dist_row=zeros(1,row);
Interp_theta=zeros(1,row);
Meta=0;
for i_=1:col
    dist_col(i_)=abs(j-m(i_));
end

[sortedValues,sortIndex] = sort(dist_col(:),'ascend');
maxIndex = sortIndex(1:2);
sortMaxIndex=sort(maxIndex);

for i_=1:row    
Interp_theta(i_)=interp1([m(sortMaxIndex(1)) m(sortMaxIndex(2))],[k(i_,sortMaxIndex(1)) k(i_,sortMaxIndex(2))],j);
end

for i_=1:row-1
    
   if ( (i>=Interp_theta(i_)) && (i<=Interp_theta(i_+1)) )
       Meta=interp1([Interp_theta(i_) Interp_theta(i_+1) ], [l(i_) l(i_+1) ],i);
       
   end
   
   if (i>Interp_theta(i_+1)) 
       lamda=(-l(i_)+l(i_+1))/(-Interp_theta(i_)+Interp_theta(i_+1));
       ct=l(i_+1)-lamda*Interp_theta(i_+1);
       Meta=lamda*i+ct;
       
   end
       
end

Interpolation=Meta;
end

