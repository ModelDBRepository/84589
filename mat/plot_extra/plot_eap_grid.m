%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot_eap_grid
%  
%  This script produces a 2D plot of a cell and the extraceullar action potentials 
%  in a plane around the cell, similar to figures 1-3 in Gold, Henze, Koch and Buzsaki 
%  (2006) and figures 3-6 in Gold, Henze and Koch (2007).  It assumes that these voltages
%  have already been previously calculated with zplane_eap_calc.  The cell is plotted with 
%  the plot_cell_flat procedure and the waveform for each point is plotted in a separate
%  axis and the rescaled and moved to the correct position on the main axis.  The
%  parameters given the script are the same parameters as are given to zplane_eap_calc.
%  Some additional constant parameters (of the plot) are defined in the top of the file.
%  The script will also save the plot to one or more files with types given by the
%  save_types variable (in the top of the script; use an empty cell array for no save.)
%  
%  One small note: the script assumes the soma is centered at (0,0,0) and does not
%  plot data for that point.  If you are using a cell where the soma is not at (0,0,0)
%  you may want to alter this (in the main loop, below.)
%
%  Example Use
%  ------------
%
%  plot_eap_grid('d151', [], [], 0.3, [-100 100 -100 100], 0, 20);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_eap_grid(cellName, trial, start_end_times, sigma, xyMax, Z, gridSize)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constant Parameters used in  plotting

% this is helpful for the line simulation
%  voltageScales = [0.001 0.002 0.004 0.008 0.012];

% good for a CA1 pyramidal cell
voltageScales = [0.01 0.02 0.04 0.08  0.16];

voltageColors = {'b'; 'g'; 'y'; 'm'; 'r'};

xgrid_plot_pcnt = .8;
track_color = 'w';
eap_line_width = 1;
volt_text_size = .015;

save_types = {'epsc'};		% use empty cell array for no save

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default the trial number if necessary

if (isempty(trial))
	trial = get_last_trial_num(cellName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Voltage Data & Check Times


disp('loading voltages...');

% load the times, and check the request start/end against them
sim_times = load(make_file_name(cellName, trial, 'time'))'; 

if (isempty(start_end_times))
	calc_length = 4;
	time_before_ic_peak = 1;
	[start_end_times start_end_indices] = pick_start_end(cellName, trial, calc_length, time_before_ic_peak);
else
	[start_end_times start_end_indices] = check_start_end(sim_times, start_end_times);
end

[Voltages, volt_pts, volt_times] = load_voltage_data_2d(cellName, trial, xyMax, Z, gridSize, start_end_times, sigma);
plot_times = sim_times(start_end_indices(1):start_end_indices(2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the cell geometry 

disp('Loading cell geometry...');
[start_segs end_segs start_diams end_diams] = get_neuron_geom(cellName, trial);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make list of all point coordinates

disp('making pts...');

% for calculation, we want to convert these from micro-meters to meters
pt_coord = make_2D_pt_coords(xyMax, Z, gridSize)*1e-6;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the main axes

main_fig_h = figure(get_next_fig);
main_ax_h = axes;

% adding some extra room to the xyMax
axis(main_ax_h, [xyMax(1) - gridSize  xyMax(2) + gridSize xyMax(3) - gridSize xyMax(4) + gridSize]);
hold on;

set(main_ax_h, 'XTickMode', 'manual');
set(main_ax_h, 'YTickMode', 'manual');
set(main_ax_h, 'Color', [.5 .5 .5]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the cell 

disp('Plotting cell...');

flatten_cell = 1;
plot_cell(start_segs, end_segs, start_diams, end_diams, xyMax, main_ax_h, flatten_cell);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Each Plot

disp('Plotting Waveforms...');

scrap_fignum = get_next_fig;

for plotNum = 1 : size(pt_coord,1)

	fig_h = figure(scrap_fignum);
	

	% if its (0,0,0) its in the soma and not a real point - skip it
	% (this may or may not be Nan depending on exactly where the soma 3D points lie,
	%  but it almost certainly lies within the soma in which case the LSA is not
	% valid)
	
	if (pt_coord(plotNum,1)==0 & pt_coord(plotNum,2) ==0 & pt_coord(plotNum,3) == 0) continue; end
	
	[volt_trace, plot_times] = get_voltage_trace(Voltages, volt_pts, volt_times, start_end_times, pt_coord(plotNum,:));
	
	% check this in case the pt was on a line in the calculation
	if (any(volt_trace)== NaN)  continue; end
	
	[ymin ymax clr] = voltage_plot_scale(volt_trace, voltageScales, voltageColors);
		
	line_hs = plot(plot_times, volt_trace, clr);
	
	for i = 1 : size(line_hs,1)
	
		y_rescale = gridSize/(ymax-ymin);
		x_rescale = (gridSize/(start_end_times(2) - start_end_times(1)))*xgrid_plot_pcnt;
	
		orig_xs = get(line_hs(i), 'XData');
		orig_ys = get(line_hs(i), 'YData');
		
		new_xs = (orig_xs * x_rescale) + pt_coord(plotNum, 1)*1e6 - start_end_times(1)*x_rescale - gridSize/2;
		new_ys = (orig_ys * y_rescale) + pt_coord(plotNum, 2)*1e6;
		
		set(line_hs(i), 'XData', new_xs);
		set(line_hs(i), 'YData', new_ys);
		set(line_hs(i), 'LineWidth', eap_line_width);
		
		% Move the Line to the Main Axes...
		set(line_hs(i), 'Parent', main_ax_h);
	end

end

close(fig_h);

% reset to work on the main figure...
figure(main_fig_h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set ticks and title

disp('Adding Ticks and Title');

set(main_ax_h, 'XTick', [xyMax(1) : gridSize : xyMax(2)]);
set(main_ax_h, 'YTick', [xyMax(3) : gridSize : xyMax(4)]);

title(sprintf('Cell=%s.%d, Z=%.0f, sig=%.2f',cellName,trial, Z, sigma), 'Interpreter', 'none');

xlabel('\mu m');
ylabel('\mu m');
set(gca, 'DataAspectRatio',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Time Scale explanation

time_line_h = line([xyMax(1)-gridSize/2 xyMax(1)+gridSize*xgrid_plot_pcnt-gridSize/2], ...
					[xyMax(3)-gridSize/4 xyMax(3)-gridSize/4], ...
					'Color', 'w');

time_text_h = text(xyMax(1)-gridSize/2, xyMax(3)-gridSize/2, ...
					sprintf(' %.2f ms', start_end_times(2)-start_end_times(1)), 'Color', 'w', 'FontUnits', 'normalized', 'FontSize', .025);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Voltage Scale explanation

disp('Adding scale bars...');

% choose a spacing for the voltage scale text

xGrid = [xyMax(1) : gridSize: xyMax(2)];	% how many x pts did we make?

textGrid = floor(length(xGrid)/length(voltageScales));

for i = 1 : length(voltageScales)


	if (length(voltageScales)>2)

		volt_line_h = line([xyMax(1)-gridSize/4 + gridSize*i*textGrid  xyMax(1)-gridSize/4 + gridSize*i*textGrid ],...
							[xyMax(3)-3*gridSize/4 xyMax(3)-gridSize/4], ...
							'Color', char(voltageColors(i)));

		volt_text_h = text(xyMax(1) + gridSize*i*textGrid, xyMax(3)-gridSize/2, strcat(sprintf('=%.1f', ....
							1000*voltageScales(i)), ' \mu V'), 'Color', char(voltageColors(i)), 'FontUnits', 'normalized', 'FontSize', volt_text_size, 'Interpreter','tex');
	else
		x_line = [xyMax(1)-gridSize/4 + gridSize*i*textGrid/2   ...
							 xyMax(1)-gridSize/4 + gridSize*i*textGrid/2  ];
							 
		y_line =   [xyMax(3)-3*gridSize/4  xyMax(3)-gridSize/4];
		x_text = xyMax(1) + gridSize*i*textGrid/2;
		y_text = xyMax(3)-gridSize/2;
	

		volt_line_h = line(x_line, y_line, 'Color', char(voltageColors(i)));
		volt_text_h = text(x_text, y_text, sprintf('=%.1f \muV', 1000*voltageScales(i)), 'Color', ...
							'b', 'FontUnits', 'normalized', 'FontSize', .025);
	end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Figure as File

if (~exist(make_file_name(cellName, trial, 'mout', [], {}) , 'dir'))
	status = mkdir(make_file_name(cellName, trial, 'pout'), 'mat');
end

for s = 1 : length(save_types)

	save_file = make_file_name(cellName, trial, 'eapg', [Z gridSize sigma], {char(save_types(s))});
	saveas(gcf, save_file, char(save_types(s)));
	
	
end








