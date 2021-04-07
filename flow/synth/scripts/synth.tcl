#
# OKSTATE Main Synopsys Flow
# Updated Sep 27, 2015 jes
#

# Verilog files
set my_verilog_files [list hdl/$::env(DESIGN).v]

# VHDL files
# set my_vhdl_files [list top.vhd]

# Set toplevel
set my_toplevel adder

# Set number of significant digits
set report_default_significant_digits 6

# V(HDL) Unconnectoed Pins Output
set verilogout_show_unconnected_pins "true"
set vhdlout_show_unconnected_pins "true"

#
# Due to parameterized Verilog must use analyze/elaborate and not 
# read_verilog/vhdl (change to pull in Verilog and/or VHDL)
#
define_design_lib WORK -path ./WORK
analyze -f sverilog -lib WORK $my_verilog_files

#
# Added if you had any VHDL
# analyze -f vhdl -lib WORK $my_vhdl_files
#
elaborate $my_toplevel -lib WORK 

# Set the current_design 
current_design $my_toplevel
link

# Reset all constraints 
reset_design

# Set Frequency in [MHz] or [ps]
set my_clk vclk
set my_uncertainty 0.0

if { [string first "ware" $::env(DESIGN)]!=-1 } {
    if { $::env(WIDTH)=="32" } {
        set my_period 0.34
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 0.39
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 0.44
    }
} elseif { [string first "ripple" $::env(DESIGN)]!=-1 } {
    if { $::env(WIDTH)=="32" } {
        set my_period 1.6
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 3.2
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 6.4
    }
} else {
    if { $::env(WIDTH)=="32" } {
        set my_period 0.37
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 0.42
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 0.47
    }
}

# Partitioning - flatten or hierarchically synthesize
#ungroup -flatten -simple_names { dp* }
#ungroup -flatten -simple_names { c* }
#ungroup -all -flatten -simple_names

create_clock -period $my_period -name $my_clk
set all_in_ex_clk [remove_from_collection [all_inputs] [get_ports $my_clk]]
set_propagated_clock [get_clocks $my_clk]

# Setting constraints on input ports 
set_driving_cell  -lib_cell scc9gena_dfxbp_1 -pin Q $all_in_ex_clk

# Set input/output delay
set_input_delay 0.0 -max -clock $my_clk $all_in_ex_clk
set_output_delay 0.0 -max -clock $my_clk [all_outputs]

# Setting load constraint on output ports 
set_load [expr [load_of scc9gena_tt_1.2v_25C/scc9gena_dfxbp_1/D] * 1] [all_outputs]

# Set the wire load model 
set_wire_load_mode "top"

# Attempt Area Recovery - if looking for minimal area
# set_max_area 2000

# Deal with constants and buffers to isolate ports
set_fix_multiple_port_nets -all -buffer_constants

# setting up the group paths to find out the required timings
#group_path -name OUTPUTS -to [all_outputs]
#group_path -name INPUTS -from [all_inputs] 
#group_path -name COMBO -from [all_inputs] -to [all_outputs]

# Save Unmapped Design
set filename [format "%s%s%s"  "unmapped/" $my_toplevel ".ddc"]
write_file -format ddc -hierarchy -o $filename

# Compile statements - either compile or compile_ultra
# compile -scan -incr -map_effort high
compile_ultra -no_seq_output_inversion -no_boundary_optimization

# Eliminate need for assign statements (yuck!)
set verilogout_no_tri true
set verilogout_equation false

# setting to generate output files
set write_v    1        ;# generates structual netlist
set write_sdc  1	;# generates synopsys design constraint file for p&r
set write_ddc  1	;# compiler file in ddc format
set write_sdf  1	;# sdf file for backannotated timing sim
set write_pow  1 	;# genrates estimated power report
set write_rep  1	;# generates estimated area and timing report
set write_cst  1        ;# generate report of constraints
set write_hier 1        ;# generate hierarchy report

# Report Constraint Violators
set filename [format "%s%s%s"  "reports/" $my_toplevel "_constraint_all_violators.rpt"]
redirect $filename {report_constraint -all_violators}

# Check design
redirect reports/check_design.rpt { check_design }

# Report Final Netlist (Hierarchical)
set filename [format "%s%s%s"  "mapped/" $my_toplevel ".vh"]
write_file -f verilog -hierarchy -output $filename

set filename [format "%s%s%s"  "mapped/" $my_toplevel ".sdc"]
write_sdc $filename

set filename [format "%s%s%s"  "mapped/" $my_toplevel ".ddc"]
write_file -format ddc -hierarchy -o $filename

set filename [format "%s%s%s"  "mapped/" $my_toplevel ".sdf"]
write_sdf $filename

# QoR
set filename [format "%s%s%s"  "reports/" $my_toplevel "_qor.rep"]
redirect $filename { report_qor }

# Report Timing
set filename [format "%s%s%s"  "reports/" $my_toplevel "_reportpath.rep"]
redirect $filename { report_path_group }

set filename [format "%s%s%s"  "reports/" $my_toplevel "_report_clock.rep"]
redirect $filename { report_clock }

set filename [format "%s%s%s" "reports/" $my_toplevel "_timing.rep"]
redirect $filename { report_timing -capacitance -transition_time -nets -nworst 10 }

set filename [format "%s%s%s" "reports/" $my_toplevel "_min_timing.rep"]
redirect $filename { report_timing -delay min }

set filename [format "%s%s%s" "reports/" $my_toplevel "_area.rep"]
redirect $filename { report_area -hierarchy -nosplit -physical -designware}

set filename [format "%s%s%s" "reports/" $my_toplevel "_cell.rep"]
redirect $filename { report_cell [get_cells -hier *] }

set filename [format "%s%s%s" "reports/" $my_toplevel "_power.rep"]
redirect $filename { report_power }

set filename [format "%s%s%s" "reports/" $my_toplevel "_constraint.rep"]
redirect $filename { report_constraint }

set filename [format "%s%s%s" "reports/" $my_toplevel "_hier.rep"]
redirect $filename { report_hierarchy }

# Quit
quit

