%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  diff_neuron_params
%  
%  This very useful script compares the params used in two separate  neuron simulation
%  trials.  The result is listed on the screen and compares all parameters that 
%  differ between the two.  It also has logic to note when a parameter was defined
%  in one simulation but not another and when a parameter was multiply defined.  This
%  relies on the list of parameters output in the param_names and param_values produced
%  by the NEURON program.  Naturally this will only work for parameters that are 
%  defined through the define_param utility in the NEURON code (so don't define
%  any additional parameters without using the utility!)
%  
%  This script uses 'nargin' to provide some useful default cases:
%  1) If only a single cell name parameter is provided the script compares the two
%     most recent trials for that cell
%  2) If a single cell name and trial number are provided the script compares the
%     most recent trial for that cell with the trial number provided
%
%  Example Use:
%  -------------
%  Comparing the last two trials...
%  diff_neuron_params('d151')
%
%  Comparing the last trial and any earlier trial...
%  diff_neuron_params('d151', 10)
%
%  Comparing any two arbitrary trials for two arbitrary cells...
%  diff_neuron_params('d151', 13, 'd11221', 30)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  value = diff_neuron_params(cell1, trial1, cell2, trial2)

if (nargin ==1)
	cell2 = cell1;
	trial1 = get_last_trial_num(cell1);
	trial2 = trial1-1;
end

if (nargin == 2)
	cell2 = cell1;
	trial2 = get_last_trial_num(cell1);
end


% TODO: if a param is not defined for one cell/trial, and it is multiply defined
% in the other cell/trial, this logic will not catch the multiple definition...

	paramsFile_1  = make_file_name(cell1, trial1, 'pnam');
	valuesFile_1 = make_file_name(cell1, trial1, 'pval');

	params_1 = textread(paramsFile_1,'%s');
	values_1 = load(valuesFile_1);

	paramsFile_2  = make_file_name(cell2, trial2, 'pnam');
	valuesFile_2 = make_file_name(cell2, trial2, 'pval');

	params_2 = textread(paramsFile_2,'%s');
	values_2 = load(valuesFile_2);

	
	no_match_params = [];
	no_match_values = [];
	max_param_length = 0;

	for n = 1 : size(params_1,1)

		% do this check in case params are in different order
		index_2 = find(strcmp(params_1(n),params_2));

		value_1 = values_1(n);

		if (~isempty(index_2) & length(index_2)==1)
			value_2 = values_2(index_2);
		else
			value_2 = nan;

			if (isempty(index_2))
%  				disp(sprintf('*** %s is NOT defined in %s.%d',char(params_1(n)), cell2,trial2));
			elseif (length(index_2) > 1)
				disp(sprintf('*** %s is MULTIPLY defined in %s.%d',char(params_1(n)), cell2,trial2));
			end
		end

		if (value_1 ~= value_2)
			no_match_params = [no_match_params; params_1(n)];
			no_match_values = [no_match_values; value_1 value_2];

			if (length(char(params_1(n)) ) > max_param_length)
				max_param_length = length(char(params_1(n)));
			end
		end

	end

	
	for n = 1 : size(params_2,1)

		% do this check in case params are in different order
		index_1 = find(strcmp(params_2(n),params_1));

		value_2 = values_2(n);

		if (~isempty(index_1) & length(index_1)==1)
			value_1 = values_1(index_1);
		else
			value_1 = nan;

			if (isempty(index_1))
%  				disp(sprintf('*** %s is NOT defined in %s.%d',char(params_2(n)), cell1,trial1));
			elseif (length(index_1) > 1)
				disp(sprintf('*** %s is MULTIPLY defined in %s.%d',char(params_2(n)), cell1,trial1));
			end
		end

		if (value_1 ~= value_2)

			in_list = find(strcmp(params_2(n),no_match_params));

			if (isempty(in_list))

				no_match_params = [no_match_params; params_2(n)];
				no_match_values = [no_match_values; value_1 value_2];

				if (length(char(params_2(n)) ) > max_param_length)
					max_param_length = length(char(params_2(n)));
				end
			
			end
		end

	end
	
	




	line_format_string = sprintf('%%%ds  %%10.5g  %%10.5g',max_param_length+3);
	header_format_string = sprintf('%%%ds  -  %%s.%%d   -  %%s.%%d',max_param_length+3);

	disp(sprintf('\n'));
	disp(sprintf(header_format_string, 'PARAM',cell1, trial1, cell2, trial2));
	disp('------------------------------------------------------------');

	for n = 1 : size(no_match_params,1)
		disp(sprintf(line_format_string,char(no_match_params(n)), no_match_values(n,1), no_match_values(n,2)));
	end