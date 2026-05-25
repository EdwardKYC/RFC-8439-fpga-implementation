// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Jun 12 01:43:25 2025
// Host        : DESKTOP-8UU9KV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ AES_SYS_AES_0_0_stub.v
// Design      : AES_SYS_AES_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "AES,Vivado 2023.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, nrst, start, enc_dec, data_in, key_in, 
  key_gen_start, key_gen_Done, data_out, addr, write_en, done)
/* synthesis syn_black_box black_box_pad_pin="nrst,start,enc_dec,data_in[31:0],key_in[127:0],key_gen_start,key_gen_Done,data_out[31:0],addr[31:0],write_en[3:0],done" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input nrst;
  input start;
  input enc_dec;
  input [31:0]data_in;
  input [127:0]key_in;
  input key_gen_start;
  output key_gen_Done;
  output [31:0]data_out;
  output [31:0]addr;
  output [3:0]write_en;
  output done;
endmodule
