: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
ASSIGNED {
	eca        (mV)       
	celsius    (degC)
	v          (mV)
	ica        (mA/cm2)
	minf
	mtau
	hinf
	htau
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ica = gbar*(m^exp_m)*(h^exp_h)*(v - eca)
}

INITIAL {

	rates(v)
	m = minf
	h = hinf
}
