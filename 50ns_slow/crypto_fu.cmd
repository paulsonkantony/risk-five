# Cadence Genus(TM) Synthesis Solution, Version 17.21-s010_1, built Feb  7 2018

# Date: Thu Apr 29 17:15:23 2021
# Host: cad54 (x86_64 w/Linux 2.6.32-71.el6.x86_64) (2cores*4cpus*1physical cpu*Intel(R) Core(TM) i3-2120 CPU @ 3.30GHz 3072KB)
# OS:   Red Hat Enterprise Linux Server release 6.0 (Santiago)

set_db library slow.lib
read_hdl {riscv_crypto_fu_saes32_32.v riscv_crypto_fu_sboxes_aes_32.v riscv_crypto_fu_sboxes_sm4_32.v riscv_crypto_fu_ssha256_32.v riscv_crypto_fu_ssha512_32.v riscv_crypto_fu_ssm3_32.v riscv_crypto_fu_ssm4_32.v riscv_crypto_fu_32.v}
elaborate riscv_crypto_fu
read_sdc counter_constraints.g
synthesize -to_mapped -effort medium
report area
report timing
report power
exit
