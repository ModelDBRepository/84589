: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
ASSIGNED {
	ena        (mV)       
	celsius    (degC)
	v          (mV)
	ina        (mA/cm2)
	minf
	mtau
	hinf
	htau
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ina = gbar*(m^exp_m)*(h^exp_h)*(v - ena)
}

INITIAL {

	rates(v)
	m = minf
	h = hinf
}
