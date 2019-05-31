%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  plot_cell_labels
%  
%  Makes a flat plot of the cell and labels all of the sections.  This can be 
%  useful if you want to pick detailed sections to export from NEURON: because
%  a neuron geometry file can be hard to interpret it can help to see it all
%  laid out.
%  
%  Note that you must have already simulated the file in NEURON and generated
%  the geom.dat file in order to use this - so you need to specify a trial number
%  even though the geometry of the cell presumably will not change from trial
%  to trial.
% 
%  Parmeters
%  -----------
%  cellName - the cell
%  
%  trial - the trial number
%  
%  plotMax - the maximum X & Y axes (in micrometers) to use for the plot
%
%
%  Example Use:
%  ------------
%
%  plot_cell_labels('d151',[],[-400 200 -200 200])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_cell_labels(cellName, trial, plotMax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Settings

save_types = {'epsc'};

if (isempty(trial))
	trial = get_last_trial_num(cellName);
end

if (isempty(plotMax))
	plotMax = [-100 100 -100 100];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the geometry

disp('Loading cell geometry...');
[start_lines end_lines start_diams end_diams ] = get_neuron_geom(cellName, trial);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the main axes

main_fig_h = figure(get_next_fig);
main_ax_h = axes;
axis(main_ax_h, [plotMax(1)  plotMax(2) plotMax(3) plotMax(4)]);
hold on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the cell

flatten_cell = 1;
plot_cell(start_lines, end_lines, start_diams, end_diams, plotMax, main_ax_h, flatten_cell);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Segment Names & Data

sec_names = textread(make_file_name(cellName, trial, 'snam'), '%s');
sec_nums = load(make_file_name(cellName, trial, 'snum'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the names to the plot

num_secs = size(sec_names, 1);

% remember - names & nums include the soma, but the geometry doesnt 

for i = 1 : size(sec_names,1)

	if (i > 1)
		sec_mid_row = floor(sec_nums(i,1) + sec_nums(i,2)*.5) - 1;
		x_loc =  start_lines(sec_mid_row, 1)*1e6;
		y_loc =  start_lines(sec_mid_row, 2)*1e6;
	else
		x_loc = 0;
		y_loc = 0;
	end

	if (x_loc < plotMax(1) | x_loc > plotMax(2) | y_loc < plotMax(3) | y_loc > plotMax(4))
		continue;
	end

	% disp(sprintf('Texting %s', char(sec_names(i))  ));
	
	text(x_loc, y_loc, sec_names(i), 'Color', 'r', 'FontUnits', 'normalized', 'FontSize', .02, 'Interpreter', 'none');


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save in fig or postscript


for s = 1 : length(save_types)

	save_file = make_file_name(cellName, trial, 'clab', [], {char(save_types(s))});
	saveas(gcf, save_file, char(save_types(s)));
	
	
end


