%  Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
%  Royalty free license granted for non-profit research and educational purposes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define_measure_columns
%
%  Defines which columns to use for which measure and the associated names
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% COLUMN CONSTANTS

NA_PEAK_COL           = 1;
NAP_WIDTH_COL          = 2;
CAP_PEAK_COL          = 3;
CAP_RATIO_COL         = 4;
MAX_CAP_DERIV_COL     = 5;
CAP_NA_TIME_COL       = 6;
K_PEAK_COL            = 7;
K_RATIO_COL           = 8;
NA_K_TIME_COL         = 9;
CAP_K_TIME_COL        = 10;
K_PHASE_EXP_COL       = 11;
K_DECAY_COL           = 12;
MAX_REPOL_DERIV_COL   = 13;
MIN_REPOL_DERIV_COL   = 14;

NUM_STAT_COLS = 14;

column_names = {'Na+ Peak';'Na+ Peak Width'; 'Cap. Peak';'Cap. Ratio'; 'Cap. Max. Deriv.'; 'Cap. -> Na. Time'; 'K+ Peak';'K+ Ratio'; 'Na -> K Time'; 'Cap -> K Time'; 'K Phase Exp. Fit'; 'K Decay Tau'; 'Max. Repol. Deriv.'; 'Min Repol. Deriv.'};

column_abrevs = {'nap';'width';'cpp';'cpr';'cpd';'cnt';'kp';'kpr';'nkt';'ckt';'kpe';'kdt';'mard';'mird';};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% These are specific to the comparison plots

AVG_COL = 1;
SD_COL  = 2;
MIN_COL = 3;
MAX_COL = 4;