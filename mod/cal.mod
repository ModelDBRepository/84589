: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.


TITLE CAL


NEURON {
	SUFFIX cal
	USEION ca READ eca WRITE ica
	RANGE gbar
	RANGE ninf, ntau

	GLOBAL vhalf_n, vsteep_n, exp_n 
	GLOBAL tskew_n, tscale_n, toffset_n 
	
}


INCLUDE "noinact_ca_currs.inc"

INCLUDE "noinact_gate_states.inc"

INCLUDE "var_funcs.inc"
