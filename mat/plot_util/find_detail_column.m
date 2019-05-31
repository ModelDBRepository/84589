%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  find_detail_column
%  
%  Returns the column number for a specified element of the detailed data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function col = find_detail_column(cellName, trial, var_name)


	curr_types_file = make_file_name(cellName, trial, 'ctyp');
	curr_types = textread(curr_types_file, '%s');
	
	mech_gates_file = make_file_name(cellName, trial, 'mgts');
	mech_gates = textread(mech_gates_file, '%s');
	
	

	match_curr_type = find(strcmp(curr_types,var_name)==1);
	match_mech_gate = find(strcmp(mech_gates,var_name)==1);
	
	col = 0;
	
	% in the details files the list of current types comes first, followed
	% by the list of mechanism gates/variables
	% +1 is because first column is the time, which is not listed in either file
	
	if (~isempty(match_curr_type))
		col = 1+match_curr_type;
	elseif (~isempty(match_mech_gate))
		col = 1+size(curr_types,1)+match_mech_gate;
	end