%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot_meas_compare
%  
%  NOTE: Uses boxplot from the Matlab Statistics Toolbox & fit() from 
%   the Matlab Curve Fitting Toolbox
%  
%  Makes plots illustrating the statistics for a set of eap measures.  Calls
%  measure_eap to actually do the measurements, concatenating them into
%  arrays suitable for passing to box_plot.  boxplot() actually calculates
%  the statisics and makes the plots.
%  
%  cellName - the cell to plot for
%  
%  trials - the trial #s ; normally call this with multiple trial #'s and
%           the plot will be a comparison of the results
%  
%  sigma - the extracellular conductivity to use for the calculation
%  
%  xyMax - a 4 element array specifying the minimum and maxium X coordinates and Y 
%  coordinates; i.e. [xmin xmax ymin ymax]
%
%  Z - the Z values to calculated for
%  
%  grid_size - the grid size calculated for
%  
%  amp_thresh - the minimum threshold amplitude to include points in the 
%  statistics
%  
%  Sample usage:
%   plot_meas_compare('d151', [27 36 16 58], 0.3, [-50 50 -50 50], 0, 10, 0.04); 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_meas_compare(cellName, trials, sigma, xyMax, Z, grid_size, amp_thresh)
 
 
n_trials = length(trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants

%  column numbers & names for the measurements
define_measure_columns;

x_label_letters = {'A';'B';'C';'D';'E';'F'};
do_notch = 1;

make_plot_stats = [CAP_RATIO_COL MAX_CAP_DERIV_COL K_RATIO_COL NAP_WIDTH_COL   K_DECAY_COL  MIN_REPOL_DERIV_COL];

calc_length = 4;
time_before_ic_peak = 1;

save_types = {'eps'};
trials_string = sprintf('%s', cellName);

for c = 1 : n_trials
	trials_string = strcat(trials_string, sprintf('-%d', trials(c)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over trials, gathering the numbers

all_trial_measures = cell(1,n_trials);

for t = 1 : n_trials

	disp(sprintf('Calculating Measures for %s.%d', cellName, trials(t)));

	[start_end_times, start_end_indices] = pick_start_end(cellName, trials(t), calc_length, time_before_ic_peak);
	[Voltages, volt_pts, volt_times] = load_voltage_data_2d(cellName, trials(t), xyMax, Z, grid_size, start_end_times, sigma);

	all_eap_measures = [];
	
	for p = 1 : size(Voltages,1)
		% (0,0,0) is really in the soma, so skip it
		if (volt_pts(p,1)*1e6 == 0 & volt_pts(p,2)*1e6 == 0 & volt_pts(p,2)*1e6 == 0) continue; end
			
		measures = measure_eap(Voltages(p,:), volt_times );
	
		if (abs(measures(NA_PEAK_COL)) > amp_thresh)
			all_eap_measures = [all_eap_measures; measures];
		end
	end
	
	all_trial_measures{t}=all_eap_measures;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over stats, making the plots

	
for s = 1 : length(make_plot_stats)
	
	figure(get_next_fig);

	X = [];
	G = [];
	for t = 1 : n_trials
		X = [X; all_trial_measures{t}(:,make_plot_stats(s))];
		G = [G; t*ones(size(all_trial_measures{t}(:,make_plot_stats(s)))) ];
	end
	
	boxplot(X,G,do_notch);
	
	set(gca, 'XTickLabel', x_label_letters(1:n_trials));
	set(gca, 'YGrid', 'on');
	title(sprintf('%s %s', cellName, char(column_names(make_plot_stats(s)))));

	for n = 1 : length(save_types)
	
		fileName = make_file_name(cellName, trials(1), 'mscp', [], {char(column_abrevs(make_plot_stats(s))) trials_string char(save_types(n))} );
		
		saveas(gcf, fileName, char(save_types(n)));
	
	end
end



