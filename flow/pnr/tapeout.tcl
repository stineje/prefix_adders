# Output GDSII
streamOut final.gds -mapFile ../../sky90_tech/c9fh_3r_innovus.layermap -stripes 1 -units 1000 -mode ALL
saveNetlist -excludeLeafCell final.v

# Run DRC and Connection checks
verifyGeometry
verifyConnectivity -type all -noAntenna

read_activity_file -format VCD -start 0ns -end 1700ns -scope tb/dut ../../outputs/$::env(WIDTH)/$::env(DESIGN)/design.vcd

# Set power analysis flags to dynamic
set_power_analysis_mode -reset
set_power_analysis_mode -disable_static false -write_static_currents true -binary_db_name dynPower.db -create_binary_db true -method dynamic_vectorbased
set_dynamic_power_simulation -reset
set_power_analysis_mode -report_missing_nets true

# Set time-step resolution
set_dynamic_power_simulation -resolution 1ps

# Report power
report_power -outfile average_power_all.rpt

report_area > all_area.txt
