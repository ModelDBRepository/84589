%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  makde_2D_pt_coords
%  
%  creates a matrix of xyz pts (each row corresponds to 1 pt) from xy limits,
%  a grid size, and a fixed Z.  Used by various functions that work on eaps
%  on a grid (do_zplane_eap_calc.m, plot_eap_grid.m, average_eap_measure.m)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pt_coord = make_2D_pt_coords(xyMax, Z, gridSize)

xGrid = [xyMax(1) : gridSize : xyMax(2)];
yGrid = [xyMax(3) : gridSize : xyMax(4)];

pt_coord = zeros(length(xGrid) * length(yGrid) ,3);

for j= 1:length(yGrid)
	for i= 1:length(xGrid)
		pt_num = (j-1)*length(xGrid) + i;
		pt_coord(pt_num,:)=[xGrid(i) yGrid(j) Z];
	end
end