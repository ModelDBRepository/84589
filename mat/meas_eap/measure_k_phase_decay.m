%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% measure_k_phase_decay
%
%  Fits an exponential function to the voltages beginning at the peak associated
%  with the K+ current.  If there is no clearly defined K+ peak it will instead
%  fit the same function to the portion of the waveform starting from 1/3 of the
%  way in between the Na+ peak and the end of the waveform, resulting in a positive
%  exponential (negative time constant.)  The criteria for decay is that starting
%  from the sample of the K+ peak (which is passed in as a parameter) the following
%  voltage should 1) decay 2) the decay should conssit of at least 3 sample points.
%  If there is decay then we stop fitting when it has decayed to 5 percent of the K+
%  peak.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [exp_fit, decay_const] = measure_k_phase_decay(ec_volts, na_peak_samp, k_peak_samp, times)

	% the portion to measure, after the Na+ peak, assuming there is no "peak" in the K+
	no_decay_skip_samps_ratio = 0.66;

	% look for the first point that is less than 5% the peak amplitude
	decay_thresh = 0.05;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% loop over samples after K+ peak and look for the minimum down to the threshold
	
	minkdec = ec_volts(k_peak_samp);
	minkdec_samp = k_peak_samp;
	
	for s = k_peak_samp : length(ec_volts)
		if (ec_volts(s) < minkdec)
			minkdec = ec_volts(s);
			minkdec_samp = s;
		end
		
		if (minkdec < decay_thresh*ec_volts(k_peak_samp)) break; end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% If there is some decay to measure, measure that...
	if (minkdec < ec_volts(k_peak_samp) & minkdec_samp-k_peak_samp > 3 )	
		kdecay_samps = k_peak_samp : minkdec_samp;
		
		% offset voltages so it _ends_ at zero
		fit_volts = 1e-3*(ec_volts(kdecay_samps)- ec_volts(minkdec_samp));  % converting to volts, not mV
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% or else just fit the curve to 2/3 of the way from the Na+ peak to the end...
	else
		total_samps = length(ec_volts);
		first_fit_samp = na_peak_samp + round((total_samps-na_peak_samp)*no_decay_skip_samps_ratio);
		kdecay_samps = first_fit_samp : total_samps;
		
		% offset voltages so it _starts_ at zero
		fit_volts = 1e-3*(ec_volts(kdecay_samps)- ec_volts(first_fit_samp));  % converting to volts, not mV
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Call the fitting function
	
	% this is the same whether its decaying or not...
	fit_times = times(kdecay_samps)*1e-3;				% convert to ms from seconds

	if (length(fit_times) > 2)
		fresult_exp = fit(fit_times', fit_volts', 'exp1');	% apparently fit wants column vectors for the data...
		
		
		% convert it to a decay constant in ms
		decay_const = (-1/fresult_exp.b)*1e3;  % convert time const back to ms
	
		% for consistency with a time const in ms, multiply by 1e-3
		exp_fit = (fresult_exp.b)*1e-3;			
	else
		exp_fit = nan;
		decay_const = nan;
	end
