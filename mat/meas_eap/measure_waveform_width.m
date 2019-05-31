%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% measure_waveform_width
%
%  For a waveform it finds the maximum absolute value and measures the duration
%  for which the waveform has amplitude > 25 percent of the peak.  
%  Assumes that there is only a single peak of interest (the largest).  This 
%  will not give the expected result for cases where the amplitude of K+ 
%  or capactive peaks is greater than the Na+ peak.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function width = measure_waveform_width(wave_data, times)
	
	% for measuring the duration of the peak
	thresh_pcnt = .25;

	% below I assume that "wave_data" is a column vector....
	if (size(wave_data,1)==1)
		wave_data = wave_data';
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FIND THE PEAK AND DEFINE THE THRESHOLD

	num_samples = size(wave_data,1);

	abs_data = abs(wave_data);

	[max_peak, max_sample] = max(abs_data);

	thresh = thresh_pcnt*max_peak;


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% SEARCH FOR THRESHOLD CROSSING BEFORE PEAK


	s1 = 1;
	s=max_sample;

	while (s >= 1)
		if (abs_data(s) < thresh)
			s1 = s;
			break;
		end
		s=s-1;
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% SEARCH FOR THRESHOLD CROSSING AFTER PEAK

	s2 = num_samples;
	s=max_sample;

	while (s <= num_samples)
		if (abs_data(s) < thresh)
			s2 = s;
			break;
		end
		s=s+1;
	end

	
	% s1
	% s2
	t1 = times(s1);
	t2 = times(s2);
	width = (t2-t1);