: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
ASSIGNED {
	eca        (mV)       
	celsius    (degC)
	v          (mV)
	ica        (mA/cm2)
	ninf
	ntau
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ica = gbar*(n^exp_n)*(v - eca)
}

INITIAL {

	rates(v)
	n = ninf
}
