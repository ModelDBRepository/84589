%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% measure_cap_rise_derivs
%
%  Calculates dV/dt for each point up to the capacitive peak and returns the
%  maximum, i.e. the steepest rise.  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function max_deriv = measure_cap_rise_derivs(ec_volts, cap_peak_i, times)


	
	max_deriv = -1e10;
	
	for s = 2 : cap_peak_i
		delta_v = ec_volts(s)-ec_volts(s-1);
		delta_t =  times(s)-times(s-1);  % should already be in ms
		deriv = delta_v / delta_t;  % using ms and mV for deriv

		if (deriv > max_deriv)
			max_deriv = deriv;
		end
	end
	
	
	% disp(sprintf('\tMax Deriv=%f @ t=%f,   Min Deriv=%f @ t=%f', max_deriv, max_deriv_samp*samp_step*1e3, min_deriv, min_deriv_samp*samp_step*1e3));