%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  pack_memory
%
%  Simple wrapper around the call to 'pack' that handles changing the
%  directory.  If no directory is supplied it assumes there is a directory
%  called 'temp' in the current directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pack_memory(temp_dir)

if (isempty(temp_dir))
	temp_dir = 'temp';
end

cwd = pwd;
cd(temp_dir);
pack
cd(cwd);