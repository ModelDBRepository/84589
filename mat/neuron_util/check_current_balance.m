%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  check_current_balance
%  
%  This is essentially a debugging utility: The total membrane current of all 
%  compartments in a NEURON simulation should equal zero (or equal the current
%  injection, if there is any.)  This script plots the net current for all 
%  compartments and compares it to the somatic membrane current.  If the NEURON
%  code is correct then the net current should be vanishingly small in comparison
%  to the somatic membrane current.  It will never be exactly zero due to numerical
%  rounding errors in the simulation, but if the error is less than something 
%  like one 1000th of the somatic membrane current the error will not perturb the
%  LSA calculation in any meaningful way. (It actually should be much smaller than 
%  this: on the order of one 100,000th.)
%  
%  If you add any additional currents to the NEURON model, such as chlorine, synaptic
%  currents, non-specific ionic currents, a shunt, etc.  you will have to modify the 
%  the neuron file current_util to correctly account for them.  After doing so this
%  script is a good check that you have done so correctly.  
%  
%  Adding a current injection does not require a change in the current_util.hoc file 
%  - the result should be that the net current plotted here will now EQUAL the current 
%  injection!  In that case you should probably subtract the current injection from
%  the net current in this script in order to assess the error.
%  
%  Example Use:
%  ------------
%  check_current_balance('d151',[]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function check_current_balance(cellName, trial_num)
	
	% plot the last trial if no trial was given
	if (isempty(trial_num))
		trial_num = get_last_trial_num(cellName);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Constants
	
	vmemb_axis_limits = [-70 30];
	x_tick_space = 2;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Setup

	if (isempty(trial_num))
		trial_num = get_last_trial_num(cellName);
	end

	sim_times = load(make_file_name(cellName, trial_num, 'time'))'; 

	disp(sprintf('Checking current balance for %s.%d... t=%.2f-%.2f', cellName, trial_num, sim_times(1), sim_times(end)));
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Loop calculating total current at all times
	
	all_i_total = [];
	
	for t = 1 : length(sim_times)
	
		tcheck = sim_times(t);
		
		I_segs = get_neuron_current(cellName, trial_num, tcheck)*1e9; % convert to nA 
		
		total_current = sum(I_segs);
		
%  		disp(sprintf('\tI_tot=%.3e', total_current));
		
		all_i_total = [all_i_total total_current];
	
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Load the detailed data for the soma
	
	soma_data = load(make_file_name(cellName, trial_num, 'dtls', 0.5, {'soma'}));
	
	soma_itotal_col = find_detail_column(cellName, trial_num, 'I_tot');
	soma_vmemb_col = find_detail_column(cellName, trial_num, 'V');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plot
	
	figure(get_next_fig);
	
	subplot(4,1,1);
	plot(sim_times, soma_data(:,soma_vmemb_col),'k');
	ylabel('mV');
	legend('Soma Membrane Potential',2);
	set(gca,'XLim',[round(sim_times(1)) round(sim_times(end))]);
	set(gca,'YLim', vmemb_axis_limits);
	title(sprintf('Check of Current Conservation, %s.%d', cellName, trial_num));
	set(gca,'XTick',[round(sim_times(1)) : x_tick_space: round(sim_times(end))]);
	grid on;
	
	
	subplot(4,1,2);
	hold on;
	plot(sim_times, soma_data(:,soma_itotal_col), 'b');
	plot(sim_times, all_i_total,'r');
	legend({'Total Soma Membrane Current';'Total Cell Membrane Current'},3);
	ylabel('nA');
	set(gca,'XLim',[round(sim_times(1)) round(sim_times(end))]);
	set(gca,'XTick',[round(sim_times(1)) : x_tick_space: round(sim_times(end))]);
	grid on;
	
	subplot(4,1,3);
	plot(sim_times, all_i_total,'k');
	legend('Total Cell Membrane Current (Enlarged)',2);
	ylabel('nA');
	set(gca,'XLim',[round(sim_times(1)) round(sim_times(end))]);
	set(gca,'XTick',[round(sim_times(1)) : x_tick_space: round(sim_times(end))]);
	grid on;
	
	subplot(4,1,4);
	plot(sim_times, abs(100*all_i_total./soma_data(:,soma_itotal_col)'),'k');
	ylabel('%');
	xlabel('ms');
	set(gca,'XLim',[round(sim_times(1)) round(sim_times(end))]);
	legend('|100*(Total/Soma)|',2);
	set(gca,'XTick',[round(sim_times(1)) : x_tick_space: round(sim_times(end))]);
	grid on;
	
	