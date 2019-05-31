%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  This script plots the membrane potential versus position, Vm(x), as well
%  as the first and second derivatives of membrane potential versus position.
%  Derivatives are taken with matlab's gradient function.
%  It then uses Vm''(x) to calculate the extracellular potential at a given
%  point and then compares it to the LSA calculation for the same point.
%
%  A few things to note:
%  -  This really set up only to use for the "line" neuron simulation.  For any
%     more complex geometry with non-uniform compartment sizes the calculation of
%     the extracellular potential will be incorrect.  That said, you could still
%     plot Vm(x) and the derivatives which might be useful under some circumstances.
%  -  The LSA calculation of the voltages for comparison must be done prior to
%     running the script.
%  -  The cell this is run for must have saved compartmental details data, and have
%     a set of detail sections named "all" defined in get_detail_secs() and 
%     get_detail_xs()
%  
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
%  dt - the time interval at which to plot the Vm(x) and its derivatives.  There are
%  two ways to specify this:
%     1) If dt < 1 then this it specifies the interval in milliseconds
%     2) If dt > 1 then it means to plot dt intervals by dividing the total time into
%        that many evenly spaced intervals
%
%  ec_loc - the (x,y,z) coordinates for the point at which to calculate the extra
%        cellular action potential from the voltage gradients.  The Z value for
%        this location also tells the function what Z plane was used in the LSA
%        calculation.
%
%  xyMax - a 4 element array specifying the minimum and maxium X coordinates and Y 
%  coordinates for the LSA calculation
%
%  sigma - the extracellular conductivity to use for the calculation  
%  
%  gridSize - the spacing between points used in the LSA calculation
%  
%  Example usage
%  --------------
% plot_eap_voltage_gradients('line', [],[], 20, [0 50 0], [-500 500 -150 150], 0.3,50)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_eap_voltage_gradients(cellName, trial, start_end_times, dt, ec_loc, xyMax, sigma, grid_size)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default trial number if necessary


if (isempty(trial))
	trial = get_last_trial_num(cellName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pick/Check the start/end times for calculation

if (isempty(start_end_times))
	calc_length = 4;
	time_before_ic_peak = 1;
	[start_end_times, start_end_indices] = pick_start_end(cellName, trial, calc_length, time_before_ic_peak);
else
	[start_end_times, start_end_indices] = check_start_end(all_times, start_end_times);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants for making the plot

colormap(jet);
cmap = colormap;
n_clrs = size(cmap,1);

line_width = 1;
vem_line_width = 1;

x_loc = ec_loc(1)*1e-6;
y_loc = ec_loc(2)*1e-6;
Z = ec_loc(3);

v_ax_lim = [-70 30];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup

Ri = 1e-2*get_neuron_param_value('r_a', cellName, trial);

plot_sec_names = get_detail_secs(cellName, 'all');
sec_xs = get_detail_xs(cellName, 'all');

num_secs = length(plot_sec_names);

% load the times, and check the request start/end against them
sim_times = load(make_file_name(cellName, trial, 'time'))'; 

% plot 4 ms starting 1 ms before the peak if no start/end times were given
if (isempty(start_end_times))
	[plot_length, time_before_ic_peak] = get_default_time_params;
	[start_end_times start_end_indices] = pick_start_end(cellName, trial, plot_length, time_before_ic_peak);   
else
	% if start/end is provided determine the ideal plot times first
	[start_end_times start_end_indices] = check_start_end(sim_times, start_end_times);
	plot_length = start_end_times(2) - start_end_times(1);
end

if (dt < 1)
    ideal_plot_times = [start_end_times(1) : dt : start_end_times(2)];
else
    nsteps = dt;
    dt = (start_end_times(2)-start_end_times(1))/dt;
    ideal_plot_times = [start_end_times(1) : dt : start_end_times(2)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the compartment details data

disp('Loading Compartment Data...');

sec_data = cell(1,num_secs);

for n = 1 : num_secs

% 	disp(sprintf('Loading data for %s...',char(plot_sec_names(n))));
	sec_data(n) = {load(make_file_name(cellName, trial, 'dtls', sec_xs(n), plot_sec_names(n) ))};
end

% collect the soma data for later
soma_col = find(strcmp('soma',plot_sec_names));
soma_volts = sec_data{soma_col}(:,find_detail_column(cellName, trial, 'V'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the calculated EAP data

disp('Loading LSA Calculated EAP Data...');

[Voltages, volt_pts, lsa_times] = load_voltage_data_2d(cellName, trial, xyMax, Z, grid_size, start_end_times, sigma);


[lsa_volts lsa_times] = get_voltage_trace(Voltages, volt_pts, lsa_times, [], [x_loc y_loc 1e-6*Z]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the geometry and determine the distance to each compartment


disp('Loading cell geometry...');
[start_segs end_segs start_diams end_diams] = get_neuron_geom(cellName, trial);

all_comp_names = textread(make_file_name(cellName, trial, 'snam'),'%s');
all_comp_nums  = load(make_file_name(cellName, trial, 'snum'));

sec_dists = zeros(1,num_secs);

for s = 1 : num_secs
    sec_list_row = find(strcmp(plot_sec_names(s),all_comp_names));
    sec_geom_row = all_comp_nums(sec_list_row,1) + floor(sec_xs(s)*all_comp_nums(sec_list_row,2));
    mid_x = 0.5*(start_segs(sec_geom_row,1)+end_segs(sec_geom_row,1));
    mid_y = 0.5*(start_segs(sec_geom_row,2)+end_segs(sec_geom_row,2));
    mid_z = 0.5*(start_segs(sec_geom_row,3)+end_segs(sec_geom_row,3));

    % units = m   
    sec_dists(s) = sqrt(mid_x^2 + mid_y^2 + mid_z^2);
    
    % define pts at a negative x as being negative on the distance axis
    if (mid_x < 0)
        sec_dists(s) = sec_dists(s)*-1;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect the voltages

disp('Collecting voltages...');

plot_times_list = [];
all_times_list = [];

all_volts_data = [];
plot_volts_data = [];


% determine times for plot (a bit hacky)
plot_time_is = [];

for i = 1 : length(ideal_plot_times)
    [min_diff min_diff_i] = min(abs(lsa_times-ideal_plot_times(i)));
    plot_time_is = [plot_time_is min_diff_i];
end

counter = 1;

for i = start_end_indices(1) : start_end_indices(2)
    
    t = sim_times(i);
    all_times_list = [all_times_list t];
    
    if (mod(i,3)==0) disp(sprintf('\tt=%.2f', t)); end
    
    volts_data = zeros(1,num_secs);
    
    % units = V (from mV in the data file)
    for s = 1 : num_secs
        volts_data(s) = 1e-3*sec_data{s}(i,find_detail_column(cellName, trial, 'V'))';
    end
    
    all_volts_data = [all_volts_data; volts_data];
    
    if (any(counter == plot_time_is))
        plot_volts_data = [plot_volts_data; volts_data];
        plot_times_list = [plot_times_list; t];
    end
    counter = counter + 1;
end

n_plot_times = length(plot_times_list);
n_times = length(all_times_list);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the 1st derivative

% units = V/m 
plot_dvdxs = [];

for t = 1 : n_plot_times
    dvdx = gradient(plot_volts_data(t,:), sec_dists);    
    plot_dvdxs = [plot_dvdxs; dvdx];
end

all_dvdxs = [];
for t = 1 : n_times
    dvdx = gradient(all_volts_data(t,:), sec_dists);    
    all_dvdxs = [all_dvdxs; dvdx];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the 2nd derivative

% units = V/m^2

% for plotting
plot_d2vdx2s = [];
for t = 1 : n_plot_times
    d2vdx2 = gradient(plot_dvdxs(t,:), sec_dists);
    plot_d2vdx2s = [plot_d2vdx2s; d2vdx2];
end

% for calculating approximate Ve
all_d2vdx2s = [];
for t = 1 : n_times
    d2vdx2 = gradient(all_dvdxs(t,:), sec_dists);
    all_d2vdx2s = [all_d2vdx2s; d2vdx2];
end


% this is also used below in the total Ve calculation
% units = m (based on y_loc and sec_dists being in m)
total_dists = sqrt(y_loc^2 + (x_loc-sec_dists).^2);

scaled_plot_d2vdx2s = zeros(size(plot_d2vdx2s));
for t = 1 : n_plot_times
    scaled_plot_d2vdx2s(t,:) = plot_d2vdx2s(t,:)./total_dists;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate approximate Ve

Ve = zeros(1,n_times);


% calculate compartment length, assuming all identical
% units = m (from sec_dists being in meters)
sec_length = abs(sec_dists(2)-sec_dists(1));
disp(sprintf('sec_length = %f m', sec_length));
disp(sprintf('sec_diam  = %f m', start_diams(1)));

disp(sprintf('Ri = %f Ohm-m', Ri));

% calculate actual Ra, assuming all identical
Ra = Ri *sec_length / (pi*(start_diams(1)/2)^2);
disp(sprintf('Ra = %f Ohm', sigma));

disp(sprintf('y_loc = %f m', y_loc));
disp(sprintf('sigma = %f 1/(Ohm-m)', sigma));

for t = 1 : n_times
    scaled_d2vdx2s = all_d2vdx2s(t,:)./total_dists;
    Ve(t) = ((sec_length^2)/(4*pi*sigma*Ra)) * sum(scaled_d2vdx2s);
end

% convert to mV from volts
Ve = Ve *1e3;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voltage plot


disp('Plotting...');

figure(get_next_fig);
subplot(2,3,1);
hold on;

for t = 1 : n_plot_times
    ph = plot(1e6*sec_dists, 1e3*plot_volts_data(t,:));
    set(ph, 'LineWidth', line_width);
    set(ph, 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
end

% plot annotation
title(sprintf('V_m(x) for %s.%d', cellName, trial));
ylabel('mV');
xlabel('\mu m');
grid on;
xlim(1e6*[min(sec_dists) max(sec_dists)]);
ylim(v_ax_lim);

legend_strings = cell(1,n_plot_times);
for t = 1 : n_plot_times
    legend_strings{t} =  sprintf('t=%.2f',plot_times_list(t)-plot_times_list(1));
end
legend(legend_strings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1st derivative plot

subplot(2,3,2);
hold on;

for t = 1 : n_plot_times
    ph = plot(1e6*sec_dists, plot_dvdxs(t,:));
    set(ph, 'LineWidth', line_width);
    set(ph, 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
end

title('dV_m/dx');
ylabel('V/m');
xlabel('\mu m');
grid on;
xlim(1e6*[min(sec_dists) max(sec_dists)]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2nd derivative plot

subplot(2,3,3);
hold on;

for t = 1 : n_plot_times
    ph = plot(1e6*sec_dists, plot_d2vdx2s(t,:));
    set(ph, 'LineWidth', line_width);
    set(ph, 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
end

title('d^2V_m/dx^2');
ylabel('V/m^2');
xlabel('\mu m');
grid on;
xlim(1e6*[min(sec_dists) max(sec_dists)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scaled 2nd derivative plot

subplot(2,3,4);
hold on;

for t = 1 : n_plot_times
    ph = plot(1e6*sec_dists, scaled_plot_d2vdx2s(t,:));
    set(ph, 'LineWidth', line_width);
    set(ph, 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
end

title(sprintf('(d^2V_m/dx^2)/d(x), x=%d, y=%d \\mu m', round(x_loc*1e6), round(1e6*y_loc)));
ylabel('V/m^3');
xlabel('\mu m');
grid on;
xlim(1e6*[min(sec_dists) max(sec_dists)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Ve approximation

subplot(2,3,5);

hold on;

% plot the approximation in colors of the rest of the plot
for t = 2 : n_plot_times
    times_i = find(all_times_list >= plot_times_list(t-1) & all_times_list <= plot_times_list(t)); 
    ph = plot(all_times_list(times_i)-all_times_list(1), Ve(times_i), 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
    set(ph, 'LineWidth', vem_line_width);
end

ph = plot( lsa_times-lsa_times(1), lsa_volts, 'k:');
set(ph, 'LineWidth', vem_line_width);

grid on;
xlabel('ms');
ylabel('mV');
title(sprintf('Ve @ x=%d, y=%d \\mu m',  round(x_loc*1e6), round(1e6*y_loc)));
xlim([0 plot_length]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Soma Vm at the soma


subplot(2,3,6);
hold on;
offset = 0;

for t = 2 : n_plot_times
    times_i = find(sim_times >= plot_times_list(t-1) & sim_times <= plot_times_list(t));
    if (t==2) offset = sim_times(times_i(1)); end
    ph = plot(sim_times(times_i)-offset, soma_volts(times_i), 'Color', cmap(round(n_clrs*(t/n_plot_times)),:));
    set(ph, 'LineWidth', vem_line_width);
end

title('Soma V(t)');
xlim([0 plot_length]);
ylim(v_ax_lim);
grid on;
