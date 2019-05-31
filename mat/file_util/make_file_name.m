%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  make_file_name
%  
%  This function provides a central repository for the names of all the various files
%  that are read by the neuron calculation and plotting scripts.  This is convenient
%  because there are a large number of such files and they may be read/written in 
%  multiple scripts.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fileName = make_file_name(cellName, trial_num, type, params, names)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEURON generated files

% file giving the cell geometry in matlab format
if (type == 'geom')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_geom.dat',get_root_path('output'), cellName,trial_num, cellName, trial_num);

% file containing detailed data for a particular section
elseif (type == 'dtls')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_%s_%.2f.dat',get_root_path('output'), cellName,trial_num, cellName, trial_num, char(names(1)), params(1));

% file listing the different types of currents in the details output files
elseif (type == 'ctyp')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_curr_types.txt',get_root_path('output'), cellName,trial_num, cellName, trial_num);

% file listing all the gate particles of the mechanisms the details output files
elseif (type == 'mgts')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_mech_gates.txt',get_root_path('output'), cellName,trial_num, cellName, trial_num);

% the file with all the parameter names
elseif (type == 'pnam')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_param_names.txt', get_root_path('output'), cellName, trial_num, cellName, trial_num);
	
% the file with all the parameter values
elseif (type == 'pval')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_param_values.dat', get_root_path('output'), cellName, trial_num, cellName, trial_num);

% the name of each section
elseif (type == 'snam')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_secnames.txt', get_root_path('output'), cellName, trial_num, cellName, trial_num);
	
% the number of line segments associate with each section
elseif (type == 'snum')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_secnums.dat', get_root_path('output'), cellName, trial_num, cellName, trial_num);
	
% the file listing all the times that have current data saved
elseif (type == 'time')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_times.dat', get_root_path('output'), cellName, trial_num, cellName, trial_num);
	
% the current data for a specific time
elseif (type == 'tdat')
	fileName = sprintf('%s/%s_%04d/nrn/%s_%04d_t%06.3f.dat', get_root_path('output'), cellName, trial_num, cellName, trial_num, params(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB generated files

% the folder that will contain the output
elseif (type == 'mout')
	fileName = sprintf('%s/%s_%04d/mat',get_root_path('output'), cellName, trial_num); 

% file containing a 2D grid of extracellular voltage calculations
elseif (type == 'vt2d')
	fileName = sprintf('%s/%s_%04d/mat/%s_%04d_x%d,%d_y%d,%d_z%d_g%.1f_t%.2f-%.2f_s%.2f_vt2d.dat', ...
			get_root_path('output'), cellName,trial_num, cellName, trial_num, ...
			params(1), params(2), params(3), params(4), params(5),params(6), params(7), params(8), params(9));

% figure file for 2D grid of EAP's w/ Cell
elseif (type == 'eapg')
	fileName = sprintf('%s/%s_%04d/mat/%s_%04d_eap_grid_z%d_g%d_s%.2f.%s', ...
			get_root_path('output'), cellName, trial_num, cellName, trial_num, params(1), ...
			params(2), params(3), char(names(1)));

% cell with all sections labelled
elseif (type == 'clab')
	fileName = sprintf('%s/%s_%04d/mat/%s_%04d_secnames.%s',get_root_path('output'), ...
			 cellName, trial_num, cellName, trial_num, char(names(1)));
			 
% plot of intracellular details for multiple compartments
elseif (type == 'idts')

	fileName = sprintf('%s/%s_%04d/mat/%s_%04d_intr_%s.%s',get_root_path('output'), cellName, trial_num, cellName, trial_num, char(names(1)), char(names(2)));

% comparison of intracellular action potentials
elseif (type == 'iapc')

	fileName = sprintf('%s/%s_%04d/mat/cells_intra_comp_%s_%s.%s',get_root_path('output'), cellName, trial_num, char(names(1)), char(names(2)) ,char(names(3)) );

% comparison of intracellular action potentials
elseif (type == 'eapc')

	fileName = sprintf('%s/%s_%04d/mat/cells_extra_comp_%s_s%.1f_%d-%d-%d.%s',get_root_path('output'), cellName, trial_num, char(names(1)), params(1), params(2), params(3), params(4) ,char(names(2)) );

elseif (type == 'eapm')

	fileName = sprintf('%s/%s_%04d/mat/%s.%04d_extra_meas_s%.1f_%d-%d-%d.%s', get_root_path('output'), cellName, trial_num, cellName, trial_num, params(1), params(2), params(3), params(4), char(names(1)) );
	
elseif (type == 'mscp')

	fileName = sprintf('%s/%s_%04d/mat/stats_meas_compare_%s_%s.%s', get_root_path('output'), cellName, trial_num,  char(names(1)),   char(names(2)), char(names(3))  );
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Misc. files

% the parent folder of the folder that will contain the output
elseif (type == 'pout')
	fileName = sprintf('%s/%s_%04d',get_root_path('output'), cellName, trial_num); 
	
% the trial number file
elseif (type == 'trnm')
	fileName = sprintf('%s/%s_trial_num.txt', get_root_path('cell'), cellName);
end
