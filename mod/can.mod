: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.


TITLE CAN


NEURON {
	SUFFIX can
	USEION ca READ eca WRITE ica
	RANGE gbar
	RANGE minf, mtau, hinf, htau

	GLOBAL vhalf_m, vsteep_m, exp_m
	GLOBAL tskew_m, tscale_m, toffset_m 
	
	GLOBAL vhalf_h, vsteep_h, exp_h
	GLOBAL tskew_h, tscale_h, toffset_h 
}

INCLUDE "inact_ca_currs.inc"

INCLUDE "inact_gate_states.inc"

INCLUDE "var_funcs.inc"
