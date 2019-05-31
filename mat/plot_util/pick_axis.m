%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pick_axis
%
%  Utility to pick an axis min/max from a pre-defined list of axes rather 
%  than letting Matlab pick.  The purpose here is if we want
%  the axes min/max to come only a regular set that bear some relationship
%  to each other, for example using axes that are only multiples of two
%  from each other  [.01 .02 .04 .08].  This makes large complex plots such
%  as the intracellular details plot easier to interpret.
%
%  Parameters are:
%  axes - the candidate min/max for the axes
%  data - the data which is being plotted
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ax = pick_axis(axes, data)

	if (size(data,1) > 1)
		[maxs indices] = max(abs(data),[],2);
		data_max = max(maxs');
	else
		data_max = max(abs(data));
	end

	ok_axes = axes(find(data_max < axes));
	
	if (~isempty(ok_axes))
		ax = min(ok_axes);
	else
		ax = max(axes);
	end
