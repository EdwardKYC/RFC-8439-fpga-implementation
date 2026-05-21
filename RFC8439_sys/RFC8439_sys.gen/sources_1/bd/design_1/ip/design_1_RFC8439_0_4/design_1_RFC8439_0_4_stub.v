// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Fri May 22 02:31:07 2026
// Host        : LAPTOP-9PRMHLIN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/RFC-8439-fpga-implementation/RFC8439_sys/RFC8439_sys.gen/sources_1/bd/design_1/ip/design_1_RFC8439_0_4/design_1_RFC8439_0_4_stub.v
// Design      : design_1_RFC8439_0_4
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "RFC8439,Vivado 2023.2" *)
module design_1_RFC8439_0_4(clk, rst, start, mode_decrypt, done, mac_error, 
  msg_length, ad_length, Src_RAM_addr, Src_RAM_en, Src_RAM_we, Src_RAM_D, Src_RAM_Q, 
  Dst_RAM_addr, Dst_RAM_en, Dst_RAM_we, Dst_RAM_D, Dst_RAM_Q)
/* synthesis syn_black_box black_box_pad_pin="rst,start,mode_decrypt,done,mac_error,msg_length[31:0],ad_length[31:0],Src_RAM_addr[31:0],Src_RAM_en,Src_RAM_we[3:0],Src_RAM_D[31:0],Src_RAM_Q[31:0],Dst_RAM_addr[31:0],Dst_RAM_en,Dst_RAM_we[3:0],Dst_RAM_D[31:0],Dst_RAM_Q[31:0]" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input rst;
  input start;
  input mode_decrypt;
  output done;
  output mac_error;
  input [31:0]msg_length;
  input [31:0]ad_length;
  output [31:0]Src_RAM_addr;
  output Src_RAM_en;
  output [3:0]Src_RAM_we;
  output [31:0]Src_RAM_D;
  input [31:0]Src_RAM_Q;
  output [31:0]Dst_RAM_addr;
  output Dst_RAM_en;
  output [3:0]Dst_RAM_we;
  output [31:0]Dst_RAM_D;
  input [31:0]Dst_RAM_Q;
endmodule
