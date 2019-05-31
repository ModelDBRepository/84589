: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.

TITLE KC
: Ca dependent K current, Ic
: Model from Borg-Graham 1999 & Shao et. al. 1999


NEURON {
	SUFFIX kc
	
	USEION k  READ ek WRITE ik
	USEION ca READ cai
	
	RANGE  gbar
	
	GLOBAL k_oi, vhalf_oi, tmin_oi
	GLOBAL k_ic, vhalf_ic, tmin_ic
	GLOBAL k_oc, vhalf_oc, tmin_oc
	GLOBAL k_co, vhalf_co, tmin_co, tmax_co, alpha_co
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) =	(millimolar)
}

ASSIGNED {

        v       (mV)
	ek      (mV)
        cai	(mM)
	ik	(mA/cm2)
	
	roi	(/ms)
	ric	(/ms)
	roc	(/ms)
	rco	(/ms)

}


: default all params to zero and set them from hoc!


PARAMETER {
        gbar	= 0 (mho/cm2)
	
	k_oi = 0 (mV)
	k_ic = 0 (mV)
	k_co = 0 (mV)
	k_oc = 0 (mV)
	
	vhalf_oi = 0 (mV)
	vhalf_ic = 0 (mV)
	vhalf_co = 0 (mV)
	vhalf_oc = 0 (mV)
	
	tmin_oi = 0 (/ms)
	tmin_ic = 0 (/ms)
	tmin_co = 0 (/ms)
	tmin_oc = 0 (/ms)
	
	tmax_co  = 0 (/ms)
	alpha_co = 0 (/mM/mM/mM)
}

STATE { 
	C
	O
	I
}

BREAKPOINT { 
	SOLVE kin METHOD sparse
	ik = gbar * O * ( v - ek ) 
}

INITIAL {
	SOLVE kin STEADYSTATE sparse
}

KINETIC kin {
	rates(v)
	
	~ C<->O  (rco,roc)
	~ O<->I  (roi,0.0)
	~ I<->C  (ric,0.0)
	
	CONSERVE C + O + I = 1

}

PROCEDURE rates( v(mV)) {

	 roi=rate_tmax_inf( v, vhalf_oi, k_oi, tmin_oi)
	 ric=rate_tmax_inf( v, vhalf_ic, k_ic, tmin_ic)
	 roc=rate_tmax_inf( v, vhalf_oc, k_oc, tmin_oc)
	 
	 
	 rco=rate_tmax_fin( v, vhalf_co, k_co, tmin_co, tmax_co) *alpha_co* cai^3

}


FUNCTION rate_tmax_inf(  v, vhalf, k, tmin) {

        rate_tmax_inf = 1.0/(tmin + exp((vhalf-v)/k))
}


FUNCTION rate_tmax_fin( v, vhalf, k, tmin, tmax ) {
        
	rate_tmax_fin = 1.0/(tmin + 1.0/(  1.0/(tmax-tmin) + exp((v-vhalf)/k) ))
}




