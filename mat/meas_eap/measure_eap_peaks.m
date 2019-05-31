%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  measure_eap_peaks
%
%  Returns the peak amplitude associated with (positive) capacitive current,
%  (negative) Na+ current, and (positive) K+ current.  The Na+ peak is defined
%  as the minimum point of the waveform.  The capacitive and K+ peaks are
%  defined as the maximum before and after the Na+ peak respectively.
%  The capacitive and K+ peaks are offset by the minimum voltage preceeding
%  the capacitive peak (not necessarily the first sample) to better measure
%  the apparent rise in cases where the waveform is decreasing before the 
%  start of the capacitive peak.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cap_peak, na_peak, k_peak, cap_peak_i, na_peak_i, k_peak_i] = measure_eap_peaks(ec_volts)


	num_samples = max(size(ec_volts));

	[na_peak na_peak_i] = min(ec_volts);
	
	pre_peak_samps = ec_volts(1:na_peak_i-1);
	post_peak_samps = ec_volts(na_peak_i+1:end);
	
	[cap_peak cap_peak_i] = max(pre_peak_samps);
	
	if (length(post_peak_samps> 0))
		[k_peak k_peak_i] = max(post_peak_samps);
	else
		k_peak = 0;
		k_peak_i = 0;
	end
	
	% subtract off the minimum pre-cap voltage from the capactive peak measure
	pre_cap_samps = ec_volts(1:cap_peak_i);
	pre_cap_min = min(pre_cap_samps);
	cap_peak = cap_peak - pre_cap_min;
	k_peak = k_peak - pre_cap_min;
	
	
	
	% don't count a "negative" capactive peak as anything - its not a peak
	if (cap_peak <= 0)
		cap_peak = 0;
	end
	
	% fix the index to refer back to the full list
	k_peak_i = k_peak_i + na_peak_i;
	