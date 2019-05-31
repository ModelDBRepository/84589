%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_detail_xs
%  
%  Returns a list of 'x' values for compartments corresponding to a description, 
%  for a given cell.  This is used by the plotting function plot_intra_detail in
%  conjunction with get_detail_secs which provides the compartment names. i.e.
%  each number in these arrays corresponds to an element in the cell array of
%  strings returned by get_detail_secs and together they define the name
%  of one of the compartments for which details have been exported from NEURON.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_xs = get_detail_xs(cellName, plot_desc)

plot_xs = [];

if  (strcmp(cellName, 'd151')==1)

	if (strcmp(plot_desc,'basal')==1)
		plot_xs = [ 0.5 0.5 0.5 0.17 0.83];
		
	elseif (strcmp(plot_desc,'approx')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5];
		
	elseif (strcmp(plot_desc,'apdist')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5];

	elseif (strcmp(plot_desc, 'axon')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5 0.5];
	end
	
elseif (strcmp(cellName, 'line')==1)
    
	if (strcmp(plot_desc,'all')==1)
        plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 ];
	elseif (strcmp(plot_desc,'approx')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5];
	elseif (strcmp(plot_desc,'apdist')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5];
	elseif (strcmp(plot_desc,'baprox')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5];
	elseif (strcmp(plot_desc,'badist')==1)
		plot_xs = [0.5 0.5 0.5 0.5 0.5 0.5];
    end
    
else
	plot_xs = [0.5];
end

