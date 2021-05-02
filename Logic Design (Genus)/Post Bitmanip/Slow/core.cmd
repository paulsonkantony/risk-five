# Cadence Genus(TM) Synthesis Solution, Version 17.21-s010_1, built Feb  7 2018

# Date: Fri Apr 30 12:54:02 2021
# Host: cad54 (x86_64 w/Linux 2.6.32-71.el6.x86_64) (2cores*4cpus*1physical cpu*Intel(R) Core(TM) i3-2120 CPU @ 3.30GHz 3072KB)
# OS:   Red Hat Enterprise Linux Server release 6.0 (Santiago)

set_db library slow.lib
read_hdl {add32.v alu.v control_unit.v data_mem.v imm_sx.v insn_mem.v load_stall.v mbr_sx_load.v mbr_sx_store.v mux32four.v mux32three.v mux32two.v program_counter.v register_bank.v riscv_crypto_fu_saes32_32.v riscv_crypto_fu_sboxes_aes_32.v riscv_crypto_fu_sboxes_sm4_32.v riscv_crypto_fu_ssha256_32.v riscv_crypto_fu_ssha512_32.v riscv_crypto_fu_ssm3_32.v riscv_crypto_fu_ssm4_32.v riscv_crypto_fu_32.v rvb_clmul.v rvb_xperm.v bitmanip_top.v core_top.v core.v}
elaborate core
read_sdc counter_constraints.g
synthesize -to_mapped -effort medium
report area
report timing
report power
exit
