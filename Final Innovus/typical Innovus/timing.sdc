# ####################################################################

#  Created by Genus(TM) Synthesis Solution 17.21-s010_1 on Sun May 02 11:37:23 IST 2021

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000.0fF
set_units -time 1000.0ps

# Set the current design
current_design core

create_clock -name "clk" -period 50.0 -waveform {0.0 25.0} [get_ports clk]
set_clock_transition 0.1 [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_dont_use [get_lib_cells typical/RF1R1WX2]
set_dont_use [get_lib_cells typical/RF2R1WX2]
set_dont_use [get_lib_cells typical/RFRDX1]
set_dont_use [get_lib_cells typical/RFRDX2]
set_dont_use [get_lib_cells typical/RFRDX4]
set_dont_use [get_lib_cells typical/TIEHI]
set_dont_use [get_lib_cells typical/TIELO]
set_clock_uncertainty -setup 0.1 [get_ports clk]
set_clock_uncertainty -hold 0.1 [get_ports clk]
