
The general approach for the Hodgkin-Huxley style ionic channels is to
use the INCLUDE capabilities of NMODL to eliminate redundancy in the
code.  The top level mod files for the HH style channels are: cal.mod,
can.mod, car.mod, cat.mod, hsoma.mod, hdend.mod, kaprox.mod,
kadist.mod, kd.mod, kk.mod, km.mod, naf.mod and nax.mod.  The mod file
itself defines only the NEURON block.  All HH style channels include
the file 'var_funcs.inc' which provide the core formulation of the
kinetics.  Each of the HH mod files also includes either

inact_gate_states.inc, or, 
noinact_gate_states.inc

which provide the appropriate PARAMETER, STATE and DERIVATIVE block
and the rates procedure (appropriate for whether or not there is an
inactivation variable.)

Finally, each of the mod files will include one of the files:

inact_ca_currs.inc 
inact_k_currs.inc 
inact_na_currs.inc 
noinact_k_currs.inc
noinact_ca_currs.inc
noinact_nak_currs.inc 

these define the ASSIGNED, INITIAL and BREAKPOINT blocks appropriate
for the ion(s) and whether or not there is inactivation.  (Note that
at present there are no files 'noinact_na_currs' and 'inact_nak_currs'
because in the present model such currents do not exist.)

The mod files for kc, kahp, and cadifus are standard, with all blocks
declared in a single file.


