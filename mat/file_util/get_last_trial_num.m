%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_last_trial_num
%  
%  This script will return the last trial number for any cell.  This is achieved by
%  examing the trial number file in the cells directory.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = get_last_trial_num(cellName)

	trial_num_file = make_file_name(cellName, 0, 'trnm', [], {});
	
	s = load(trial_num_file);
	
	s = s -1;
