: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}


: Initialize everything to zero - they should all be set from the
: hoc code by the "define_param" function that writes the value
: used to a parameter file (no magic numbers, anywhere...)

PARAMETER {
	vhalf_n = 0 (mV)
	vsteep_n = 0 (mV)
	tskew_n = 0 
	tscale_n = 0 (ms)
	toffset_n = 0 (ms)
	exp_n = 0
	
	gbar = 0 (mho/cm2)
}


STATE { n }


DERIVATIVE states {
	rates(v)
	n' = (ninf-n)/ntau
}


PROCEDURE rates(v) {

	ninf = var_inf(v, vhalf_n, vsteep_n)
	ntau =  var_tau(v, vhalf_n, vsteep_n, tskew_n, tscale_n, toffset_n)
}
