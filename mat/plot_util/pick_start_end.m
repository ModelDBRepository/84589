%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pick_start_end
%
%  This utility picks start/end times for a plot/calculation run on a 
%  particular simulation.  The method is to pick a sequence of times that
%  begin a specified interval before the peak of the soma membrane potential.
%  This function is used by most of the high level plotting/calculation 
%  functions.  The parameters are
%
%   sequence_length - the total duration of the time sequence
%
%   pre_length - how much time to leave before the intracellular potential peak 
%
%   cellName - the cell 
%
%   trial - the trial number
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [se_times, se_indices] = pick_start_end(cellName, trial, sequence_length, pre_length, section, x)

	if (nargin < 5)
		section = 'soma';
		x = 0.5;
	end

	sess_data = load(make_file_name(cellName, trial, 'dtls', x, {section}));
	sess_times = load(make_file_name(cellName, trial, 'time'))';  %'
	
	sess_volts = sess_data(:,find_detail_column(cellName, trial, 'V'))';
	
	[v t_max] = max(sess_volts);
	
	[tdiff t_start] = min(abs(sess_times - (sess_times(t_max)-pre_length)));
	
	s = sess_times(t_start);
	
	[tdiff t_end] = min(abs(sess_times  - (sess_times(t_max)+(sequence_length-pre_length))));

	e = sess_times(t_end);
	se_times = [s e];
	se_indices = [t_start t_end];	
