# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DECRYPTION" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DONE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENCRYPTION" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IDLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "KEY_GENERATION" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUTPUT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WAIT_KEY_GEN_LOW" -parent ${Page_0}


}

proc update_PARAM_VALUE.DECRYPTION { PARAM_VALUE.DECRYPTION } {
	# Procedure called to update DECRYPTION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DECRYPTION { PARAM_VALUE.DECRYPTION } {
	# Procedure called to validate DECRYPTION
	return true
}

proc update_PARAM_VALUE.DONE { PARAM_VALUE.DONE } {
	# Procedure called to update DONE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DONE { PARAM_VALUE.DONE } {
	# Procedure called to validate DONE
	return true
}

proc update_PARAM_VALUE.ENCRYPTION { PARAM_VALUE.ENCRYPTION } {
	# Procedure called to update ENCRYPTION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENCRYPTION { PARAM_VALUE.ENCRYPTION } {
	# Procedure called to validate ENCRYPTION
	return true
}

proc update_PARAM_VALUE.IDLE { PARAM_VALUE.IDLE } {
	# Procedure called to update IDLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IDLE { PARAM_VALUE.IDLE } {
	# Procedure called to validate IDLE
	return true
}

proc update_PARAM_VALUE.INPUT { PARAM_VALUE.INPUT } {
	# Procedure called to update INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT { PARAM_VALUE.INPUT } {
	# Procedure called to validate INPUT
	return true
}

proc update_PARAM_VALUE.KEY_GENERATION { PARAM_VALUE.KEY_GENERATION } {
	# Procedure called to update KEY_GENERATION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KEY_GENERATION { PARAM_VALUE.KEY_GENERATION } {
	# Procedure called to validate KEY_GENERATION
	return true
}

proc update_PARAM_VALUE.OUTPUT { PARAM_VALUE.OUTPUT } {
	# Procedure called to update OUTPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT { PARAM_VALUE.OUTPUT } {
	# Procedure called to validate OUTPUT
	return true
}

proc update_PARAM_VALUE.WAIT_KEY_GEN_LOW { PARAM_VALUE.WAIT_KEY_GEN_LOW } {
	# Procedure called to update WAIT_KEY_GEN_LOW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WAIT_KEY_GEN_LOW { PARAM_VALUE.WAIT_KEY_GEN_LOW } {
	# Procedure called to validate WAIT_KEY_GEN_LOW
	return true
}


proc update_MODELPARAM_VALUE.IDLE { MODELPARAM_VALUE.IDLE PARAM_VALUE.IDLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IDLE}] ${MODELPARAM_VALUE.IDLE}
}

proc update_MODELPARAM_VALUE.INPUT { MODELPARAM_VALUE.INPUT PARAM_VALUE.INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT}] ${MODELPARAM_VALUE.INPUT}
}

proc update_MODELPARAM_VALUE.KEY_GENERATION { MODELPARAM_VALUE.KEY_GENERATION PARAM_VALUE.KEY_GENERATION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KEY_GENERATION}] ${MODELPARAM_VALUE.KEY_GENERATION}
}

proc update_MODELPARAM_VALUE.WAIT_KEY_GEN_LOW { MODELPARAM_VALUE.WAIT_KEY_GEN_LOW PARAM_VALUE.WAIT_KEY_GEN_LOW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WAIT_KEY_GEN_LOW}] ${MODELPARAM_VALUE.WAIT_KEY_GEN_LOW}
}

proc update_MODELPARAM_VALUE.ENCRYPTION { MODELPARAM_VALUE.ENCRYPTION PARAM_VALUE.ENCRYPTION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENCRYPTION}] ${MODELPARAM_VALUE.ENCRYPTION}
}

proc update_MODELPARAM_VALUE.DECRYPTION { MODELPARAM_VALUE.DECRYPTION PARAM_VALUE.DECRYPTION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DECRYPTION}] ${MODELPARAM_VALUE.DECRYPTION}
}

proc update_MODELPARAM_VALUE.OUTPUT { MODELPARAM_VALUE.OUTPUT PARAM_VALUE.OUTPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT}] ${MODELPARAM_VALUE.OUTPUT}
}

proc update_MODELPARAM_VALUE.DONE { MODELPARAM_VALUE.DONE PARAM_VALUE.DONE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DONE}] ${MODELPARAM_VALUE.DONE}
}

