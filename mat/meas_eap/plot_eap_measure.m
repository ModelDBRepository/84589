%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot_eap_measure
% 
% Plots the eap at a given point and prints the measurements in the axes.
%  Parameters define the grid of EAP data to load, and which point to plot.
%
%  cellName - the cell to plot for
%  
%  trial - the trial # ; this can be left blank and the program will determine
%  the last trial and use that
%  
%  start_end_times - the (approximate) beginning and ending times to calculate for;
%  if this is left blank the program will pick times that begin 1 ms before the 
%  somatic peak membrane potential and ending 3 ms after.
%  
%  meas_loc - The point to plot/measure
%
%  sigma - the extracellular conductivity to use for the calculation
%  
%  xyMax - a 4 element array specifying the minimum and maxium X coordinates and Y 
%  coordinates; i.e. [xmin xmax ymin ymax] of the data file
%
%  
% Sample usage:
% plot_eap_measure('d151', [], [], [0 20 0], [-100 100 -100 100], 0.3, 20)
%
% plot_eap_measure('d151', 27, [], [0 20 0], [-100 100 -100 100], 0.3, 20)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_eap_measure(cellName, trial, start_end_times, meas_loc,  xyMax, sigma, grid_size)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default trial number if necessary

if (isempty(trial))
	trial = get_last_trial_num(cellName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pick/Check the start/end times for calculation

if (isempty(start_end_times))
	calc_length = 4;
	time_before_ic_peak = 1;
	[start_end_times, start_end_indices] = pick_start_end(cellName, trial, calc_length, time_before_ic_peak);
else
	all_times = load(make_file_name(cellName, trial, 'time'))';  %'
	[start_end_times, start_end_indices] = check_start_end(all_times, start_end_times);
end


% the file will be saved to this type
save_types ={'eps'};

% where to put the y axis grid  lines
y_ticks = [-.1:.02:.04];

% this file defines the column numbers & names for the measurements
define_measure_columns;

measures = zeros(1, NUM_STAT_COLS);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD _EX_TRACELLULAR DATA

disp(sprintf('Calculating Simulation measures for %s.%d... w/ EC Loc= (%d,%d,%d) ', cellName, trial, meas_loc(1,1), meas_loc(1,2), meas_loc(1,3)));

[Voltages, volt_pts, sim_times] = load_voltage_data_2d(cellName, trial, xyMax, meas_loc(3), grid_size, start_end_times, sigma);

[ec_volts ec_times] = get_voltage_trace(Voltages, volt_pts, sim_times, [], 1e-6*meas_loc(:));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call the measurement function

measures = measure_eap(ec_volts, ec_times );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the EAP


figure(get_next_fig);
plot(ec_times, ec_volts,'bo-');
title(sprintf('EAP %s.%d @ (%d,%d,%d)', cellName, trial, meas_loc(1,1), meas_loc(1,2), meas_loc(1,3)));
grid on;
set(gca,'YTick',y_ticks);
ylim = get(gca, 'YLim');

% write out the measures  in the figure
string_x = ec_times(1) + (ec_times(end)-ec_times(1))*0.66;
string_y = ylim(2)*.5;
y_step = (ylim(2)-ylim(1))/20;

for s = NA_PEAK_COL : MIN_REPOL_DERIV_COL
	plot_string = sprintf('%s = %.4f', char(column_names(s)), measures(s));
	text(string_x, string_y ,plot_string);
	string_y = string_y - y_step;
end

%%%%%%%%%%%%%%%
% Save as fig

for s = 1 : size(save_types,1)
	
	fileName = make_file_name(cellName, trial, 'eapm', [sigma meas_loc ], {char(save_types(s))});	
	saveas(gcf, fileName, char(save_types(s)));
end





