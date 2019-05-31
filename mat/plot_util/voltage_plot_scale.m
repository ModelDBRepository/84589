%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  voltage_plot_scale
%  
%  This is a specialized scaling utility used in making the EAP "grid" plot
%  (plot_eap_grid): it picks an appropriate scale for the voltage along with 
%  a color from the lists provided.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ymin, ymax, clr] = voltage_plot_scale(volt_trace, voltageScales, voltageColors)

	
	maxV = max(volt_trace);
	minV = min(volt_trace);

	if (abs(maxV) > abs(minV))
		peak = abs(maxV);
	else
		peak = abs(minV);
	end

	for i = 1 : length(voltageScales)
		if (peak < voltageScales(i) | i == length(voltageScales)) 
			ymin = -voltageScales(i);
			ymax = voltageScales(i);
			clr =  char(voltageColors(i,:));
			break;
		end
	end
