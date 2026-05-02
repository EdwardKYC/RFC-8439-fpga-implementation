analyze -format verilog {
    Quarter_round.v
    Chacha20.v
    Poly1305.v
    RFC8439.v
}
elaborate $TOP_MODULE
current_design $TOP_MODULE
link
uniquify

set CLK_PERIOD 10.0
create_clock -name clk -period $CLK_PERIOD [get_ports clk]

set_clock_uncertainty 0.2 [get_clocks clk]
set_ideal_network [get_ports clk]

# 設定 I/O 延遲
set_input_delay  1.0 -clock clk [all_inputs]
set_output_delay 1.0 -clock clk [all_outputs]


set_fix_hold [all_clocks]

set_max_area 0

compile -map_effort high

change_names -rules name_rule -hierarchy

# 6. 輸出報告
report_area > "${TOP_MODULE}_area.log"
# [修正] 增加 check_design，幫你檢查是否有沒接好的線
check_design > "${TOP_MODULE}_check.log"
# [修正] 輸出詳細的時序報告 (包含 Setup 與 Hold)
report_timing -path full -delay max > "${TOP_MODULE}_setup_timing.log"
report_timing -path full -delay min > "${TOP_MODULE}_hold_timing.log"

# 7. 輸出結果
write -format verilog -hierarchy -output "${TOP_MODULE}_syn.v"
write_sdf "${TOP_MODULE}.sdf"
write -format ddc -hierarchy -output "${TOP_MODULE}.ddc"

exit