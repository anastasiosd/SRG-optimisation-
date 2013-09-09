function [ out2 ] = f2( a,b,c,d,e,f,g,h,i,j )
%F2 Calculates the integral of (-) voltage minus the voltage drop iR.
%
% Author : Anastasios Doukas (MSc University of Edinburgh)
% Date   : 10-07-2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out2=a-j*(b-c)/d-e*(b-c)*(Imap(f,b,g,h,i)+Imap(f,c,g,h,i))/(2*d)-f;

end

