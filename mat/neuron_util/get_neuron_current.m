%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_neuron_current
%  
%  This scripts the load the line segment current data for a single cell, trial, and
%  time.  It then converts it from nA to Amps.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I_segs = get_neuron_current(cellName, trial, time)


I_segs = load(make_file_name(cellName, trial, 'tdat', [time]));

% Currents from NEURON are in nano-amps
% we convert it to amps for the voltage calculation
I_segs = I_segs * 1e-9;

