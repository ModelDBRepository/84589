%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  cylinder_num_pts
%  
%  This script gives a number of pts to use in the circumference.when making a 
%  cylinder for a dendrite in the plot.  It just looks better scaling the number
%  with the diameter.  This is called from plot_cell
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Np = cylinder_num_pts(diam)


	if (diam >=6 )
		Np = 12;
	elseif (diam >= 5)
		Np = 10;
	elseif (diam >=4 )
		Np = 8;
	elseif (diam >= 3)
		Np = 6;
	elseif (diam >=2 )
		Np = 4;
	else
		Np = 3;
	end
	
%  	disp(sprintf('Diam=%.1f, Np=%d', diam, Np));