%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_next_fig
%
%  Utility that keeps a global count of the last figure opened (via this 
%  method) and returns the index for the next figure.  This was
%  useful because when using Matlab 6 with 'hold on' simply calling 'figure'
%  would bring back an axes that still had the previous contents.  It is
%  not necessary with later versions of Matlab.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fignum = get_next_fig()

global curr_fig;
	
if (~isempty(curr_fig))
	curr_fig = curr_fig+1;
else
	curr_fig = 1;
end

fignum = curr_fig;