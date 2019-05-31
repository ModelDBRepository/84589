: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
ASSIGNED {
	ek        (mV)       :k reversal potential (also reset in
	celsius    (degC)
	v          (mV)
	ik        (mA/cm2)
	minf
	mtau
	hinf
	htau
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ik = gbar*(m^exp_m)*(h^exp_h)*(v - ek)
}

INITIAL {

	rates(v)
	m = minf
	h = hinf
}
