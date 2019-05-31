function undo_trial(cellName)

number = get_last_trial_num(cellName);

reply = input(sprintf('Really delete %s trial %d? Y/N [N]: ', cellName, number),'s');

if (strcmp(reply,'Y'))

	rm_string = sprintf('rm -rf %s',make_file_name(cellName, number, 'pout'));
	
	[status, result] = system(rm_string);
 	disp(sprintf('system: %s got STATUS=%d', rm_string, status));
	
	trial_num_file = make_file_name(cellName, 0, 'trnm', [], {});
	
	s = load(trial_num_file);
	
	fid = fopen(trial_num_file,'w');
	fprintf(fid, '%d',s-1);
	
	fclose(fid);
	disp(sprintf('Decremented trial counter to: %d', s-1));

end