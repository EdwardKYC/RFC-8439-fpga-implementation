set_property SRC_FILE_INFO {cfile:c:/code/RFC-8439-fpga-implementation/AES-Cam-on-PYNQ-Z2-main/AES-Cam-on-PYNQ-Z2-main/AES_SYS/AES_SYS.gen/sources_1/bd/AES_SYS/ip/AES_SYS_clk_wiz_0_0/AES_SYS_clk_wiz_0_0.xdc rfile:../../../AES_SYS.gen/sources_1/bd/AES_SYS/ip/AES_SYS_clk_wiz_0_0/AES_SYS_clk_wiz_0_0.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.200
