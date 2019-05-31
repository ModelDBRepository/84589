%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_h
% 
%  This function performs the calculation of the distance of a set of
%  line segments to a set of points in line-centered cylindrical coordinates.
%  This is necessary for the Line Source Approximation described in the 
%  thesis of Gary Holt, Appendix C.  pt_coord are a set of 3D points, [x y z].
%  in_seg and fin_seg are two more sets of 3D points describing the start
%  and end of each line segment, respectively.
%   
%  This implementation was written by Zoran Nenadic, Caltech, 12/17/2001
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h, r2, ds]=get_h(pt_coord, in_seg, fin_seg)

% this can consume a lot of memory, so pack memory first...
pack_memory('./lsa/temp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GET THE RELEVANT DIMENSIONS

N = size(in_seg,1);      %get the number of segments
n = size(pt_coord,1);     %get the number of points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       DEFINE THE IMPORTANT MATRIX

M = zeros(3,3*n);         %define M=[I1|I2|...|In] where Ii=eye(3)
M(1,1:3:3*n-2) = 1;
M(2,2:3:3*n-1) = 1;
M(3,3:3:3*n) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GET THE SEGMENT LENGTHS

V = fin_seg - in_seg;

% is there a more memory efficient way to do this than to calculate V*V' ???
% del = sqrt(diag(V*V')); %vector containing the length of each segment

% like this...
del = sqrt(sum(V.*V,2));


zero_seg_nums = find(del==0);

if (length(zero_seg_nums) > 0)
	disp('!!!!!!!!!!!!!!  ZERO SEGS IN GET_H !!!!!!!!!!!!!!!!!!!!!!');
	zero_seg_nums
	zero_segs = [in_seg(zero_seg_nums,:) fin_seg(zero_seg_nums,:)]
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       RESHAPE THE COORDINATE FILE

pt_coord = reshape(pt_coord',1,3*n);          %1 x 3*n matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       SUBTRACT THE END OF EACH SEGMENT FROM EACH 
%                       POINT

H = ones(N,1) * pt_coord - fin_seg * M;     %N x 3*n matrix 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       ADJUST THE DIMENSION OF V 

J = V * M;                                  %N x 3*n matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       SUPER FAST PROJECTION

HH = H .* J;                                %project

HH = reshape(HH',3,(N*n))';                 %N*n x 3 matrix - reshape needed because sum
                                            %is going to be used

HH = sum(HH,2);                             %N*n x 1 matrix


HH = reshape(HH',n,N)';                     %N x n matrix - reshape back


HH = HH./(del*ones(1,n));                   %normalize

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       CALCULATE R^2 = (PT_COORD-FIN_SEG)^2 - HH^2

temp1 = H .* H;                             %N x 3*n matrix

temp1 = reshape(temp1',3,(N*n))';           %N*n x 3 - old trick

temp1 = sum(temp1,2);                       %N*n x 1 - another one

temp1 = reshape(temp1',n,N)';               %N x n matrix

r_sq = temp1 - HH.^2;                       %N x n matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GET THEM ALL TOGETHER

h = HH;                                     %return projection

r2 = r_sq;                                  %return r^2

ds = del;                                   %return length of each segment
