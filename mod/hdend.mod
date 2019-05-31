: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.

TITLE HDEND

NEURON {
	SUFFIX hdend
	USEION na READ ena WRITE ina
	USEION k  READ ek  WRITE ik
	RANGE gbar
	RANGE ninf, ntau

	GLOBAL vhalf_n, vsteep_n, exp_n 
	GLOBAL tskew_n, tscale_n, toffset_n 

}

INCLUDE "noinact_nak_currs.inc"

INCLUDE "noinact_gate_states.inc"

INCLUDE "var_funcs.inc"


