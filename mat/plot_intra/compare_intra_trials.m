%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  compare_intra_trials
%  
%  This script compares the intracellular membrane potential from multiple trials in a 
%  specific compartment.  This produces figures similar to Figure 2 in Gold, Henze and 
%  Koch (2007).  It generates the normalized square root of the mean square error for each 
%  trial  relative to the first trial in the list (so if you want to determine pair-wise 
%  errors for multiple trials you will need to run the script more than once with 
%  different trials in the first position on each run.) The comparison is done with 
%  the search_smse utility (in plot_util).  Normalization is by the amplitude of the
%  smallest potential in the group.
%  
%  Note that the SMSE measure is not symmetric (as described in search_smse.m) 
%  so for each pair of membrane potentials the smse is calculated twice and the 
%  average is taken as the result.
%  
%  The parameters are:
%  -------------------
%  
%  cellName - the cell
%  
%  trial_nums - list of trial numbers to compare (>2 trials is fine)
%  
%  sec_name - the name of the section to comapre
%  
%  sec_x - the neuron 'x' value for the compartment within the section
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
%  Note that the section for comparison must be one for which full details were
%  exported from the NEURON program.  See the file hoc/src/current_util.hoc for
%  details.
%  
%  Example Use:
%  ------------
%  compare_intra_trials('d151', [16 27 36], 'soma', 0.5, [10 0.5])  -- weighting the peak 10x
%
%  compare_intra_trials('d151', [16 27 36], 'soma', 0.5, [])  -- no peak weighting
%
%  compare_intra_trials('d151', [16 27 36], 'apical1_0222', 0.5, [10 0.5])  -- weighting the peak 10x
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function compare_intra_trials(cellName, trial_nums, sec_name, sec_x, peak_weight_params)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% constants

y_min = -75;
y_max = 25;

line_width = 1;
plot_clrs = {'k-';'b-'; 'r-';'m-'};

max_y_off = 10;
y_step = 0.1;
max_t_shift = 2;

interp_time_step = 0.05;

plot_length = 4;
time_before_ic_peak = 1;

save_types = {'epsc'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Loading data for all cells

num_trials = length(trial_nums);

all_intra_data = cell(1,num_trials);
all_intra_times = cell(1,num_trials);
all_se_indices = zeros(num_trials,2);

for c = 1 : num_trials

	trial = trial_nums(c);

	disp(sprintf('Loading data for %s.%d  %s', char(cellName), trial, sec_name));
	
	%%%%%%%%%%%%%%%%%%%%%%%%%
	% load the simulation data
	
	sim_times = load(make_file_name(cellName, trial, 'time'))';
	all_sim_times{c} = sim_times;
	
	sim_data = load(make_file_name(cellName, trial, 'dtls', sec_x, {sec_name}));
	sim_volts = sim_data(:,find_detail_column(cellName, trial, 'V'))';
	all_sim_volts{c} = sim_volts;

	[start_end se_indices] = pick_start_end(cellName, trial, plot_length, time_before_ic_peak, sec_name, sec_x);
	all_se_indices(c,:) = se_indices;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the normalization constant


cand_norm_factors= [];
for c = 1 : num_trials
	a_norm_factor = max(all_sim_volts{c}(:)) - all_sim_volts{c}(1);
	cand_norm_factors = [cand_norm_factors a_norm_factor];
end

% use the minimum amplitude as the normalization factor - to get the maximum error
norm_factor = min(cand_norm_factors);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate MSE... on each vs. the first.

smses = zeros(1,num_trials);
avg_smse = 0;

interp_times = [0 : interp_time_step : plot_length];

shifted_waveforms = cell(1,num_trials);

for i = 1 : num_trials
for j = 1 : num_trials

	if (i==j) continue; end
	
	mse_i_trace = all_sim_volts{i}(all_se_indices(i,1):all_se_indices(i,2));
	mse_i_times = all_sim_times{i}(all_se_indices(i,1):all_se_indices(i,2))-all_sim_times{i}(all_se_indices(i,1));
	
	mse_j_trace = all_sim_volts{j}(all_se_indices(j,1):all_se_indices(j,2));
	mse_j_times = all_sim_times{j}(all_se_indices(j,1):all_se_indices(j,2))-all_sim_times{j}(all_se_indices(j,1));
	
	% Interpolate the simulation to the recording times
	mse_i_interp = interp1(mse_i_times, mse_i_trace, interp_times,'linear','extrap');
	mse_j_interp = interp1(mse_j_times, mse_j_trace, interp_times,'linear','extrap');
	
	disp(sprintf('Searching alignments... %d vs %d',j,i));
	[smse_ij, shifted_i_interp] = search_smse(mse_i_interp , mse_j_interp, interp_times,  max_y_off, y_step, max_t_shift, peak_weight_params);
	disp(sprintf('\tNormalized Error = %.2f %%', 100*(1/norm_factor)*smse_ij));
	

	if (j==1)
		shifted_waveforms{1} = mse_j_interp;
		shifted_waveforms{i} = shifted_i_interp;
	end
	
	smses(i,j) = smse_ij;
	avg_smse = avg_smse + smse_ij;
end
end

nsmses = 100*(1/norm_factor)*smses;
avg_smse = 100*(1/norm_factor)*avg_smse / (num_trials^2-num_trials);  % skipped diagnoals, so n*(n-1) errors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% plot the intra-cellular recording data


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

title(sprintf('Comparison of %s IAPs @ %s(%.2f) %s, Avg NSMSE=%.2f%%', cellName, sec_name,sec_x, peak_weight_string, avg_smse));

xlabel('ms');
ylabel('mV');
grid on;

axis([0 plot_length y_min y_max ]);

legend_strings = cell(num_trials, 1);

for i = 1 : num_trials
	err_string = '';
	for j = 1 : num_trials
		if (i==j) continue; end
		err_string = strcat(err_string, sprintf(' %d=%.2f%%, ',trial_nums(j),nsmses(i,j)));
	end
	
	legend_strings(i) = cellstr(strrep(sprintf('%d Err: %s', trial_nums(i), err_string),'_','-') );
end


legend(legend_strings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the figure

if (~exist(make_file_name(cellName, trial_nums(1), 'mout', [], {}) , 'dir'))
	status = mkdir(make_file_name(cellName, trial_nums(1), 'pout'), 'mat');
end

trials_string = sprintf('%s', cellName);

for c = 1 : num_trials
	trials_string = strcat(trials_string, sprintf('-%d', trial_nums(c)));
end

for s = 1 : length(save_types)
	
	fileName = make_file_name(cellName, trial_nums(1), 'iapc', [], {sec_name; trials_string; char(save_types(s))});
	saveas(gcf, fileName, char(save_types(s)));

end



