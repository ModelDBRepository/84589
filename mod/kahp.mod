: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.

TITLE KAHP

NEURON {
	SUFFIX kahp
	USEION k READ ek WRITE ik
	USEION ca READ cai
	
	RANGE gbar
	RANGE ninf, ntau

	GLOBAL alpha_n, beta_n 
	GLOBAL toffset_n, exp_n
	GLOBAL exp_ca
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

ASSIGNED {
	ek        (mV)      
	v          (mV)
	ik        (mA/cm2)
	cai	  (mM)
	ninf
	ntau      (/ms)
	exp_n
	exp_ca
}

: Initialize everything to zero - they should all be set from the
: hoc code by the "define_param" function that writes the value
: used to a parameter file (no magic numbers, anywhere...)

PARAMETER {
	alpha_n = 0 (/ms/mM^4)
	beta_n = 0 (/ms)

	toffset_n = 0 (ms)

	gbar = 0 (mho/cm2)
}




STATE {
	n
}


BREAKPOINT {
	rates(v)
	SOLVE states METHOD cnexp
	ik = gbar*do_exp(n,exp_n)*(v - ek)
}

INITIAL {

	rates(v)
	n = ninf
	ik = gbar*do_exp(n, exp_n)*(v - ek)
}

DERIVATIVE states {

	n' = (ninf-n)/ntau
}


PROCEDURE rates(v) {

	LOCAL  cai_to_power
	
	cai_to_power = do_exp(cai,exp_ca)

	ninf = (alpha_n*cai_to_power)/(alpha_n*cai_to_power + beta_n)

	ntau =  1/(alpha_n*cai_to_power + beta_n) + toffset_n
}

	

FUNCTION do_exp(var,gexp) {

	do_exp = 1.0
	
	FROM i = 1 TO gexp {
		do_exp = do_exp * var
	} 

}
