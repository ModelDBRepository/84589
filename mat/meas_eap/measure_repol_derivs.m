%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% measure_repol_derivs
%
%  Calculates the (approximate) first derivative for points in between the Na+
%  peak and the K+ peak.  The first sample after the Na+ peak and the last 1/3
%  of the samples in betwee the peaks are skipped - the derivative will go to
%  zero at the K+ peak, but we're not interested in that.  Its really looking
%  for evidence of an inflection point in the middle and not about the end.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [max_deriv, min_deriv] = measure_repol_derivs(ec_volts, na_peak_i, k_peak_i, times)

	% for measuring the derivatives after the Na+ peak and before the K+ peak
	napeak_noderiv_samps_num = 1;
	kpeak_noderiv_samps_ratio = 0.33;  % don't consider derivates within N samps of K+ peak

	first_deriv_samp = na_peak_i+ napeak_noderiv_samps_num;
	last_deriv_samp = round(na_peak_i + (k_peak_i-na_peak_i)*(1-kpeak_noderiv_samps_ratio));
	
	% disp(sprintf('\tFirst Deriv Samp = %d (%f), Last Deriv Samp = %d (%f)', first_deriv_samp, (first_deriv_samp * samp_step*1e3), last_deriv_samp, (last_deriv_samp*samp_step*1e3) ));
	
	min_deriv = 1e10;
	max_deriv = -1e10;
	min_deriv_samp = 0;
	max_deriv_samp = 0;
	
	for s = first_deriv_samp : last_deriv_samp
		delta_v = ec_volts(s)-ec_volts(s-1);
		delta_t =  times(s)-times(s-1);  % should already be in ms
		deriv = delta_v / delta_t;  % using ms and mV for deriv
		if (deriv < min_deriv)
			min_deriv = deriv;
			min_deriv_samp = s;
		end
		if (deriv > max_deriv)
			max_deriv = deriv;
			max_deriv_samp = s;
		end
	end
	
	
	% disp(sprintf('\tMax Deriv=%f @ t=%f,   Min Deriv=%f @ t=%f', max_deriv, max_deriv_samp*samp_step*1e3, min_deriv, min_deriv_samp*samp_step*1e3));