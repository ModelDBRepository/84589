%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  Calculates the Line Source Approximation of extracellular potentials for 
%  a rectangular grid of points with a single Z value.  This function performs
%  the task of setting up the grid of points that is passed to get_h and get_phi
%  (which do the real computation), and looping over the times to calculate.
%  
%  The parameters are:
%  
%  cellName - the cell to calculate for
%  
%  trial - the trial # ; this can be left blank and the program will determine
%  the last trial and use that
%  
%  start_end_times - the (approximate) beginning and ending times to calculate for;
%  if this is left blank the program will pick times that begin 1 ms before the 
%  somatic peak membrane potential and ending 3 ms after.
%  
%  sigma - the extracellular conductivity to use for the calculation
%  
%  xyMax - a 4 element array specifying the minimum and maxium X coordinates and Y 
%  coordinates; i.e. [xmin xmax ymin ymax]
%  
%  Z - the Z value to calculate for
%  
%  gridSize - the spacing between points at which to calculate; it is usually best 
%  to make the xyMax evenly divisible by the gridSize
%  
%  Example usage
%  --------------
%  zplane_eap_calc('d151', [], [], 0.3, [-100 100 -100 100], 0, 20);
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function VoltageData = zplane_eap_calc(cellName, trial, start_end_times, sigma, xyMax, Z, gridSize)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default trial number if necessary


if (isempty(trial))
	trial = get_last_trial_num(cellName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the simulation times

all_times = load(make_file_name(cellName, trial, 'time'))';  %'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pick/Check the start/end times for calculation

if (isempty(start_end_times))
	calc_length = 4;
	time_before_ic_peak = 1;
	[start_end_times, start_end_indices] = pick_start_end(cellName, trial, calc_length, time_before_ic_peak);
else
	[start_end_times, start_end_indices] = check_start_end(all_times, start_end_times);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prune the calculation times

calc_times = all_times(find(all_times >= start_end_times(1) & all_times <=start_end_times(2)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the geometry

disp('Loading Geometry...');


[start_segs end_segs start_diams end_diams] = get_neuron_geom(cellName, trial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make list of all point coordinates

disp('making pts...');

% for calculation, we want to convert these from micro-meters to meters
pt_coord = make_2D_pt_coords(xyMax, Z, gridSize)*1e-6;

Voltages = zeros(size(pt_coord,1), size(calc_times,2));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the segment distances to point coords

disp('Doing get_h reference frame conversion...');

[h, R, ds] = get_h(pt_coord,start_segs,end_segs);


r = sqrt(diag(pt_coord * pt_coord'))';   %distance between points and soma


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over times


for t = 1 : length(calc_times)

	time = calc_times(t);
	disp(sprintf('LSA t=%f',time));

	I_segs = get_neuron_current(cellName, trial, time);

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Call the Calculation Routine

	[Voltage_segs]= get_phi(h,R,ds,I_segs,sigma, pt_coord);

	Voltages(:,t) = Voltage_segs'; 
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save it

% convert to millivolts
Voltages = Voltages * 1000;

% file format:
%	sigma	0	0	t1	t2	t3	...
%	x1	y1	z1	v11	v12	v13	...
%	x2	y2	z2	v21	v22	v23 ...
%	...

VoltageData = [ sigma 0 0 calc_times];
VoltageData = [VoltageData; pt_coord Voltages];

if (~exist(make_file_name(cellName, trial, 'mout', [], {}) , 'dir'))
	status = mkdir(make_file_name(cellName, trial, 'pout'), 'mat');
end

saveDataName =  make_file_name(cellName, trial, 'vt2d', [xyMax Z gridSize start_end_times sigma ])

save(saveDataName,'VoltageData','-ASCII');
