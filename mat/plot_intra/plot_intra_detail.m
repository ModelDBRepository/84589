%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot_intra_detail
%
%  Creates a plot of the simulation details for a specified set of compartments. Along the 
%  lines of figures 1-3 in Gold, Henze, Koch and Buzsaki (2006) and figure 5-8 in Gold, Henze
%  and Koch (2007). The basic algorithm is that the script loops over a set of compartments 
%  and for each one generates the request figures along a row of the plot.  The set of compartments 
%  is described by a descriptive string which corresponds to a list in the functions 
%  get_detail_secs and get_detail_xs. The standard data plotted on each
%  line is the membrane potential, the total membrane current, and the breakdown of the 
%  membrane current into ionic and capacitive components.  Additional data may be plotted
%  for each row according to the arguments described below. Unfortunately, this is a rather 
%  long and convoluted script.  Fortunately, it already  provides a large number of options 
%  to create a wide variety of plots and gracefully handles a reasonable range of data scales.
%  
%  Parameters control exactly what plot is produced:
%  
%  cellName - which cell to plot (i.e. 'd151')
%  
%  trial - which trial to plot; this can be left empty (i.e. '[]') in which case the program
%  will determine the most recent trial and plot it
%  
%  sec_string - a string that describes which portion of the cell to plot.  The choices are:
%  	approx : apical trunk dendrite, proximal
%  	apdist : apical trunk dendrite, distal
%  	basal  : a sample basal dendrite
%  	axon   : the axon
%  More options can be created by defining suitable detail compartments in the NEURON program
%  (see current_util.hoc) and suitable choices in get_detail_secs.m and detail_xs.m 
%  (in ../cell_settings)
%  
%  plot_ion_mechs - a cell array of strings describing which optional ions and other details
%  to plot.  The options are:
%  	na	: plot details of Na+ current mechanisms
%  	k	: plot details of K+ current mechanisms
%  	ca	: plot details of Ca++ current mechanims (if this option is used alone, the script
%  		  will not plot other total ionic currents - that is useful to make the Ca++ current
%  		  visible at a smaller scale)
%  	h	: plot the mixed ion h current mechanism
%  	ax	: plot axial currents
%  Supplying an empty list will plot only the membrane potential, total membrane current, and
%  components of the mebrane current.
%  
%  start_end_times - the beginning and ending times of the simulation to plot.  If this option
%  is left empty (i.e. '[]') then the default behavior is to start the plot 1 ms before the
%  intracellular action potential peak and make the plot 4 ms long.
%  
%  If the save_types cell array (under 'constants', below) is defined then the script will
%  automatically save the output to the listed formats.
%  
%  Sample Uses:
%  --------------
%   plot_intra_detail('d151', [], 'approx', {}, [])
%   
%   plot_intra_detail('d151', [], 'approx', {'ax';'k'}, [])
%   
%   plot_intra_detail('d151', [], 'apdist', {'ax';'k'}, [])
%   
%   plot_intra_detail('d151', [], 'approx', {'ca'}, [])
%   
%   plot_intra_detail('d151', [], 'basal', {'ax'}, [10 20])
%   
%   plot_intra_detail('d151', 27, 'axon', {'ax';'k'}, [])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_intra_detail(cellName, trial, secs_string, plot_ion_mechs, start_end_times)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constants

gate_part_lines = {'k-';'k--';'b-';'b--';'m-';'m--';'r-';'r--';'g-';'g--';'c-';'c--';'y-';'y--';};
g_lines = {'r-';'b-';'g-';'c-';'y-';'m-';'k-';'r--';'b--';'g--';'c--';'y--';'m--';'k--'};

% controls y-axes limits
v_axis = [-75 25];
i_axes = [.01 .02 .05 .1 .2 .5 1 2 5 10 20 50];
g_axes = [.04 .02 .01 .005 .002 .001 .0001 .00001 .000001];
ca_axes = [1e-6 1e-4 .25e-3 .5e-3 1e-3 2e-3 4e-3 8e-3];
ca_ax_min = 0.7e-4;

curr_colors = {'r' ; 'g' ; 'y' ; 'k' ; 'b'; 'k--'};
curr_strings = {'I_na'; 'I_k' ; 'I_ca'; 'I_pas'; 'I_cap'};
plot_curr_strings = {'I_{na}'; 'I_{k}' ; 'I_{ca}'; 'I_{pas}'; 'I_{cap}'};
num_currs = 5;
gate_part_col_offset = 5;  % time, Itot, V, I_in (axial), I_out (axial)

save_types = {'epsc'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup

% plot the last trial if no trial was given
if (isempty(trial))
	trial = get_last_trial_num(cellName);
end


% get a set of compartments based on the description
plot_sec_names = get_detail_secs(cellName, secs_string);
sec_xs = get_detail_xs(cellName, secs_string);

num_secs = length(plot_sec_names);
num_plot_ion_mechs = length(plot_ion_mechs);

% load the times, and check the request start/end against them
sim_times = load(make_file_name(cellName, trial, 'time'))'; 


% plot 4 ms starting 1 ms before the peak if no start/end times were given
if (isempty(start_end_times))
	plot_length = 4;
	time_before_ic_peak = 1;
	[start_end_times start_end_indices] = pick_start_end(cellName, trial, plot_length, time_before_ic_peak);
else
	[start_end_times start_end_indices] = check_start_end(sim_times, start_end_times);

end

% zero the time for the start of the plot
plot_times = sim_times(start_end_indices(1):start_end_indices(2));
plot_times = plot_times-plot_times(1);
total_time = round(plot_times(length(plot_times)));

% make a string describing the ions being plotted (for the file name to save)
if (isempty(plot_ion_mechs))
	ions_string = 'noi';
else
	ions_string = '';
	for i = 1 : size(plot_ion_mechs,1)
		ions_string = strcat(ions_string, char(plot_ion_mechs(i)));
	end

end

ext = sprintf('%s%.0f-%.0f_%s',ions_string, start_end_times(1), start_end_times(2), secs_string);


% figure out if we are plotting the axial current
do_plot_axial_current = 0;
for pi = 1 : num_plot_ion_mechs
	if (strncmp(char(plot_ion_mechs(pi)),'ax',2))
		do_plot_axial_current = 1;
		
		% if we are plotting the axial current, remove it from the list
		% (is there a better way to remove an element from a cell array?)
		if (num_plot_ion_mechs>1)
			if (pi ==1)
				plot_ion_mechs = plot_ion_mechs(2:end);
			elseif (pi == num_plot_ion_mechs)
				plot_ion_mechs = plot_ion_mechs(1:num_plot_ion_mechs-1);
			else
				plot_ion_mechs = {plot_ion_mechs{1:pi-1} plot_ion_mechs{pi+1:end}};
			end
		else
			plot_ion_mechs = {};
		end
		
		num_plot_ion_mechs = length(plot_ion_mechs);
		break;
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load & Sort the Mechanism Description Data

mech_gates_file = make_file_name(cellName, trial, 'mgts');
mech_gates = textread(mech_gates_file, '%s');

% Figure out which columns correspond to which currents
% and for each ion current make an array for gate part columns
% and another array for conductance columns

gate_columns = cell(1,num_plot_ion_mechs);
g_columns = cell(1, num_plot_ion_mechs);

do_ca_buf = 1;
ca_cols = [];
buff_cols = [];

for i = 1 : size(mech_gates,1)


	[gate_name gate_part] = strtok(char(mech_gates(i)), '_');

	for j = 1 : num_plot_ion_mechs
		
		% disp(sprintf('checking %s for %s:', gate_name, char(plot_ion_mechs(j))));

		k = findstr( gate_name, char(plot_ion_mechs(j)));

		% start of the name should be the ion, or h for the h current
		if (~isempty(k) & k(1)==1)

			if (strcmp(gate_part,'_g')==1)
				g_columns(j) = {[g_columns{j} i]};
			elseif (~isempty(findstr(gate_part, 'ca')))
				disp('Calcium Column...');
				ca_cols = [ca_cols i];
			elseif (~isempty(findstr(gate_part, 'Buffer')));
				disp('Buffer Column...');
				buff_cols = [buff_cols i];
			else
				gate_columns(j) = {[gate_columns{j} i]};
			end
		end
	end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the compartment data

sec_data = cell(1,num_secs);

for n = 1 : num_secs

	disp(sprintf('Loading data for %s...',char(plot_sec_names(n))));
	sec_data(n) = {load(make_file_name(cellName, trial, 'dtls', sec_xs(n), plot_sec_names(n) ))};
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Setup

figure(get_next_fig);

% choose a x-tick and x-ticks spacing basd on the length of time being plotted
if (start_end_times(2) - start_end_times(1) < 4)
	tick_spacing = 0.5;
elseif (start_end_times(2) - start_end_times(1) < 8)
	tick_spacing = 1;
else
	tick_spacing = round((start_end_times(2) - start_end_times(1))/5);
end
	
xticks = [plot_times(1) : tick_spacing : plot_times(length(plot_times))];
if (tick_spacing >= 1)
	xticks = round(xticks);
	tick_labels = xticks;
else
	xticks = 10 * xticks;
	xticks = round(xticks);
	xticks = 0.1* xticks;
	tick_labels = xticks-xticks(1);
end

% how many plots not related to ionic currents are being made?
if (do_plot_axial_current == 1)
	num_non_ion_plots = 4;
else
	num_non_ion_plots = 3;
end

% always plot volts, total current & ion currents - number of ions varies
num_plot_cols = num_non_ion_plots + 2*num_plot_ion_mechs;

if (~isempty(ca_cols) & do_ca_buf ==1)
	num_plot_cols = num_plot_cols+1;
end
if (~isempty(buff_cols) & do_ca_buf ==1)
	num_plot_cols = num_plot_cols+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop over compartments to make the plot

for i = 1 : num_secs

	% disp(sprintf('',));
	disp(sprintf('Plotting %s ...',char(plot_sec_names(i)) ) );

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%  Plot Membrane Voltages on the left

	subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+1);

	volts_data = sec_data{i}(start_end_indices(1):start_end_indices(2),find_detail_column(cellName, trial, 'V'))';
	
	ph = plot(plot_times, volts_data, 'k');
	
	axis([0 total_time v_axis(1) v_axis(2)]);
	ylabel('mV');

	set(gca,'XTickLabelMode', 'manual');
	set(gca,'XTick', xticks);
	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');
	
	if (i ~= num_secs)
		set(gca, 'XTickLabel', []);
	else
		set(gca, 'XTickLabel', tick_labels);
	end


	if (isempty(sec_xs))
		title_h = title(sprintf('%s',char(plot_sec_names(i))), 'Interpreter', 'none');
	else
		title_h = title(sprintf('%s(%.2f)',char(plot_sec_names(i)), sec_xs(i)), 'Interpreter', 'none');
	end
	set(title_h, 'VerticalAlignment', 'Middle');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Plot Total 2nd to Left, w/ axial currents...

	subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+2);

	tot_data = sec_data{i}(start_end_indices(1):start_end_indices(2),find_detail_column(cellName, trial, 'I_tot'));
	ph = plot(plot_times, tot_data, 'k');
	

	set(title_h, 'VerticalAlignment', 'Middle');
	ylabel('nA');
	
	i_ax = pick_axis(i_axes, tot_data);
	
	axis([0 total_time -i_ax i_ax]);
	
	set(gca,'XTickLabelMode', 'manual');
	set(gca,'XTick', xticks);
	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');
	
	if (i ~= num_secs)
		set(gca, 'XTickLabel', []);
	else
		set(gca, 'XTickLabel', tick_labels);
		
	end

	if (i == 1)
		title_h = title(sprintf('%s-%04d ',cellName, trial));
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Plot Total Ion Currents 3rd

	subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+3);
	hold on;
	all_ion_currs = [];	
	
	for m = 1 : num_currs
		% if we're only plotting calcium, skip other ion currents
		% (or else Ca will be invisible on the larger scale)
		if (num_plot_ion_mechs==1 & ~isempty(ca_cols) & strcmp(char(curr_strings(m)),'I_ca') ~= 1)
			continue;
		end
		
		ion_curr_data = sec_data{i}(start_end_indices(1):start_end_indices(2),find_detail_column(cellName, trial, char(curr_strings(m))));
		ph = plot(plot_times, ion_curr_data, char(curr_colors(m)));
		all_ion_currs = [all_ion_currs; ion_curr_data];
	end
	hold off;

	i_ax = pick_axis(i_axes, all_ion_currs);
	axis([0 total_time -i_ax i_ax]);

	ylabel('nA');
	set(gca,'XTickLabelMode', 'manual');
	set(gca,'XTick', xticks);
	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');

	if (i ~= num_secs)
		set(gca, 'XTickLabel', []);
	else
		set(gca, 'XTickLabel', tick_labels);
		
		% hacky make the legend for Ca only plot
		if (num_plot_ion_mechs==1 & ~isempty(ca_cols) ~= 0 & strcmp(char(curr_strings(m)),'I_ca') ~= 1)
			legend('I_{ca}');
		else
			legend(plot_curr_strings(1:num_currs), 0);
		end
	end
	
	if (i == 1)
		title_h = title(sprintf('t=%.1f-%.1f', start_end_times(1), start_end_times(2)));
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% If plotting them, plot axial currents 4th
	
	if (do_plot_axial_current == 1)

		subplot(num_secs, num_plot_cols, (i-1)*num_plot_cols+4);
		
		hold on;
		
		
		in_data = sec_data{i}(start_end_indices(1):start_end_indices(2),find_detail_column(cellName, trial, 'I_in'));
		ph = plot(plot_times, in_data, 'r');
		
		out_data = sec_data{i}(start_end_indices(1):start_end_indices(2),find_detail_column(cellName, trial, 'I_out'));
		ph = plot(plot_times, out_data, 'b');

		all_is = [in_data; out_data];
		i_ax = pick_axis(i_axes, all_is);
	
		axis([0 total_time -i_ax i_ax]);
			
		set(gca,'XTickLabelMode', 'manual');
		set(gca,'XTick', xticks);
		set(gca, 'XGrid', 'on');
		set(gca, 'YGrid', 'on');
		
		if (i ~= num_secs)
			set(gca, 'XTickLabel', []);
		else
			set(gca, 'XTickLabel', tick_labels);
			legend('I_{in}(ax)','I_{out}(ax)');
		end
		
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Plot mechanism particles and conductances

	for m = 1 : num_plot_ion_mechs
	
		disp(sprintf('Plotting ion mechs for %s',char(plot_ion_mechs(m)) ) );
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% Plot Mechanism Gate Parts 
		
		subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+num_non_ion_plots+(m*2)-1);
		hold on;

		num_gate_parts = size(gate_columns{m},2);
		legend_list = cell(1,num_gate_parts);
		
		for n = 1 : num_gate_parts
			% add number of current columns, plus 3 for the time column, I_tot and V, I_in, I_out
			gate_part_col = gate_columns{m}(n) + num_currs + gate_part_col_offset;
			
			% this is a total hack to find the gate name
			chan_gate =char(mech_gates(gate_columns{m}(n)));
			underscore = findstr('_',chan_gate);
			chan =chan_gate(1:underscore-1);
			gate =chan_gate(underscore+1: length(chan_gate) );

			% read the power associated with this gate from the neuron parameters
			power = get_neuron_param_value(sprintf('exp_%s_%s',gate, chan), cellName, trial);
			if (isempty(power)) power = 1; end	% non HH style gates won't have a power

			gate_part_data_noexp = sec_data{i}(start_end_indices(1):start_end_indices(2),gate_part_col);
			
			gate_part_data = ones(size(gate_part_data_noexp));

			for p = 1 : power
				gate_part_data = gate_part_data .* gate_part_data_noexp;
			end

			ph = plot(plot_times, gate_part_data , char(gate_part_lines(n)));
			
			
			legend_list(n) = strcat(strrep(mech_gates(gate_columns{m}(n)),'_','-'), sprintf('^%d',power));
		end
		hold off;

		% celldisp(legend_list)
		
		axis([0 total_time 0  1]);

		set(gca,'XTickLabelMode', 'manual');
		set(gca,'XTick', xticks);
		set(gca, 'XGrid', 'on');
		set(gca, 'YGrid', 'on');

		if (i ~= num_secs)
			set(gca, 'XTickLabel', []);
		else
			set(gca, 'XTickLabel', tick_labels);
			legend(legend_list, 0);
		end

		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% Plot Mechanism Conductance

		subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+num_non_ion_plots+(m*2));
		hold on;
		
		num_gs = size(g_columns{m},2);
		legend_list = cell(1,num_gs);
		all_g_data = [];

		for n = 1 : num_gs
			g_col = g_columns{m}(n) + num_currs + gate_part_col_offset;
			g_data = sec_data{i}(start_end_indices(1):start_end_indices(2),g_col);
			ph = plot(plot_times, g_data ,char(g_lines(n)));

			all_g_data = [all_g_data; g_data];
			legend_list(n) = strrep(mech_gates(g_columns{m}(n)),'_','-');
		end
		hold off;

		g_ax = pick_axis(g_axes, all_g_data);
		axis([0 total_time 0 g_ax]);
					
		set(gca,'XTickLabelMode', 'manual');
		set(gca,'XTick', xticks);
		set(gca, 'XGrid', 'on');
		set(gca, 'YGrid', 'on');
		
		if (i ~= num_secs)
			set(gca, 'XTickLabel', []);
		else
			set(gca, 'XTickLabel', tick_labels);
			legend(legend_list, 0);
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% If we're plotting cad calcium, plot it after others

	if (~isempty(ca_cols)  & do_ca_buf ==1)

		subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+num_plot_cols-1);
		hold on;
		num_cas = size(ca_cols,2);
		legend_list = cell(1,num_cas);
		all_ca_data = [];

		for n = 1: num_cas
			ca_col = ca_cols(n) + num_currs + gate_part_col_offset;
			ca_data = sec_data{i}(start_end_indices(1):start_end_indices(2),ca_col)';
			ph = plot(plot_times, ca_data, char(gate_part_lines(n)));

			all_ca_data = [all_ca_data ; ca_data];
			legend_list(n) = strrep(mech_gates(ca_cols(n)),'_','-');
		end
		hold off;

		ylabel('Ca_i (mM)');
		set(gca, 'YAxisLocation', 'right');

		ca_ax = pick_axis(ca_axes, all_ca_data);
		axis([0 total_time ca_ax_min ca_ax]);

		set(gca,'XTickLabelMode', 'manual');
		set(gca,'XTick', xticks);
		set(gca, 'XGrid', 'on');
		set(gca, 'YGrid', 'on');

		if (i ~= num_secs)
			set(gca, 'XTickLabel', []);
		else
			set(gca, 'XTickLabel', tick_labels);
			legend(legend_list, 0);
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Plot State of Ca Buffers

	if (~isempty(buff_cols)  & do_ca_buf ==1)

		subplot(num_secs,num_plot_cols,(i-1)*num_plot_cols+num_plot_cols);
		hold on;
		num_cas = size(buff_cols,2);
		legend_list = cell(1,num_cas);
		all_buff_data = [];

		for n = 1: num_cas
			buff_col = buff_cols(n) + num_currs + gate_part_col_offset;
			buff_data = sec_data{i}(start_end_indices(1):start_end_indices(2),buff_col)';
			ph = plot(plot_times, buff_data, char(gate_part_lines(n)));

			all_buff_data = [all_buff_data ; buff_data];
			legend_list(n) = strrep(mech_gates(buff_cols(n)),'_','-');
		end
		hold off;

		ylabel('CaBuf (mM)');
		set(gca, 'YAxisLocation', 'right');

		buff_ax = pick_axis(ca_axes, all_buff_data);
		axis([0 total_time 0 buff_ax]);

		set(gca,'XTickLabelMode', 'manual');
		set(gca,'XTick', xticks);
		set(gca, 'XGrid', 'on');
		set(gca, 'YGrid', 'on');

		if (i ~= num_secs)
			set(gca, 'XTickLabel', []);
		else
			set(gca, 'XTickLabel', tick_labels);
			legend(legend_list, 0);
		end
	end
end

if (~exist(make_file_name(cellName, trial, 'mout', [], {}) , 'dir'))
	status = mkdir(make_file_name(cellName, trial, 'pout'), 'mat');
end


for s = 1 : length (save_types)

	save_file = make_file_name(cellName, trial, 'idts', [], {ext; char(save_types(s))});
	saveas(gcf, save_file, char(save_types(s)));

end

