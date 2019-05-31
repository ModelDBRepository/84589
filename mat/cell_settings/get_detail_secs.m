%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get_detail_secs
%  
%  Returns a list of section names corresponding to a description, for a 
%  given cell.  This is used by the plotting function plot_intra_detail in
%  conjunction with get_detail_xs which give the neuron 'x' location of
%  the specific compartment. The basic idea is that it is simply more convenient 
%  to store pre-defined sets of appropriate parameters for each cell here 
%  rather than try to remember them and pass them as a command line argument.  
%  (This is especially the case when you starting plotting multiple cells and 
%  the compartment names will most likely be different for every cell.)  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_secs = get_detail_secs(cellName, plot_desc)


if  (strcmp(cellName, 'd151')==1)

	if (strcmp(plot_desc,'basal')==1)
		plot_secs =  {'soma'; 'basal4_02'; 'basal4_0211'; 'basal4_02112'; 'basal4_02112'};

	elseif (strcmp(plot_desc,'approx')==1)
		plot_secs =  {'soma'; 'apical1_0'; 'apical1_02'; 'apical1_0222';};
		
	elseif (strcmp(plot_desc,'apdist')==1)
		plot_secs =  {  'apical1_02222211'; 'apical1_02222211111';  'apical1_0222221111111'; 'apical1_022222111111111'; 'apical1_02222211111111111'  }; 

	elseif (strcmp(plot_desc,'axon')==1)
		plot_secs =  {'node_05';'node_01'; 'myelin_01';'iseg';'hill';'soma'};
	end
elseif (strcmp(cellName, 'line')==1)
    
	if (strcmp(plot_desc,'all')==1)
        plot_secs = {'basal_50';'basal_49'; 'basal_48'; 'basal_47'; 'basal_46'; 'basal_45'; 'basal_44'; 'basal_43'; 'basal_42'; 'basal_41'; 'basal_40'; 'basal_39'; 'basal_38'; 'basal_37'; 'basal_36'; 'basal_35'; 'basal_34'; 'basal_33'; 'basal_32'; 'basal_31'; 'basal_30'; 'basal_29'; 'basal_28'; 'basal_27'; 'basal_26'; 'basal_25'; 'basal_24'; 'basal_23'; 'basal_22'; 'basal_21'; 'basal_20'; 'basal_19'; 'basal_18'; 'basal_17'; 'basal_16'; 'basal_15'; 'basal_14'; 'basal_13'; 'basal_12'; 'basal_11'; 'basal_10'; 'basal_09'; 'basal_08'; 'basal_07'; 'basal_06'; 'basal_05'; 'basal_04'; 'basal_03'; 'basal_02'; 'basal_01'; 'soma'; 'apical_01'; 'apical_02'; 'apical_03'; 'apical_04'; 'apical_05'; 'apical_06'; 'apical_07'; 'apical_08'; 'apical_09'; 'apical_10'; 'apical_11'; 'apical_12'; 'apical_13'; 'apical_14'; 'apical_15'; 'apical_16'; 'apical_17'; 'apical_18'; 'apical_19'; 'apical_20'; 'apical_21'; 'apical_22'; 'apical_23'; 'apical_24'; 'apical_25'; 'apical_26'; 'apical_27'; 'apical_28'; 'apical_29'; 'apical_30'; 'apical_31'; 'apical_32'; 'apical_33'; 'apical_34'; 'apical_35'; 'apical_36'; 'apical_37'; 'apical_38'; 'apical_39'; 'apical_40'; 'apical_41'; 'apical_42'; 'apical_43'; 'apical_44'; 'apical_45'; 'apical_46'; 'apical_47'; 'apical_48'; 'apical_49'; 'apical_50'};
	elseif (strcmp(plot_desc,'approx')==1)
        	plot_secs = {'soma'; 'apical_04'; 'apical_08'; 'apical_12'; 'apical_16'; 'apical_20'};
	elseif (strcmp(plot_desc,'apdist')==1)
        	plot_secs = { 'apical_25'; 'apical_30'; 'apical_35'; 'apical_40'; 'apical_45'; 'apical_50'};
	elseif (strcmp(plot_desc,'baprox')==1)
        	plot_secs = {'soma'; 'basal_04'; 'basal_08'; 'basal_12'; 'basal_16'; 'basal_20'};
	elseif (strcmp(plot_desc,'badist')==1)
        	plot_secs = { 'basal_25'; 'basal_30'; 'basal_35'; 'basal_40'; 'basal_45'; 'basal_50'};
    end
else
	plot_secs = {'soma'}
end
