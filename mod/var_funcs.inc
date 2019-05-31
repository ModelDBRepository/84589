: Copyright (c) California Institute of Technology, 2006 -- All Rights Reserved
: Royalty free license granted for non-profit research and educational purposes.
FUNCTION var_inf(v(mV), vhalf(mV), vsteep(mV)) { 

	var_inf = 1 / (1 + exp((v - vhalf)/(vsteep))) 

}


FUNCTION var_tau(v (mV), vhalf (mV), vsteep (mV), tskew, tscale(ms), toffset(ms)) {

	var_tau = toffset + (tscale  / ( exp(-tskew*(v-vhalf)/vsteep) * (1+exp((v-vhalf)/vsteep)))  )


}	


