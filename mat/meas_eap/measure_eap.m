%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  measure_eap
%  
%  NOTE: uses fit() from the Matlab Curve Fitting Toolbox. 
%
%  Main routine for measuring the features of an EAP.  Paraameters
%  are two arrays of the voltages and times associated with them.
%  This will be called by higher level functions that plot or analyze
%  the measurements. Calls the following sub-routines: 
%  
%  define_measure_columns - defines the column number and a string name
%  for each of the measurements; shared by the high level routines
%  that plot or analyze these measurements.
%  
%  measure_waveform_width - the duration of the peak at 25 percent
%  of peak amplitude
%  
%  measure_eap_peaks - Measures the location and amplitude of Na+, K+ and 
%  capacitive peaks.
%  
%  measure_cap_rise_derivative - first derivative before the capacitive peak
%  
%  measure_k_phase_decay - fits an exponential decay starting at the K+ peak.
%  Requires the curve fitting toolbox!!!   Comment out this call if you do
%  not have the toolbox.
%  
%  measure_repol_derivs - measures the minimum and maximum first derivate
%  in between the Na+ peak and the K+ peak: discounts samples that are 
%  close to the K+ peak as the first derivative will go to zero there always;
%  it is the degree to which there is an inflection point that we are 
%  interested in.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function measures = measure_eap(ec_volts, ec_times)

% this file defines the column numbers & names for the measurements
define_measure_columns;

measures = zeros(1, NUM_STAT_COLS);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Width of the Na+ peak

nap_width = measure_waveform_width(ec_volts, ec_times);
measures( NAP_WIDTH_COL) = nap_width;  % convert this to ms


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the EC Peaks & Timing

[cap_peak, na_peak, k_peak, cap_peak_i, na_peak_i, k_peak_i] = measure_eap_peaks(ec_volts);


measures(CAP_PEAK_COL) = cap_peak;
measures(NA_PEAK_COL) = abs(na_peak);
measures(K_PEAK_COL) = k_peak;

measures(CAP_RATIO_COL) = cap_peak/abs(na_peak);
measures(K_RATIO_COL)   = k_peak/abs(na_peak);

measures(NA_K_TIME_COL) = ec_times(k_peak_i)-ec_times(na_peak_i); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rising Derivative to the capacitive peak

if (cap_peak > 0)
	measures(MAX_CAP_DERIV_COL) = measure_cap_rise_derivs(ec_volts, cap_peak_i, ec_times);
else
	measures(MAX_CAP_DERIV_COL) = 0;
end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get K peak decay time const...

 % set to if (0) to run without curve fitting toolbox
if (1)
	[exp_fit, decay_const] = measure_k_phase_decay(ec_volts, na_peak_i, k_peak_i, ec_times);
	measures(K_PHASE_EXP_COL) = exp_fit;
	measures(K_DECAY_COL) = decay_const;
else
	exp_fit = 0;
	decay_const = 0; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure Derivs in Repolarization... 

[max_deriv, min_deriv] = measure_repol_derivs(ec_volts, na_peak_i, k_peak_i, ec_times);


measures(MAX_REPOL_DERIV_COL) = max_deriv;
measures(MIN_REPOL_DERIV_COL) = min_deriv;






