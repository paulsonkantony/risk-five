if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name max_timing\
   -timing\
    [list ${::IMEX::libVar}/lib/typ/slow.lib]
create_library_set -name min_timing\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast.lib]
create_rc_corner -name default_rc_corner\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0
create_delay_corner -name min\
   -library_set min_timing
create_delay_corner -name max\
   -library_set max_timing
create_constraint_mode -name constraints_top\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/constraints_top/constraints_top.sdc]
create_analysis_view -name worst -constraint_mode constraints_top -delay_corner max -latency_file ${::IMEX::dataVar}/mmmc/views/worst/latency.sdc
create_analysis_view -name best -constraint_mode constraints_top -delay_corner min -latency_file ${::IMEX::dataVar}/mmmc/views/best/latency.sdc
set_analysis_view -setup [list worst] -hold [list best]
