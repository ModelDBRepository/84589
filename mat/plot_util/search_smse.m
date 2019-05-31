%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  search_smse
%  
%  This function takes two waveforms (defined on the same sset of times) and
%  searches for the optimal (lowest MSE) alignment.  It performs a simple
%  (brute force) comparison of all the options given by a range of steps in
%  both time and the y axis.  The error returned is the square root of the 
%  mean square error.  The second return argument is the 2nd input trace
%  with the optimal time and Y offset applied, suitable for plotting in a
%  comparison with the first.  This is used both in compare_intra_trials and
%  compare_extra_trials.
%  
%  There is also an option to weight the peak: the "peak_weight_params" should
%  be a two element vector where the first is how much to weight the sample
%  with peak amplitude, and the second is a decay factor to reduce the weight
%  on neighboring points.  For example, peak_weight_parms of [10 0.5] would 
%  mean that the peak sample is weighted 10x, the two neighboring samples
%  are weighted 5x, the two samples two places from the peak are weighted 2.5x, 
%  and the two samples three places from the peak are weighted 1.25x.  The 
%  remaining samples would get a standard weight of 1x.  After weighting the
%  total MSE is renormalized.
%  
%  Note that this measure is actually asymmetric: the two traces start out
%  the same length.  Then the first trace is held fixed while the second is 
%  shifted in time.  When the second trace is shifted in time it is padded by
%  repeating its first/last element in order to keep the total length the 
%  same.  Consequently the result will be slightly different depending on 
%  which trace is held fixed and which is shifted.  (This is not a consequence
%  of the padding: even if more original data was provided for the shifted
%  trace the same asymmetry would exist.)  The solution to this (used in 
%  compare_intra_trials and compare_extra_trials) is simply to search the
%  error twice with the order reversed and average the htwo results.
%  
%  Also note that this is unsuitable for comparing SIMULTANEOUS intra-
%  and extracellular recordings as in Gold, Henze, Koch and Buzsaki (2006)
%  and this is not the method used there:  If the intra- and extra- recordings 
%  are _separately_ shifted in time to find two different optimal alignments
%  then the temporal relationship between the intra- and extracellular 
%  recordings is destroyed.  In order to preserve this information the
%  two waveforms must be shifted together and a single optimal temporal
%  alignment determined.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [smse, shifted_trace1] = search_smse(trace_1, trace_2,  trace_times, max_y_off, y_step, max_t_shift, peak_weight_params)


% set up the Y-shifts to use
y_shifts = [-max_y_off : y_step : max_y_off];
num_y_shifts = size(y_shifts,2);

% set up the T-shifts to use
tstep_size = trace_times(2)-trace_times(1);
max_tshift_steps = round(max_t_shift / tstep_size);
t_shifts = [-max_tshift_steps : max_tshift_steps];
num_t_shifts = size(t_shifts,2);

% space for the results
smses = zeros(num_t_shifts, num_y_shifts);
length_tcomp = size(trace_times,2);
compare_recs = zeros(num_t_shifts, num_y_shifts, length_tcomp);

% if we are using weighted mse...
samp_step = 1e-3*(trace_times(2)-trace_times(1));  % convert to seconds from msecs

if (~isempty(peak_weight_params))

	[na_peak na_peak_i] = min(trace_1);
	
	na_peak_weight = peak_weight_params(1);
	weight_decay = peak_weight_params(2);
	
	weights = zeros(1,length_tcomp);
	for n = 1 : length_tcomp
		weights(n) = max(na_peak_weight*(weight_decay^abs(n-na_peak_i) ) ,1);	
	end
else
	weights = ones(1,length_tcomp);
end

total_weight = sum(weights);

% Loop searching different waveform alignments...

for t = 1 : num_t_shifts
	for i = 1 : num_y_shifts
		
		compare_rec = zeros(1, length_tcomp);
		overlap = length_tcomp - abs(t_shifts(t));
		
		if (t_shifts(t) > 0)
			% shift it forwards
			compare_rec(t_shifts(t)+1:length_tcomp) = trace_1(1:length_tcomp-t_shifts(t));
			compare_rec(1:t_shifts(t)) = trace_1(1); % fill with the first value
		elseif (t_shifts(t) < 0)
			% shift it back
			abs_toff = abs(t_shifts(t));
			compare_rec(1:length_tcomp-abs_toff) = trace_1(abs_toff+1:length_tcomp);
			compare_rec(length_tcomp-abs_toff+1:length_tcomp) = trace_1(length_tcomp); % fill with the last value
		else
			compare_rec = trace_1;
		end
		
		compare_rec = compare_rec + y_shifts(i);
		
		compare_recs(t,i,1:length_tcomp) = compare_rec;
		
		smses(t,i) = sqrt((1/total_weight)*sum( weights.*((compare_rec - trace_2).^2)));
	end
end


[mins min_t_indices]=min(smses);
[min_smse min_y_shift_index]=min(mins);

min_t_shift_index = min_t_indices(min_y_shift_index);

min_y_shift = y_shifts(min_y_shift_index);
min_t_shift = t_shifts(min_t_shift_index);



% this seems to be necessary, or plot gets confused by the 3-D array
shifted_trace1 = zeros(size(trace_1));
shifted_trace1(1,:) = compare_recs(min_t_shift_index,min_y_shift_index,:);

smse = smses(min_t_shift_index, min_y_shift_index);