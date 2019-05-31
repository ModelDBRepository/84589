%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_root_path
%  
%  This simply defines the root directories where various data can be found.  If you
%  want to change the directory structure update this file. (It provides a little
%  extra decoupling from the directory structure for  the make_file_name function 
%  where it is used.)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function pathName = get_root_path(type)


if (strcmp(type,'output')==1)
	pathName = '../output';
elseif (strcmp(type, 'cell')==1)
	pathName = '../cells';
else
	pathName = './'
end
