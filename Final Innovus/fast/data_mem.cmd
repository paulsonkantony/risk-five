# Cadence Genus(TM) Synthesis Solution, Version 17.21-s010_1, built Feb  7 2018

# Date: Fri Apr 30 17:19:55 2021
# Host: cad54 (x86_64 w/Linux 2.6.32-71.el6.x86_64) (2cores*4cpus*1physical cpu*Intel(R) Core(TM) i3-2120 CPU @ 3.30GHz 3072KB)
# OS:   Red Hat Enterprise Linux Server release 6.0 (Santiago)

set_db library fast.lib
read_hdl data_mem.v
elaborate
read_sdc counter_consraints.g
read_sdc counter_constraints.g
synthesize -to_mapped -effort medium
report area
report timing
report power
exit
