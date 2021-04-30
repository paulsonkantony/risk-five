# Cadence Genus(TM) Synthesis Solution, Version 17.21-s010_1, built Feb  7 2018

# Date: Thu Apr 29 16:48:20 2021
# Host: cad54 (x86_64 w/Linux 2.6.32-71.el6.x86_64) (2cores*4cpus*1physical cpu*Intel(R) Core(TM) i3-2120 CPU @ 3.30GHz 3072KB)
# OS:   Red Hat Enterprise Linux Server release 6.0 (Santiago)

set_db library slow.lib
read_sdc mux32four.v
read_hdl mux32four.v
elaborate
read_sdc counter_constraints.g
synthesize -to_mapped -effort medium
report area
report timing
report power
exit
