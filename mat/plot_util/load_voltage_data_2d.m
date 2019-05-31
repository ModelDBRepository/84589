%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  load_voltage_data_2d
%  
%  This is simply a wrapper around loading a file of 2D voltage data - it
%  calls the routine to make the file name, and then separates into the
%  XYZ coordinates, the times and the actual voltage data.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Voltages, volt_pts, volt_times] = load_voltage_data_2d(cellName, trial, xyMax, Z, grid, start_end_times, sigmas)

% 
% file format:
% 	0	0	0	t1	t2	t3	...
% 	x1	y1	z1	v11	v12	v13	...
% 	x2	y2	z2	v21	v22	v23 ...
% 	...

VoltageData = [];

% check for the proper file first
file_name = make_file_name(cellName, trial, 'vt2d', [xyMax Z grid start_end_times sigmas]);

if (exist(file_name,'file'))
	VoltageData = load(file_name);
else
	disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	disp(sprintf('No data file %s in load_voltage_data_2d', file_name));
	disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	Voltages = [];
	volt_pts = [];
	volt_times = [];
	return;
end

Voltages = VoltageData(2:size(VoltageData,1), 4:size(VoltageData,2));
volt_pts = VoltageData(2:size(VoltageData,1), 1:3);
volt_times = VoltageData(1, 4:size(VoltageData,2));

