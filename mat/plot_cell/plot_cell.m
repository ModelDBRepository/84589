%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  plot_cell
%  
%  Plots a cell from the geometry for use in the EAP grid plot, the 3D plot,
%  and the section labels plot (plot_eap_grid.m, plot_neuron_3d.m, 
%  plot_cell_labels.m).  The parameter "flat" is used for 2D plots and results
%  in the Z value for all of the cylinders is set to zero.  The cell is made by 
%  creating cylinders according to the size given by each start/end location and 
%  start/end diameter.  Note that this function assumes that the main axis is 
%  already open and plots the cell to it (as is the case for all the functions 
%  which call it)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_cell(start_coords,end_coords, start_diams, end_diams, plotMax, main_ax_h, flat)

Ns=size(start_coords,1);

% convert from meters to micrometers
scale_start_coords = start_coords * 1e6;
scale_end_coords = end_coords * 1e6;
scale_start_diams = start_diams * 1e6;
scale_end_diams = end_diams * 1e6;

v=scale_end_coords(:,1:3)-scale_start_coords(:,1:3);
L=sqrt(sum((v.*v),2));
th=atan2(v(:,2),v(:,1));
th=th*180/pi;
th=th+90;

d=sqrt(sum((v(:,1:2).*v(:,1:2)),2));
alpha=atan2(v(:,3),d);
alpha=alpha*180/pi;
alpha=90-alpha;

plot_cell_h = figure(get_next_fig);


for i=1:Ns

	
	if(~isempty(plotMax))
		if (scale_start_coords(i,1) > plotMax(2) | ...
			scale_start_coords(i,1) < plotMax(1) | ...
			scale_start_coords(i,2) > plotMax(4) | ...
			scale_start_coords(i,2) < plotMax(3))
				continue;
		end
	end
	
	Np = cylinder_num_pts(start_diams(i,1)*1e6);	% convert diam to microns	
	[x y z]=cylinder([scale_start_diams(i,1)/2 scale_end_diams(i,1)/2],Np);
	

	z=z*L(i);
	sh=surf(x,y,z);

	if (~isempty(plotMax))
    		axis([plotMax(1) plotMax(2) plotMax(3) plotMax(4)]);
    	end
	
	rotate(sh,[th(i) 0], alpha(i),[0 0 0]);
	
    	x=get(sh,'XData');
	y=get(sh,'YData');
	z=get(sh,'ZData');

    
	x=x+scale_start_coords(i,1);
	y=y+scale_start_coords(i,2);
	
	if (flat == 1)
		z=z*0;
	else
		z=z+scale_start_coords(i,3);
	end

	set(sh,'XData',x,'YData',y,'ZData',z, 'Parent', main_ax_h);

	clear x y z sh

	hold on;

end


close(plot_cell_h);
