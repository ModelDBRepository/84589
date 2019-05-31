%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_voltage_trace
%  
%  Loads a single v(t) trace from a set of voltge data.  It includes a "fudge"
%  when finding the coordinates because there seemed to be some problem with
%  a roundoff error leading to no point giving an exact match.  This utility
%  is used by high level functions that plot the extracellular potential.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [trace_volts, trace_times] = get_voltage_trace(voltage_traces, volt_pts, volt_times, start_end, coord)

fudge = 1e-7; % 1/10th micron

volt_row = find(volt_pts(:,1) >= coord(1)-fudge & ...
				volt_pts(:,1) <= coord(1)+fudge & ...
				volt_pts(:,2) >= coord(2)-fudge & ...
				volt_pts(:,2) <= coord(2)+fudge & ...
				volt_pts(:,3) >= coord(3)-fudge & ...
				volt_pts(:,3) <= coord(3)+fudge);



if (isempty(volt_row) | size(volt_row,1) > 1)

	disp('----------------------------------------------------');
	disp('Could not find voltage pt!');
	coord*1e6
	find(volt_pts(:,2) == coord(2))
	find(volt_pts(:,1) == coord(1))
	disp('----------------------------------------------------');
else
	if (~ isempty(start_end)) 
		min_col = min(find(volt_times >= start_end(1)));
		max_col = max(find(volt_times <= start_end(2)));
	else
		min_col = 1;
		max_col = size(volt_times,2);
	end

	trace_volts =  voltage_traces(volt_row, min_col:max_col);
	trace_times = volt_times(1,min_col: max_col);
end
