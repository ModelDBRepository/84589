%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_neuron_param_value
%  
%  This script will load the value of the specified parameter for a specific neuron
%  trial.  This is done by checking the list of parameters output in the param_names 
%  and param_values produced by the NEURON program.  Naturally this will only work 
%  for parameters that are defined through the define_param utility in the NEURON 
%  code (so don't define any additional parameters without using the utility!)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  value = get_neuron_param_value(param, cellName, trial)

	namesFile = make_file_name(cellName, trial, 'pnam');
	valuesFile = make_file_name(cellName, trial, 'pval');

	names = textread(namesFile,'%s');
	values = load(valuesFile);

	if (strcmp(param,'gna_avg')==1)

		index = find(strcmp(names,'gna_default'));
		gna_default = values(index);

		index = find(strcmp(names,'gna_default_max_apical_ratio'));
		gna_max_ratio =  values(index);
		
		
		index = find(strcmp(names,'gna_default_min_apical_ratio'));
		gna_min_ratio =  values(index);

		value = gna_default * (1.0 + gna_max_ratio + gna_min_ratio)/3;
		disp(sprintf('gna_avg = %f *(1 + %f + %f)=%f', gna_default, gna_max_ratio, gna_min_ratio, value));

	else


		index = find(strcmp(names,param));

		if (isempty(index))
			disp(sprintf('param %s NOT FOUND in %s', param, namesFile));
		end

		value = values(index);

	end