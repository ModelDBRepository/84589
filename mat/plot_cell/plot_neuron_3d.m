%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  plot_neuron_3d
% 
% This is a simple wrapper around the plot_cell routine.  Opens the cell geometry,
% creates a figure,  and plots the cell to it.
% 
% Example Use:
% ------------
%
% plot_neuron_3d('d151',20, [-400 200 -200 200 -200 200])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plot_neuron_3d(cellName, trial, plot_max)

if (isempty(trial))
	trial = get_last_trial_num(cellName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the Geometry

disp('loading geometry...');
[start_segs end_segs start_diams end_diams] = get_neuron_geom(cellName, trial);

figure(get_next_fig);
main_ax_h = axes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual Plotting Routine

flatten_cell = 0;
plot_cell(start_segs, end_segs, start_diams, end_diams, plot_max, main_ax_h, flatten_cell);


if (~isempty(plot_max))
	axis([plot_max(1) plot_max(2) plot_max(3) plot_max(4) plot_max(5) plot_max(6)]);
end

set(gca, 'DataAspectRatio', [1 1 1]);
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');

