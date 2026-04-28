# src/syn.tcl
analyze -format verilog "${TOP_MODULE}.v"
elaborate $TOP_MODULE
current_design $TOP_MODULE

create_clock -name clk -period 10.0 [get_ports clk]

change_names -rules name_rule -hierarchy

compile -map_effort high

report_area > "${TOP_MODULE}_area.log"
report_timing > "${TOP_MODULE}_timing.log"

write -format verilog -hierarchy -output "${TOP_MODULE}_syn.v"
write_sdf "${TOP_MODULE}.sdf"
exit