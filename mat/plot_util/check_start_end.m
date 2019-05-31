%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check_start_end
%
%  This utility compares the (non-uniform) times at which the simulation 
%  exported data with the requested start/end times for a plot/calculation.
%  It determines what times from the simulation most closely match those
%  requested by the user and return the actual start/end times and the
%  corresponding indices into the simulation time array.  This function 
%  is called from a variety of higher level plotting/calculation functions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [start_end_new, start_end_indices] = check_start_end(sim_times, start_end_old)

start_end_new = [-1 -1];
start_index = 0;
end_index = 0;


if (isempty(start_end_old))
	start_end_new = [ sim_times(1) sim_times(length(sim_times))];
	start_index = 1;
	end_index = length(sim_times);
else
	if (start_end_old(1) < sim_times(1))
		start_end_new(1) = sim_times(1);
		start_index = 1;
	end

	if (start_end_old(2) > sim_times(length(sim_times)))
		start_end_new(2) = sim_times(length(sim_times));
		end_index = length(sim_times);
	end
	
	if (isempty(find(sim_times == start_end_old(1))))
		[dist start_index] = min(abs(sim_times - start_end_old(1)));
		start_end_new(1) = sim_times(start_index);
	else
		start_index = find(sim_times == start_end_old(1));
	end

	if (isempty(find(sim_times == start_end_old(2))))
		[dist end_index] = min(abs(sim_times - start_end_old(2)));
		start_end_new(2) = sim_times(end_index);
	else
		end_index = find(sim_times == start_end_old(2));
	end
end


if (start_end_new(1) == -1)
	start_end_new(1) = start_end_old(1);
end

if (start_end_new(2) == -1)
	start_end_new(2) = start_end_old(2);
end

start_end_indices = [start_index end_index];

