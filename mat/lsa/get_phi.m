%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_phi
%
%  This function caculates the potentials at a set of 3D pts, given by
%  pt_coord = [x, y, z].  The potential is produced by a set of line segments
%  with current I, lengths ds, and distances to the pt_coord (in a the reference
%  frame of each line) given by h,R.  For full explanation of the calculation
%  and notation refer to the thesis of Gary Holt, Appendix C.
%  
%  This implementation was written by Zoran Nenadic, Caltech, 12/17/2001
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f] = get_phi(h,R,ds,I, sigma, pt_coord)

[N n] = size(h);                    %number of segments & points

dss = ds * ones(1,n);
L = h + dss;             %calculate L

I1 = [h < 0 & L < 0];
I3 = [h > 0 & L > 0];
I2 = ~I1 & ~I3;

i1=find(I1~=0);
i2=find(I2~=0);
i3=find(I3~=0);


phi=zeros(N,n);

% when comparing to holt thesis, note that what we call "R" here is really r^2 in Gary's notation

if (length(i1) ~= 0)
	phi(i1)= log((sqrt(h(i1).^2+R(i1))-h(i1))./(sqrt(L(i1).^2+R(i1))-L(i1)));
end

if (length(i2) ~= 0)
	phi(i2)=log(((sqrt(h(i2).^2+R(i2))-h(i2)).* (sqrt(L(i2).^2+R(i2))+L(i2)))./R(i2));
end

if (length(i3) ~= 0)
	phi(i3)= log((sqrt(L(i3).^2+R(i3))+L(i3))./(sqrt(h(i3).^2+R(i3))+h(i3)));
end


Phi = 1/(4*pi*sigma) * (((I./ds)*ones(1,n)).*phi);


f = sum(Phi);   % 1 x n matrix

