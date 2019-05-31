%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  compare_extra_trials
%  
%  This script compares the extracellular potential from multiple trials at a 
%  specific point.  This produces figures similar to Figure 2 in Gold, Henze and Koch
%  (2007).  It generates the square root of the mean square error for each trial 
%  relative to the first trial in the list (so if you want to determine pair-wise 
%  errors for multiple trials you will need to run the script more than once with 
%  different trials in the first position on each run.) The comparison is done with 
%  the search_smse utility (in plot_util). Normalization is by the amplitude of the
%  smallest EAP in the group.
%
%  Note that the SMSE measure is not symmetric (as described in search_smse.m) 
%  so for each pair of EAP's the smse is calculated twice and the average is 
%  taken as the result.
%  
%  The parameters are:
%  -------------------
%  
%  cellName - the cell
%  
%  trial_nums - list of trial numbers to compare
%  
%  ec_loc - [x y z] for the point to compare at in micrometers
%  
%  xyMax - a 4 element array specifying the minimum and maxium X coordinates and Y 
%  coordinates; i.e. [xmin xmax ymin ymax] of the data file
%
%  sigma - the sigma with which the extracellular potentials was calculated
%  
%  grid_size - the grid on which the extracellular potentials were calculated
% 
%  peak_weight_params - define if and how the peak of the waveform is weighted
%  in the calculation.  See search_smse for explanation. Pass an empty array for
%  no weighting.
%  
%  Some important parameters are defined as constants in the top of the file:
%  these are the size of the time step to which the (non-uniform) data is 
%  interpolated (20,000 kHz), and the number and size of the steps with which
%  to attempt offseting the waveforms in calculating the minimum error between
%  them.
%
%  Note that the extracellular potential data is loaded using a file name made
%  from the Z value of the ec point, the sigma and the grid size.  Depending on
%  what were the xyMax in the calculation there is actually no guarantee that the
%  specified point is in that data.  If its not you will get an error and need
%  to either recalculate the extracellular data or choose a different point.
%  
%  Example Use:
%  ------------
%  compare_extra_trials('d151', [16 27 36], [0 20 0], [-100 100 -100 100], 0.3, 20, [])  -- no peak weighting
%  
%  compare_extra_trials('d151', [16 27 36], [0 20 0], [-100 100 -100 100], 0.3, 20, [10 0.5])  -- 10x peak weighting
%
%  compare_extra_trials('d151', [16 27 36], [0 20 0], [-100 100 -100 100], 0.3, 10, [10 0.5])  -- 10x peak weighting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function compare_extra_trials(cellName, trial_nums, ec_loc, xyMax, sigma, grid_size, peak_weight_params)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% constants

y_min = -.1;
y_max = .04;
ygrid_step = .01;

line_width = 1;
plot_clrs = {'k-';'b-'; 'r-';'m-'};

max_y_off = 0.2;
y_step = 0.005;
max_t_shift = 2;

before_after_peak_ratio = [.3 .7];
plot_length = 4;
time_before_ic_peak = 1;

interp_time_step = 0.05;

extra_pts = ec_loc(1:2);
Z = ec_loc(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Loading data for all cells

num_trials = length(trial_nums);

all_extra_volts = cell(1,num_trials);
all_extra_times = cell(1,num_trials);
all_se_indices = zeros(num_trials,2);

for c = 1 : num_trials

	trial = trial_nums(c);

	start_end = pick_start_end(cellName, trial, plot_length, time_before_ic_peak);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%
	% load the simulation data
	
	disp(sprintf('Loading data for %s.%d', cellName, trial));
	[Voltages, volt_pts, sim_times] = load_voltage_data_2d(cellName, trial, xyMax, Z, grid_size, start_end, sigma);
	
	[ec_volts ec_times] = get_voltage_trace(Voltages, volt_pts, sim_times, [], 1e-6*[extra_pts(1,:) Z]);

	all_extra_volts{c} = ec_volts;
	all_extra_times{c} = ec_times;
	
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the normalization constant


cand_norm_factors= [];
for c = 1 : num_trials
	a_norm_factor = abs(min(all_extra_volts{c}(:)));
	cand_norm_factors = [cand_norm_factors a_norm_factor];
end

% use the minimum amplitude as the normalization factor - to get the maximum error
norm_factor = min(cand_norm_factors);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate MSE... on each vs. the others

smses = zeros(num_trials,num_trials);
avg_smse = 0;

interp_times = [0 : interp_time_step : plot_length];

% only keeping the re-aligned waveforms vs. the 1st for the final plot
shifted_waveforms = cell(1,num_trials);

for i = 1 : num_trials
for j = 1 : num_trials

	if (i==j) continue; end

	mse_i_trace = all_extra_volts{i}(:);
	mse_i_times = all_extra_times{i}(:)-all_extra_times{i}(1);
	
	mse_j_trace = all_extra_volts{j}(:);
	mse_j_times = all_extra_times{j}(:)-all_extra_times{j}(1);
	
	% Interpolate the simulation to the recording times
	mse_i_interp = interp1(mse_i_times, mse_i_trace, interp_times,'linear','extrap');
	mse_j_interp = interp1(mse_j_times, mse_j_trace, interp_times,'linear','extrap');

	% find the optimal  SMSE	
	disp(sprintf('Searching alignments... %d vs %d',j,i));
	[smse_ij, shifted_i_interp] = search_smse(mse_i_interp, mse_j_interp, interp_times, max_y_off, y_step, max_t_shift, peak_weight_params);
	disp(sprintf('\tNormalized Error = %.2f %%', 100*(1/norm_factor)*smse_ij));
	
	if (j==1)
		shifted_waveforms{1} = mse_j_interp;
		shifted_waveforms{i} = shifted_i_interp;
	end
		
	smses(i,j) = smse_ij;
	avg_smse = avg_smse + smse_ij;
end
end

%  smses
nsmses = 100*(1/norm_factor)*smses;

avg_smse = 100*(1/norm_factor)*avg_smse / (num_trials^2-num_trials);  % skipped diagnoals, so n*(n-1) errors


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% plot it


figure(get_next_fig);
hold on;
for c = 1 : num_trials

	ph = plot(interp_times, shifted_waveforms{c}, char(plot_clrs(c)));
	set(ph,'LineWidth',line_width);
end
hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add labels etc.

if (~isempty(peak_weight_params))
	peak_weight_string = sprintf('(peak-wt %d/%.1f)', peak_weight_params(1), peak_weight_params(2));
else
	peak_weight_string = '';
end

title(sprintf('Comparison of EAPs %s @(%d,%d,%d) %s, Avg NSMSE=%.2f%%', cellName, extra_pts(1), extra_pts(2), Z, peak_weight_string, avg_smse));

xlabel('ms');
ylabel('mV');
set(gca,'YTick', [y_min : ygrid_step : y_max]);
grid on;

axis([0 plot_length y_min y_max ]);

legend_strings = cell(num_trials, 1);

for i = 1 : num_trials
	err_string = '';
	for j = 1 : num_trials
		if (i==j) continue; end
		err_string = strcat(err_string, sprintf(' %d=%.2f%%, ',trial_nums(j),nsmses(i,j)));
	end

	legend_strings(i) = cellstr(strrep(sprintf('%d Errs: %s', trial_nums(i),  err_string),'_','-') );
end


legend(legend_strings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save as fig file

if (~exist(make_file_name(cellName, trial_nums(1), 'mout', [], {}) , 'dir'))
	status = mkdir(make_file_name(cellName, trial_nums(1), 'pout'), 'mat');
end

save_types = {'fig';'epsc'};

trials_string = sprintf('%s', cellName);

for c = 1 : num_trials
	trials_string = strcat(trials_string, sprintf('-%d', trial_nums(c)));
end

for s = 1 : length(save_types)

	fileName = make_file_name(cellName, trial_nums(1), 'eapc', [sigma ec_loc ], {trials_string; char(save_types(s))});
	
	saveas(gcf, fileName, char(save_types(s)));

end



