// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Jun 12 01:59:49 2025
// Host        : DESKTOP-8UU9KV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ AES_SYS_AES_0_0_sim_netlist.v
// Design      : AES_SYS_AES_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_AES
   (key_gen_Done,
    done,
    write_en,
    data_out,
    addr,
    clk,
    start,
    key_gen_start,
    nrst,
    enc_dec);
  output key_gen_Done;
  output done;
  output [0:0]write_en;
  output [9:0]data_out;
  output [29:0]addr;
  input clk;
  input start;
  input key_gen_start;
  input nrst;
  input enc_dec;

  wire \FSM_onehot_state[0]_i_1_n_0 ;
  wire \FSM_onehot_state[1]_i_1_n_0 ;
  wire \FSM_onehot_state[2]_i_1_n_0 ;
  wire \FSM_onehot_state[2]_i_2_n_0 ;
  wire \FSM_onehot_state[3]_i_1_n_0 ;
  wire \FSM_onehot_state[3]_i_2_n_0 ;
  wire \FSM_onehot_state[3]_i_3_n_0 ;
  wire \FSM_onehot_state[4]_i_1_n_0 ;
  wire \FSM_onehot_state[4]_i_2_n_0 ;
  wire \FSM_onehot_state[4]_i_3_n_0 ;
  wire \FSM_onehot_state[5]_i_1_n_0 ;
  wire \FSM_onehot_state[5]_i_2_n_0 ;
  wire \FSM_onehot_state[6]_i_10_n_0 ;
  wire \FSM_onehot_state[6]_i_11_n_0 ;
  wire \FSM_onehot_state[6]_i_1_n_0 ;
  wire \FSM_onehot_state[6]_i_2_n_0 ;
  wire \FSM_onehot_state[6]_i_3_n_0 ;
  wire \FSM_onehot_state[6]_i_4_n_0 ;
  wire \FSM_onehot_state[6]_i_5_n_0 ;
  wire \FSM_onehot_state[6]_i_6_n_0 ;
  wire \FSM_onehot_state[6]_i_7_n_0 ;
  wire \FSM_onehot_state[6]_i_8_n_0 ;
  wire \FSM_onehot_state[6]_i_9_n_0 ;
  wire \FSM_onehot_state_reg_n_0_[0] ;
  wire \FSM_onehot_state_reg_n_0_[2] ;
  wire \FSM_onehot_state_reg_n_0_[3] ;
  wire \FSM_onehot_state_reg_n_0_[5] ;
  wire [29:0]addr;
  wire addr_in;
  wire addr_in1;
  wire \addr_in[0]_i_1_n_0 ;
  wire \addr_in[0]_i_4_n_0 ;
  wire \addr_in[0]_i_5_n_0 ;
  wire \addr_in[0]_i_6_n_0 ;
  wire \addr_in[0]_i_7_n_0 ;
  wire \addr_in[12]_i_2_n_0 ;
  wire \addr_in[12]_i_3_n_0 ;
  wire \addr_in[12]_i_4_n_0 ;
  wire \addr_in[12]_i_5_n_0 ;
  wire \addr_in[16]_i_2_n_0 ;
  wire \addr_in[16]_i_3_n_0 ;
  wire \addr_in[16]_i_4_n_0 ;
  wire \addr_in[16]_i_5_n_0 ;
  wire \addr_in[20]_i_2_n_0 ;
  wire \addr_in[20]_i_3_n_0 ;
  wire \addr_in[20]_i_4_n_0 ;
  wire \addr_in[20]_i_5_n_0 ;
  wire \addr_in[24]_i_2_n_0 ;
  wire \addr_in[24]_i_3_n_0 ;
  wire \addr_in[24]_i_4_n_0 ;
  wire \addr_in[24]_i_5_n_0 ;
  wire \addr_in[28]_i_2_n_0 ;
  wire \addr_in[28]_i_3_n_0 ;
  wire \addr_in[4]_i_2_n_0 ;
  wire \addr_in[4]_i_3_n_0 ;
  wire \addr_in[4]_i_4_n_0 ;
  wire \addr_in[4]_i_5_n_0 ;
  wire \addr_in[8]_i_2_n_0 ;
  wire \addr_in[8]_i_3_n_0 ;
  wire \addr_in[8]_i_4_n_0 ;
  wire \addr_in[8]_i_5_n_0 ;
  wire [29:0]addr_in_reg;
  wire \addr_in_reg[0]_i_2_n_0 ;
  wire \addr_in_reg[0]_i_2_n_1 ;
  wire \addr_in_reg[0]_i_2_n_2 ;
  wire \addr_in_reg[0]_i_2_n_3 ;
  wire \addr_in_reg[0]_i_2_n_4 ;
  wire \addr_in_reg[0]_i_2_n_5 ;
  wire \addr_in_reg[0]_i_2_n_6 ;
  wire \addr_in_reg[0]_i_2_n_7 ;
  wire \addr_in_reg[12]_i_1_n_0 ;
  wire \addr_in_reg[12]_i_1_n_1 ;
  wire \addr_in_reg[12]_i_1_n_2 ;
  wire \addr_in_reg[12]_i_1_n_3 ;
  wire \addr_in_reg[12]_i_1_n_4 ;
  wire \addr_in_reg[12]_i_1_n_5 ;
  wire \addr_in_reg[12]_i_1_n_6 ;
  wire \addr_in_reg[12]_i_1_n_7 ;
  wire \addr_in_reg[16]_i_1_n_0 ;
  wire \addr_in_reg[16]_i_1_n_1 ;
  wire \addr_in_reg[16]_i_1_n_2 ;
  wire \addr_in_reg[16]_i_1_n_3 ;
  wire \addr_in_reg[16]_i_1_n_4 ;
  wire \addr_in_reg[16]_i_1_n_5 ;
  wire \addr_in_reg[16]_i_1_n_6 ;
  wire \addr_in_reg[16]_i_1_n_7 ;
  wire \addr_in_reg[20]_i_1_n_0 ;
  wire \addr_in_reg[20]_i_1_n_1 ;
  wire \addr_in_reg[20]_i_1_n_2 ;
  wire \addr_in_reg[20]_i_1_n_3 ;
  wire \addr_in_reg[20]_i_1_n_4 ;
  wire \addr_in_reg[20]_i_1_n_5 ;
  wire \addr_in_reg[20]_i_1_n_6 ;
  wire \addr_in_reg[20]_i_1_n_7 ;
  wire \addr_in_reg[24]_i_1_n_0 ;
  wire \addr_in_reg[24]_i_1_n_1 ;
  wire \addr_in_reg[24]_i_1_n_2 ;
  wire \addr_in_reg[24]_i_1_n_3 ;
  wire \addr_in_reg[24]_i_1_n_4 ;
  wire \addr_in_reg[24]_i_1_n_5 ;
  wire \addr_in_reg[24]_i_1_n_6 ;
  wire \addr_in_reg[24]_i_1_n_7 ;
  wire \addr_in_reg[28]_i_1_n_3 ;
  wire \addr_in_reg[28]_i_1_n_6 ;
  wire \addr_in_reg[28]_i_1_n_7 ;
  wire \addr_in_reg[4]_i_1_n_0 ;
  wire \addr_in_reg[4]_i_1_n_1 ;
  wire \addr_in_reg[4]_i_1_n_2 ;
  wire \addr_in_reg[4]_i_1_n_3 ;
  wire \addr_in_reg[4]_i_1_n_4 ;
  wire \addr_in_reg[4]_i_1_n_5 ;
  wire \addr_in_reg[4]_i_1_n_6 ;
  wire \addr_in_reg[4]_i_1_n_7 ;
  wire \addr_in_reg[8]_i_1_n_0 ;
  wire \addr_in_reg[8]_i_1_n_1 ;
  wire \addr_in_reg[8]_i_1_n_2 ;
  wire \addr_in_reg[8]_i_1_n_3 ;
  wire \addr_in_reg[8]_i_1_n_4 ;
  wire \addr_in_reg[8]_i_1_n_5 ;
  wire \addr_in_reg[8]_i_1_n_6 ;
  wire \addr_in_reg[8]_i_1_n_7 ;
  wire [31:1]addr_out;
  wire \addr_out[0]_i_1_n_0 ;
  wire \addr_out[31]_i_1_n_0 ;
  wire \addr_out_reg[12]_i_2_n_0 ;
  wire \addr_out_reg[12]_i_2_n_1 ;
  wire \addr_out_reg[12]_i_2_n_2 ;
  wire \addr_out_reg[12]_i_2_n_3 ;
  wire \addr_out_reg[16]_i_2_n_0 ;
  wire \addr_out_reg[16]_i_2_n_1 ;
  wire \addr_out_reg[16]_i_2_n_2 ;
  wire \addr_out_reg[16]_i_2_n_3 ;
  wire \addr_out_reg[20]_i_2_n_0 ;
  wire \addr_out_reg[20]_i_2_n_1 ;
  wire \addr_out_reg[20]_i_2_n_2 ;
  wire \addr_out_reg[20]_i_2_n_3 ;
  wire \addr_out_reg[24]_i_2_n_0 ;
  wire \addr_out_reg[24]_i_2_n_1 ;
  wire \addr_out_reg[24]_i_2_n_2 ;
  wire \addr_out_reg[24]_i_2_n_3 ;
  wire \addr_out_reg[28]_i_2_n_0 ;
  wire \addr_out_reg[28]_i_2_n_1 ;
  wire \addr_out_reg[28]_i_2_n_2 ;
  wire \addr_out_reg[28]_i_2_n_3 ;
  wire \addr_out_reg[31]_i_3_n_2 ;
  wire \addr_out_reg[31]_i_3_n_3 ;
  wire \addr_out_reg[4]_i_2_n_0 ;
  wire \addr_out_reg[4]_i_2_n_1 ;
  wire \addr_out_reg[4]_i_2_n_2 ;
  wire \addr_out_reg[4]_i_2_n_3 ;
  wire \addr_out_reg[8]_i_2_n_0 ;
  wire \addr_out_reg[8]_i_2_n_1 ;
  wire \addr_out_reg[8]_i_2_n_2 ;
  wire \addr_out_reg[8]_i_2_n_3 ;
  wire \addr_out_reg_n_0_[30] ;
  wire \addr_out_reg_n_0_[31] ;
  wire clk;
  wire \cnt[0]_i_1_n_0 ;
  wire \cnt[1]_i_1_n_0 ;
  wire \cnt[2]_i_1_n_0 ;
  wire \cnt_reg_n_0_[0] ;
  wire \cnt_reg_n_0_[1] ;
  wire \cnt_reg_n_0_[2] ;
  wire [9:0]data_out;
  wire done;
  wire enc_dec;
  wire [31:1]in11;
  wire key_expansion_counter;
  wire \key_expansion_counter[0]_i_1_n_0 ;
  wire \key_expansion_counter[1]_i_1_n_0 ;
  wire \key_expansion_counter[2]_i_1_n_0 ;
  wire \key_expansion_counter[3]_i_1_n_0 ;
  wire \key_expansion_counter_reg_n_0_[0] ;
  wire \key_expansion_counter_reg_n_0_[1] ;
  wire \key_expansion_counter_reg_n_0_[2] ;
  wire \key_expansion_counter_reg_n_0_[3] ;
  wire key_gen_Done;
  wire key_gen_Done_i_1_n_0;
  wire key_gen_Done_i_2_n_0;
  wire key_gen_start;
  wire nrst;
  wire [31:2]p_0_in;
  wire round_counter;
  wire [3:0]round_counter0_in;
  wire \round_counter_reg_n_0_[0] ;
  wire \round_counter_reg_n_0_[1] ;
  wire \round_counter_reg_n_0_[2] ;
  wire \round_counter_reg_n_0_[3] ;
  wire start;
  wire [0:0]write_en;
  wire [3:1]\NLW_addr_in_reg[28]_i_1_CO_UNCONNECTED ;
  wire [3:2]\NLW_addr_in_reg[28]_i_1_O_UNCONNECTED ;
  wire [3:2]\NLW_addr_out_reg[31]_i_3_CO_UNCONNECTED ;
  wire [3:3]\NLW_addr_out_reg[31]_i_3_O_UNCONNECTED ;

  LUT5 #(
    .INIT(32'h0A0ACFCE)) 
    \FSM_onehot_state[0]_i_1 
       (.I0(addr_in),
        .I1(\FSM_onehot_state_reg_n_0_[2] ),
        .I2(start),
        .I3(\FSM_onehot_state_reg_n_0_[0] ),
        .I4(key_gen_start),
        .O(\FSM_onehot_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hF888)) 
    \FSM_onehot_state[1]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[0] ),
        .I1(key_gen_start),
        .I2(key_expansion_counter),
        .I3(\FSM_onehot_state[2]_i_2_n_0 ),
        .O(\FSM_onehot_state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hF444)) 
    \FSM_onehot_state[2]_i_1 
       (.I0(\FSM_onehot_state[2]_i_2_n_0 ),
        .I1(key_expansion_counter),
        .I2(\FSM_onehot_state_reg_n_0_[2] ),
        .I3(key_gen_start),
        .O(\FSM_onehot_state[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'hFFDF)) 
    \FSM_onehot_state[2]_i_2 
       (.I0(\key_expansion_counter_reg_n_0_[0] ),
        .I1(\key_expansion_counter_reg_n_0_[1] ),
        .I2(\key_expansion_counter_reg_n_0_[3] ),
        .I3(\key_expansion_counter_reg_n_0_[2] ),
        .O(\FSM_onehot_state[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFEAAAA)) 
    \FSM_onehot_state[3]_i_1 
       (.I0(\FSM_onehot_state[3]_i_2_n_0 ),
        .I1(\FSM_onehot_state[6]_i_4_n_0 ),
        .I2(\FSM_onehot_state[6]_i_3_n_0 ),
        .I3(\FSM_onehot_state[6]_i_2_n_0 ),
        .I4(\FSM_onehot_state[6]_i_5_n_0 ),
        .I5(\FSM_onehot_state[3]_i_3_n_0 ),
        .O(\FSM_onehot_state[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hE0)) 
    \FSM_onehot_state[3]_i_2 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\FSM_onehot_state_reg_n_0_[3] ),
        .O(\FSM_onehot_state[3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h08FF0808)) 
    \FSM_onehot_state[3]_i_3 
       (.I0(start),
        .I1(\FSM_onehot_state_reg_n_0_[0] ),
        .I2(key_gen_start),
        .I3(\cnt_reg_n_0_[2] ),
        .I4(\FSM_onehot_state_reg_n_0_[3] ),
        .O(\FSM_onehot_state[3]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h8F888888)) 
    \FSM_onehot_state[4]_i_1 
       (.I0(round_counter),
        .I1(\FSM_onehot_state[4]_i_2_n_0 ),
        .I2(\FSM_onehot_state[4]_i_3_n_0 ),
        .I3(enc_dec),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\FSM_onehot_state[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'hFFDF)) 
    \FSM_onehot_state[4]_i_2 
       (.I0(\round_counter_reg_n_0_[1] ),
        .I1(\round_counter_reg_n_0_[2] ),
        .I2(\round_counter_reg_n_0_[3] ),
        .I3(\round_counter_reg_n_0_[0] ),
        .O(\FSM_onehot_state[4]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hEF)) 
    \FSM_onehot_state[4]_i_3 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\FSM_onehot_state_reg_n_0_[3] ),
        .O(\FSM_onehot_state[4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \FSM_onehot_state[5]_i_1 
       (.I0(\round_counter_reg_n_0_[1] ),
        .I1(\round_counter_reg_n_0_[2] ),
        .I2(\round_counter_reg_n_0_[3] ),
        .I3(\round_counter_reg_n_0_[0] ),
        .I4(round_counter),
        .I5(\FSM_onehot_state[5]_i_2_n_0 ),
        .O(\FSM_onehot_state[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCC00FF00FF00FF40)) 
    \FSM_onehot_state[5]_i_2 
       (.I0(enc_dec),
        .I1(\cnt_reg_n_0_[2] ),
        .I2(\FSM_onehot_state_reg_n_0_[3] ),
        .I3(\FSM_onehot_state_reg_n_0_[5] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\cnt_reg_n_0_[1] ),
        .O(\FSM_onehot_state[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h8888888F88888888)) 
    \FSM_onehot_state[6]_i_1 
       (.I0(addr_in),
        .I1(start),
        .I2(\FSM_onehot_state[6]_i_2_n_0 ),
        .I3(\FSM_onehot_state[6]_i_3_n_0 ),
        .I4(\FSM_onehot_state[6]_i_4_n_0 ),
        .I5(\FSM_onehot_state[6]_i_5_n_0 ),
        .O(\FSM_onehot_state[6]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_onehot_state[6]_i_10 
       (.I0(p_0_in[31]),
        .I1(p_0_in[30]),
        .I2(\addr_out_reg_n_0_[31] ),
        .I3(\addr_out_reg_n_0_[30] ),
        .O(\FSM_onehot_state[6]_i_10_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_onehot_state[6]_i_11 
       (.I0(p_0_in[27]),
        .I1(p_0_in[26]),
        .I2(p_0_in[29]),
        .I3(p_0_in[28]),
        .O(\FSM_onehot_state[6]_i_11_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFBFFF)) 
    \FSM_onehot_state[6]_i_2 
       (.I0(p_0_in[12]),
        .I1(p_0_in[13]),
        .I2(p_0_in[10]),
        .I3(p_0_in[11]),
        .I4(\FSM_onehot_state[6]_i_6_n_0 ),
        .O(\FSM_onehot_state[6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFF7FFF)) 
    \FSM_onehot_state[6]_i_3 
       (.I0(p_0_in[4]),
        .I1(p_0_in[5]),
        .I2(p_0_in[2]),
        .I3(p_0_in[3]),
        .I4(\FSM_onehot_state[6]_i_7_n_0 ),
        .O(\FSM_onehot_state[6]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_onehot_state[6]_i_4 
       (.I0(\FSM_onehot_state[6]_i_8_n_0 ),
        .I1(\FSM_onehot_state[6]_i_9_n_0 ),
        .I2(\FSM_onehot_state[6]_i_10_n_0 ),
        .I3(\FSM_onehot_state[6]_i_11_n_0 ),
        .O(\FSM_onehot_state[6]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h4000)) 
    \FSM_onehot_state[6]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .O(\FSM_onehot_state[6]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hFFFD)) 
    \FSM_onehot_state[6]_i_6 
       (.I0(p_0_in[15]),
        .I1(p_0_in[14]),
        .I2(p_0_in[17]),
        .I3(p_0_in[16]),
        .O(\FSM_onehot_state[6]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h7FFF)) 
    \FSM_onehot_state[6]_i_7 
       (.I0(p_0_in[7]),
        .I1(p_0_in[6]),
        .I2(p_0_in[9]),
        .I3(p_0_in[8]),
        .O(\FSM_onehot_state[6]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_onehot_state[6]_i_8 
       (.I0(p_0_in[23]),
        .I1(p_0_in[22]),
        .I2(p_0_in[25]),
        .I3(p_0_in[24]),
        .O(\FSM_onehot_state[6]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'hFFFD)) 
    \FSM_onehot_state[6]_i_9 
       (.I0(p_0_in[18]),
        .I1(p_0_in[19]),
        .I2(p_0_in[21]),
        .I3(p_0_in[20]),
        .O(\FSM_onehot_state[6]_i_9_n_0 ));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDPE #(
    .INIT(1'b1)) 
    \FSM_onehot_state_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\FSM_onehot_state[0]_i_1_n_0 ),
        .PRE(key_gen_Done_i_2_n_0),
        .Q(\FSM_onehot_state_reg_n_0_[0] ));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[1]_i_1_n_0 ),
        .Q(key_expansion_counter));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[2]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[2] ));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[3]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[3] ));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[4]_i_1_n_0 ),
        .Q(round_counter));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[5]_i_1_n_0 ),
        .Q(\FSM_onehot_state_reg_n_0_[5] ));
  (* FSM_ENCODED_STATES = "KEY_GENERATION:0000010,WAIT_KEY_GEN_LOW:0000100,ENCRYPTION:011,DECRYPTION:0010000,OUTPUT:0100000,INPUT:0001000,IDLE:0000001,DONE:1000000" *) 
  FDCE #(
    .INIT(1'b0)) 
    \FSM_onehot_state_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\FSM_onehot_state[6]_i_1_n_0 ),
        .Q(addr_in));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[10]_INST_0 
       (.I0(addr_in_reg[8]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[10]),
        .O(addr[8]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[11]_INST_0 
       (.I0(addr_in_reg[9]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[11]),
        .O(addr[9]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[12]_INST_0 
       (.I0(addr_in_reg[10]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[12]),
        .O(addr[10]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[13]_INST_0 
       (.I0(addr_in_reg[11]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[13]),
        .O(addr[11]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[14]_INST_0 
       (.I0(addr_in_reg[12]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[14]),
        .O(addr[12]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[15]_INST_0 
       (.I0(addr_in_reg[13]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[15]),
        .O(addr[13]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[16]_INST_0 
       (.I0(addr_in_reg[14]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[16]),
        .O(addr[14]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[17]_INST_0 
       (.I0(addr_in_reg[15]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[17]),
        .O(addr[15]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[18]_INST_0 
       (.I0(addr_in_reg[16]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[18]),
        .O(addr[16]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[19]_INST_0 
       (.I0(addr_in_reg[17]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[19]),
        .O(addr[17]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[20]_INST_0 
       (.I0(addr_in_reg[18]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[20]),
        .O(addr[18]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[21]_INST_0 
       (.I0(addr_in_reg[19]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[21]),
        .O(addr[19]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[22]_INST_0 
       (.I0(addr_in_reg[20]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[22]),
        .O(addr[20]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[23]_INST_0 
       (.I0(addr_in_reg[21]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[23]),
        .O(addr[21]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[24]_INST_0 
       (.I0(addr_in_reg[22]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[24]),
        .O(addr[22]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[25]_INST_0 
       (.I0(addr_in_reg[23]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[25]),
        .O(addr[23]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[26]_INST_0 
       (.I0(addr_in_reg[24]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[26]),
        .O(addr[24]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[27]_INST_0 
       (.I0(addr_in_reg[25]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[27]),
        .O(addr[25]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[28]_INST_0 
       (.I0(addr_in_reg[26]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[28]),
        .O(addr[26]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[29]_INST_0 
       (.I0(addr_in_reg[27]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[29]),
        .O(addr[27]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[2]_INST_0 
       (.I0(addr_in_reg[0]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[2]),
        .O(addr[0]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[30]_INST_0 
       (.I0(addr_in_reg[28]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[30]),
        .O(addr[28]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[31]_INST_0 
       (.I0(addr_in_reg[29]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[31]),
        .O(addr[29]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[3]_INST_0 
       (.I0(addr_in_reg[1]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[3]),
        .O(addr[1]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[4]_INST_0 
       (.I0(addr_in_reg[2]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[4]),
        .O(addr[2]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[5]_INST_0 
       (.I0(addr_in_reg[3]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[5]),
        .O(addr[3]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[6]_INST_0 
       (.I0(addr_in_reg[4]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[6]),
        .O(addr[4]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[7]_INST_0 
       (.I0(addr_in_reg[5]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[7]),
        .O(addr[5]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[8]_INST_0 
       (.I0(addr_in_reg[6]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[8]),
        .O(addr[6]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \addr[9]_INST_0 
       (.I0(addr_in_reg[7]),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(p_0_in[9]),
        .O(addr[7]));
  LUT3 #(
    .INIT(8'hF4)) 
    \addr_in[0]_i_1 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in),
        .O(\addr_in[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \addr_in[0]_i_3 
       (.I0(\FSM_onehot_state_reg_n_0_[3] ),
        .I1(\cnt_reg_n_0_[2] ),
        .O(addr_in1));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[0]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[3]),
        .O(\addr_in[0]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[0]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[2]),
        .O(\addr_in[0]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[0]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[1]),
        .O(\addr_in[0]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h10)) 
    \addr_in[0]_i_7 
       (.I0(addr_in_reg[0]),
        .I1(\cnt_reg_n_0_[2] ),
        .I2(\FSM_onehot_state_reg_n_0_[3] ),
        .O(\addr_in[0]_i_7_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[12]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[15]),
        .O(\addr_in[12]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[12]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[14]),
        .O(\addr_in[12]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[12]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[13]),
        .O(\addr_in[12]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[12]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[12]),
        .O(\addr_in[12]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[16]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[19]),
        .O(\addr_in[16]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[16]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[18]),
        .O(\addr_in[16]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[16]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[17]),
        .O(\addr_in[16]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[16]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[16]),
        .O(\addr_in[16]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[20]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[23]),
        .O(\addr_in[20]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[20]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[22]),
        .O(\addr_in[20]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[20]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[21]),
        .O(\addr_in[20]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[20]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[20]),
        .O(\addr_in[20]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[24]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[27]),
        .O(\addr_in[24]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[24]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[26]),
        .O(\addr_in[24]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[24]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[25]),
        .O(\addr_in[24]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[24]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[24]),
        .O(\addr_in[24]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[28]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[29]),
        .O(\addr_in[28]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[28]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[28]),
        .O(\addr_in[28]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[4]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[7]),
        .O(\addr_in[4]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[4]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[6]),
        .O(\addr_in[4]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[4]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[5]),
        .O(\addr_in[4]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[4]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[4]),
        .O(\addr_in[4]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[8]_i_2 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[11]),
        .O(\addr_in[8]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[8]_i_3 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[10]),
        .O(\addr_in[8]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[8]_i_4 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[9]),
        .O(\addr_in[8]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h40)) 
    \addr_in[8]_i_5 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\FSM_onehot_state_reg_n_0_[3] ),
        .I2(addr_in_reg[8]),
        .O(\addr_in[8]_i_5_n_0 ));
  FDCE \addr_in_reg[0] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[0]_i_2_n_7 ),
        .Q(addr_in_reg[0]));
  CARRY4 \addr_in_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\addr_in_reg[0]_i_2_n_0 ,\addr_in_reg[0]_i_2_n_1 ,\addr_in_reg[0]_i_2_n_2 ,\addr_in_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,addr_in1}),
        .O({\addr_in_reg[0]_i_2_n_4 ,\addr_in_reg[0]_i_2_n_5 ,\addr_in_reg[0]_i_2_n_6 ,\addr_in_reg[0]_i_2_n_7 }),
        .S({\addr_in[0]_i_4_n_0 ,\addr_in[0]_i_5_n_0 ,\addr_in[0]_i_6_n_0 ,\addr_in[0]_i_7_n_0 }));
  FDCE \addr_in_reg[10] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[8]_i_1_n_5 ),
        .Q(addr_in_reg[10]));
  FDCE \addr_in_reg[11] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[8]_i_1_n_4 ),
        .Q(addr_in_reg[11]));
  FDCE \addr_in_reg[12] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[12]_i_1_n_7 ),
        .Q(addr_in_reg[12]));
  CARRY4 \addr_in_reg[12]_i_1 
       (.CI(\addr_in_reg[8]_i_1_n_0 ),
        .CO({\addr_in_reg[12]_i_1_n_0 ,\addr_in_reg[12]_i_1_n_1 ,\addr_in_reg[12]_i_1_n_2 ,\addr_in_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[12]_i_1_n_4 ,\addr_in_reg[12]_i_1_n_5 ,\addr_in_reg[12]_i_1_n_6 ,\addr_in_reg[12]_i_1_n_7 }),
        .S({\addr_in[12]_i_2_n_0 ,\addr_in[12]_i_3_n_0 ,\addr_in[12]_i_4_n_0 ,\addr_in[12]_i_5_n_0 }));
  FDCE \addr_in_reg[13] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[12]_i_1_n_6 ),
        .Q(addr_in_reg[13]));
  FDCE \addr_in_reg[14] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[12]_i_1_n_5 ),
        .Q(addr_in_reg[14]));
  FDCE \addr_in_reg[15] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[12]_i_1_n_4 ),
        .Q(addr_in_reg[15]));
  FDCE \addr_in_reg[16] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[16]_i_1_n_7 ),
        .Q(addr_in_reg[16]));
  CARRY4 \addr_in_reg[16]_i_1 
       (.CI(\addr_in_reg[12]_i_1_n_0 ),
        .CO({\addr_in_reg[16]_i_1_n_0 ,\addr_in_reg[16]_i_1_n_1 ,\addr_in_reg[16]_i_1_n_2 ,\addr_in_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[16]_i_1_n_4 ,\addr_in_reg[16]_i_1_n_5 ,\addr_in_reg[16]_i_1_n_6 ,\addr_in_reg[16]_i_1_n_7 }),
        .S({\addr_in[16]_i_2_n_0 ,\addr_in[16]_i_3_n_0 ,\addr_in[16]_i_4_n_0 ,\addr_in[16]_i_5_n_0 }));
  FDCE \addr_in_reg[17] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[16]_i_1_n_6 ),
        .Q(addr_in_reg[17]));
  FDCE \addr_in_reg[18] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[16]_i_1_n_5 ),
        .Q(addr_in_reg[18]));
  FDCE \addr_in_reg[19] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[16]_i_1_n_4 ),
        .Q(addr_in_reg[19]));
  FDCE \addr_in_reg[1] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[0]_i_2_n_6 ),
        .Q(addr_in_reg[1]));
  FDCE \addr_in_reg[20] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[20]_i_1_n_7 ),
        .Q(addr_in_reg[20]));
  CARRY4 \addr_in_reg[20]_i_1 
       (.CI(\addr_in_reg[16]_i_1_n_0 ),
        .CO({\addr_in_reg[20]_i_1_n_0 ,\addr_in_reg[20]_i_1_n_1 ,\addr_in_reg[20]_i_1_n_2 ,\addr_in_reg[20]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[20]_i_1_n_4 ,\addr_in_reg[20]_i_1_n_5 ,\addr_in_reg[20]_i_1_n_6 ,\addr_in_reg[20]_i_1_n_7 }),
        .S({\addr_in[20]_i_2_n_0 ,\addr_in[20]_i_3_n_0 ,\addr_in[20]_i_4_n_0 ,\addr_in[20]_i_5_n_0 }));
  FDCE \addr_in_reg[21] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[20]_i_1_n_6 ),
        .Q(addr_in_reg[21]));
  FDCE \addr_in_reg[22] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[20]_i_1_n_5 ),
        .Q(addr_in_reg[22]));
  FDCE \addr_in_reg[23] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[20]_i_1_n_4 ),
        .Q(addr_in_reg[23]));
  FDCE \addr_in_reg[24] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[24]_i_1_n_7 ),
        .Q(addr_in_reg[24]));
  CARRY4 \addr_in_reg[24]_i_1 
       (.CI(\addr_in_reg[20]_i_1_n_0 ),
        .CO({\addr_in_reg[24]_i_1_n_0 ,\addr_in_reg[24]_i_1_n_1 ,\addr_in_reg[24]_i_1_n_2 ,\addr_in_reg[24]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[24]_i_1_n_4 ,\addr_in_reg[24]_i_1_n_5 ,\addr_in_reg[24]_i_1_n_6 ,\addr_in_reg[24]_i_1_n_7 }),
        .S({\addr_in[24]_i_2_n_0 ,\addr_in[24]_i_3_n_0 ,\addr_in[24]_i_4_n_0 ,\addr_in[24]_i_5_n_0 }));
  FDCE \addr_in_reg[25] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[24]_i_1_n_6 ),
        .Q(addr_in_reg[25]));
  FDCE \addr_in_reg[26] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[24]_i_1_n_5 ),
        .Q(addr_in_reg[26]));
  FDCE \addr_in_reg[27] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[24]_i_1_n_4 ),
        .Q(addr_in_reg[27]));
  FDCE \addr_in_reg[28] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[28]_i_1_n_7 ),
        .Q(addr_in_reg[28]));
  CARRY4 \addr_in_reg[28]_i_1 
       (.CI(\addr_in_reg[24]_i_1_n_0 ),
        .CO({\NLW_addr_in_reg[28]_i_1_CO_UNCONNECTED [3:1],\addr_in_reg[28]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_addr_in_reg[28]_i_1_O_UNCONNECTED [3:2],\addr_in_reg[28]_i_1_n_6 ,\addr_in_reg[28]_i_1_n_7 }),
        .S({1'b0,1'b0,\addr_in[28]_i_2_n_0 ,\addr_in[28]_i_3_n_0 }));
  FDCE \addr_in_reg[29] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[28]_i_1_n_6 ),
        .Q(addr_in_reg[29]));
  FDCE \addr_in_reg[2] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[0]_i_2_n_5 ),
        .Q(addr_in_reg[2]));
  FDCE \addr_in_reg[3] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[0]_i_2_n_4 ),
        .Q(addr_in_reg[3]));
  FDCE \addr_in_reg[4] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[4]_i_1_n_7 ),
        .Q(addr_in_reg[4]));
  CARRY4 \addr_in_reg[4]_i_1 
       (.CI(\addr_in_reg[0]_i_2_n_0 ),
        .CO({\addr_in_reg[4]_i_1_n_0 ,\addr_in_reg[4]_i_1_n_1 ,\addr_in_reg[4]_i_1_n_2 ,\addr_in_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[4]_i_1_n_4 ,\addr_in_reg[4]_i_1_n_5 ,\addr_in_reg[4]_i_1_n_6 ,\addr_in_reg[4]_i_1_n_7 }),
        .S({\addr_in[4]_i_2_n_0 ,\addr_in[4]_i_3_n_0 ,\addr_in[4]_i_4_n_0 ,\addr_in[4]_i_5_n_0 }));
  FDCE \addr_in_reg[5] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[4]_i_1_n_6 ),
        .Q(addr_in_reg[5]));
  FDCE \addr_in_reg[6] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[4]_i_1_n_5 ),
        .Q(addr_in_reg[6]));
  FDCE \addr_in_reg[7] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[4]_i_1_n_4 ),
        .Q(addr_in_reg[7]));
  FDCE \addr_in_reg[8] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[8]_i_1_n_7 ),
        .Q(addr_in_reg[8]));
  CARRY4 \addr_in_reg[8]_i_1 
       (.CI(\addr_in_reg[4]_i_1_n_0 ),
        .CO({\addr_in_reg[8]_i_1_n_0 ,\addr_in_reg[8]_i_1_n_1 ,\addr_in_reg[8]_i_1_n_2 ,\addr_in_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\addr_in_reg[8]_i_1_n_4 ,\addr_in_reg[8]_i_1_n_5 ,\addr_in_reg[8]_i_1_n_6 ,\addr_in_reg[8]_i_1_n_7 }),
        .S({\addr_in[8]_i_2_n_0 ,\addr_in[8]_i_3_n_0 ,\addr_in[8]_i_4_n_0 ,\addr_in[8]_i_5_n_0 }));
  FDCE \addr_in_reg[9] 
       (.C(clk),
        .CE(\addr_in[0]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_in_reg[8]_i_1_n_6 ),
        .Q(addr_in_reg[9]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \addr_out[0]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(p_0_in[2]),
        .O(\addr_out[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[10]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[10]),
        .O(addr_out[10]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[11]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[11]),
        .O(addr_out[11]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[12]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[12]),
        .O(addr_out[12]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[13]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[13]),
        .O(addr_out[13]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[14]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[14]),
        .O(addr_out[14]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[15]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[15]),
        .O(addr_out[15]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[16]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[16]),
        .O(addr_out[16]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[17]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[17]),
        .O(addr_out[17]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[18]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[18]),
        .O(addr_out[18]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[19]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[19]),
        .O(addr_out[19]));
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[1]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[1]),
        .O(addr_out[1]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[20]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[20]),
        .O(addr_out[20]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[21]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[21]),
        .O(addr_out[21]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[22]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[22]),
        .O(addr_out[22]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[23]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[23]),
        .O(addr_out[23]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[24]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[24]),
        .O(addr_out[24]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[25]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[25]),
        .O(addr_out[25]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[26]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[26]),
        .O(addr_out[26]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[27]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[27]),
        .O(addr_out[27]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[28]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[28]),
        .O(addr_out[28]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[29]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[29]),
        .O(addr_out[29]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[2]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[2]),
        .O(addr_out[2]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[30]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[30]),
        .O(addr_out[30]));
  LUT2 #(
    .INIT(4'hE)) 
    \addr_out[31]_i_1 
       (.I0(addr_in),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .O(\addr_out[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[31]_i_2 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[31]),
        .O(addr_out[31]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[3]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[3]),
        .O(addr_out[3]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[4]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[4]),
        .O(addr_out[4]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[5]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[5]),
        .O(addr_out[5]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[6]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[6]),
        .O(addr_out[6]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[7]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[7]),
        .O(addr_out[7]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[8]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[8]),
        .O(addr_out[8]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \addr_out[9]_i_1 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(in11[9]),
        .O(addr_out[9]));
  FDCE \addr_out_reg[0] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\addr_out[0]_i_1_n_0 ),
        .Q(p_0_in[2]));
  FDCE \addr_out_reg[10] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[10]),
        .Q(p_0_in[12]));
  FDCE \addr_out_reg[11] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[11]),
        .Q(p_0_in[13]));
  FDCE \addr_out_reg[12] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[12]),
        .Q(p_0_in[14]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[12]_i_2 
       (.CI(\addr_out_reg[8]_i_2_n_0 ),
        .CO({\addr_out_reg[12]_i_2_n_0 ,\addr_out_reg[12]_i_2_n_1 ,\addr_out_reg[12]_i_2_n_2 ,\addr_out_reg[12]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[12:9]),
        .S(p_0_in[14:11]));
  FDCE \addr_out_reg[13] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[13]),
        .Q(p_0_in[15]));
  FDCE \addr_out_reg[14] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[14]),
        .Q(p_0_in[16]));
  FDCE \addr_out_reg[15] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[15]),
        .Q(p_0_in[17]));
  FDCE \addr_out_reg[16] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[16]),
        .Q(p_0_in[18]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[16]_i_2 
       (.CI(\addr_out_reg[12]_i_2_n_0 ),
        .CO({\addr_out_reg[16]_i_2_n_0 ,\addr_out_reg[16]_i_2_n_1 ,\addr_out_reg[16]_i_2_n_2 ,\addr_out_reg[16]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[16:13]),
        .S(p_0_in[18:15]));
  FDCE \addr_out_reg[17] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[17]),
        .Q(p_0_in[19]));
  FDCE \addr_out_reg[18] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[18]),
        .Q(p_0_in[20]));
  FDCE \addr_out_reg[19] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[19]),
        .Q(p_0_in[21]));
  FDCE \addr_out_reg[1] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[1]),
        .Q(p_0_in[3]));
  FDCE \addr_out_reg[20] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[20]),
        .Q(p_0_in[22]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[20]_i_2 
       (.CI(\addr_out_reg[16]_i_2_n_0 ),
        .CO({\addr_out_reg[20]_i_2_n_0 ,\addr_out_reg[20]_i_2_n_1 ,\addr_out_reg[20]_i_2_n_2 ,\addr_out_reg[20]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[20:17]),
        .S(p_0_in[22:19]));
  FDCE \addr_out_reg[21] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[21]),
        .Q(p_0_in[23]));
  FDCE \addr_out_reg[22] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[22]),
        .Q(p_0_in[24]));
  FDCE \addr_out_reg[23] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[23]),
        .Q(p_0_in[25]));
  FDCE \addr_out_reg[24] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[24]),
        .Q(p_0_in[26]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[24]_i_2 
       (.CI(\addr_out_reg[20]_i_2_n_0 ),
        .CO({\addr_out_reg[24]_i_2_n_0 ,\addr_out_reg[24]_i_2_n_1 ,\addr_out_reg[24]_i_2_n_2 ,\addr_out_reg[24]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[24:21]),
        .S(p_0_in[26:23]));
  FDCE \addr_out_reg[25] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[25]),
        .Q(p_0_in[27]));
  FDCE \addr_out_reg[26] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[26]),
        .Q(p_0_in[28]));
  FDCE \addr_out_reg[27] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[27]),
        .Q(p_0_in[29]));
  FDCE \addr_out_reg[28] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[28]),
        .Q(p_0_in[30]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[28]_i_2 
       (.CI(\addr_out_reg[24]_i_2_n_0 ),
        .CO({\addr_out_reg[28]_i_2_n_0 ,\addr_out_reg[28]_i_2_n_1 ,\addr_out_reg[28]_i_2_n_2 ,\addr_out_reg[28]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[28:25]),
        .S(p_0_in[30:27]));
  FDCE \addr_out_reg[29] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[29]),
        .Q(p_0_in[31]));
  FDCE \addr_out_reg[2] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[2]),
        .Q(p_0_in[4]));
  FDCE \addr_out_reg[30] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[30]),
        .Q(\addr_out_reg_n_0_[30] ));
  FDCE \addr_out_reg[31] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[31]),
        .Q(\addr_out_reg_n_0_[31] ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[31]_i_3 
       (.CI(\addr_out_reg[28]_i_2_n_0 ),
        .CO({\NLW_addr_out_reg[31]_i_3_CO_UNCONNECTED [3:2],\addr_out_reg[31]_i_3_n_2 ,\addr_out_reg[31]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_addr_out_reg[31]_i_3_O_UNCONNECTED [3],in11[31:29]}),
        .S({1'b0,\addr_out_reg_n_0_[31] ,\addr_out_reg_n_0_[30] ,p_0_in[31]}));
  FDCE \addr_out_reg[3] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[3]),
        .Q(p_0_in[5]));
  FDCE \addr_out_reg[4] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[4]),
        .Q(p_0_in[6]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[4]_i_2 
       (.CI(1'b0),
        .CO({\addr_out_reg[4]_i_2_n_0 ,\addr_out_reg[4]_i_2_n_1 ,\addr_out_reg[4]_i_2_n_2 ,\addr_out_reg[4]_i_2_n_3 }),
        .CYINIT(p_0_in[2]),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[4:1]),
        .S(p_0_in[6:3]));
  FDCE \addr_out_reg[5] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[5]),
        .Q(p_0_in[7]));
  FDCE \addr_out_reg[6] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[6]),
        .Q(p_0_in[8]));
  FDCE \addr_out_reg[7] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[7]),
        .Q(p_0_in[9]));
  FDCE \addr_out_reg[8] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[8]),
        .Q(p_0_in[10]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \addr_out_reg[8]_i_2 
       (.CI(\addr_out_reg[4]_i_2_n_0 ),
        .CO({\addr_out_reg[8]_i_2_n_0 ,\addr_out_reg[8]_i_2_n_1 ,\addr_out_reg[8]_i_2_n_2 ,\addr_out_reg[8]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(in11[8:5]),
        .S(p_0_in[10:7]));
  FDCE \addr_out_reg[9] 
       (.C(clk),
        .CE(\addr_out[31]_i_1_n_0 ),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_out[9]),
        .Q(p_0_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h000FBBF0)) 
    \cnt[0]_i_1 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[2] ),
        .I2(\FSM_onehot_state_reg_n_0_[5] ),
        .I3(\FSM_onehot_state_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[0] ),
        .O(\cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h57A8)) 
    \cnt[1]_i_1 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\FSM_onehot_state_reg_n_0_[3] ),
        .I3(\cnt_reg_n_0_[1] ),
        .O(\cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h667F8800)) 
    \cnt[2]_i_1 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\FSM_onehot_state_reg_n_0_[5] ),
        .I3(\FSM_onehot_state_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\cnt[2]_i_1_n_0 ));
  FDCE \cnt_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\cnt[0]_i_1_n_0 ),
        .Q(\cnt_reg_n_0_[0] ));
  FDCE \cnt_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\cnt[1]_i_1_n_0 ),
        .Q(\cnt_reg_n_0_[1] ));
  FDCE \cnt_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\cnt[2]_i_1_n_0 ),
        .Q(\cnt_reg_n_0_[2] ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    \data_out[0]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[0] ),
        .O(data_out[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h08000008)) 
    \data_out[1]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .O(data_out[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h00000800)) 
    \data_out[2]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[1] ),
        .O(data_out[2]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h0000D000)) 
    \data_out[3]_INST_0 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(nrst),
        .I3(\FSM_onehot_state_reg_n_0_[5] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(data_out[3]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h0000D000)) 
    \data_out[4]_INST_0 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(nrst),
        .I3(\FSM_onehot_state_reg_n_0_[5] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(data_out[4]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00800000)) 
    \data_out[5]_INST_0 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\FSM_onehot_state_reg_n_0_[5] ),
        .I3(\cnt_reg_n_0_[2] ),
        .I4(nrst),
        .O(data_out[5]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    \data_out[6]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[1] ),
        .O(data_out[6]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    \data_out[7]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[0] ),
        .O(data_out[7]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h00080800)) 
    \data_out[8]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .O(data_out[8]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    \data_out[9]_INST_0 
       (.I0(nrst),
        .I1(\FSM_onehot_state_reg_n_0_[5] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[1] ),
        .O(data_out[9]));
  FDCE done_reg
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(addr_in),
        .Q(done));
  LUT1 #(
    .INIT(2'h1)) 
    \key_expansion_counter[0]_i_1 
       (.I0(\key_expansion_counter_reg_n_0_[0] ),
        .O(\key_expansion_counter[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h0BF0)) 
    \key_expansion_counter[1]_i_1 
       (.I0(\key_expansion_counter_reg_n_0_[2] ),
        .I1(\key_expansion_counter_reg_n_0_[3] ),
        .I2(\key_expansion_counter_reg_n_0_[1] ),
        .I3(\key_expansion_counter_reg_n_0_[0] ),
        .O(\key_expansion_counter[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \key_expansion_counter[2]_i_1 
       (.I0(\key_expansion_counter_reg_n_0_[2] ),
        .I1(\key_expansion_counter_reg_n_0_[0] ),
        .I2(\key_expansion_counter_reg_n_0_[1] ),
        .O(\key_expansion_counter[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h68AA)) 
    \key_expansion_counter[3]_i_1 
       (.I0(\key_expansion_counter_reg_n_0_[3] ),
        .I1(\key_expansion_counter_reg_n_0_[2] ),
        .I2(\key_expansion_counter_reg_n_0_[1] ),
        .I3(\key_expansion_counter_reg_n_0_[0] ),
        .O(\key_expansion_counter[3]_i_1_n_0 ));
  FDCE \key_expansion_counter_reg[0] 
       (.C(clk),
        .CE(key_expansion_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\key_expansion_counter[0]_i_1_n_0 ),
        .Q(\key_expansion_counter_reg_n_0_[0] ));
  FDCE \key_expansion_counter_reg[1] 
       (.C(clk),
        .CE(key_expansion_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\key_expansion_counter[1]_i_1_n_0 ),
        .Q(\key_expansion_counter_reg_n_0_[1] ));
  FDCE \key_expansion_counter_reg[2] 
       (.C(clk),
        .CE(key_expansion_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\key_expansion_counter[2]_i_1_n_0 ),
        .Q(\key_expansion_counter_reg_n_0_[2] ));
  FDCE \key_expansion_counter_reg[3] 
       (.C(clk),
        .CE(key_expansion_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(\key_expansion_counter[3]_i_1_n_0 ),
        .Q(\key_expansion_counter_reg_n_0_[3] ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    key_gen_Done_i_1
       (.I0(\key_expansion_counter_reg_n_0_[0] ),
        .I1(\key_expansion_counter_reg_n_0_[1] ),
        .I2(\key_expansion_counter_reg_n_0_[3] ),
        .I3(\key_expansion_counter_reg_n_0_[2] ),
        .I4(key_expansion_counter),
        .I5(key_gen_Done),
        .O(key_gen_Done_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    key_gen_Done_i_2
       (.I0(nrst),
        .O(key_gen_Done_i_2_n_0));
  FDCE key_gen_Done_reg
       (.C(clk),
        .CE(1'b1),
        .CLR(key_gen_Done_i_2_n_0),
        .D(key_gen_Done_i_1_n_0),
        .Q(key_gen_Done));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h00DF)) 
    \round_counter[0]_i_1 
       (.I0(\round_counter_reg_n_0_[1] ),
        .I1(\round_counter_reg_n_0_[2] ),
        .I2(\round_counter_reg_n_0_[3] ),
        .I3(\round_counter_reg_n_0_[0] ),
        .O(round_counter0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h0FD0)) 
    \round_counter[1]_i_1 
       (.I0(\round_counter_reg_n_0_[3] ),
        .I1(\round_counter_reg_n_0_[2] ),
        .I2(\round_counter_reg_n_0_[1] ),
        .I3(\round_counter_reg_n_0_[0] ),
        .O(round_counter0_in[1]));
  LUT3 #(
    .INIT(8'h6A)) 
    \round_counter[2]_i_1 
       (.I0(\round_counter_reg_n_0_[2] ),
        .I1(\round_counter_reg_n_0_[1] ),
        .I2(\round_counter_reg_n_0_[0] ),
        .O(round_counter0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h6A8A)) 
    \round_counter[3]_i_1 
       (.I0(\round_counter_reg_n_0_[3] ),
        .I1(\round_counter_reg_n_0_[2] ),
        .I2(\round_counter_reg_n_0_[1] ),
        .I3(\round_counter_reg_n_0_[0] ),
        .O(round_counter0_in[3]));
  FDCE \round_counter_reg[0] 
       (.C(clk),
        .CE(round_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(round_counter0_in[0]),
        .Q(\round_counter_reg_n_0_[0] ));
  FDCE \round_counter_reg[1] 
       (.C(clk),
        .CE(round_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(round_counter0_in[1]),
        .Q(\round_counter_reg_n_0_[1] ));
  FDCE \round_counter_reg[2] 
       (.C(clk),
        .CE(round_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(round_counter0_in[2]),
        .Q(\round_counter_reg_n_0_[2] ));
  FDCE \round_counter_reg[3] 
       (.C(clk),
        .CE(round_counter),
        .CLR(key_gen_Done_i_2_n_0),
        .D(round_counter0_in[3]),
        .Q(\round_counter_reg_n_0_[3] ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \write_en[0]_INST_0 
       (.I0(\FSM_onehot_state_reg_n_0_[5] ),
        .I1(nrst),
        .O(write_en));
endmodule

(* CHECK_LICENSE_TYPE = "AES_SYS_AES_0_0,AES,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "AES,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    nrst,
    start,
    enc_dec,
    data_in,
    key_in,
    key_gen_start,
    key_gen_Done,
    data_out,
    addr,
    write_en,
    done);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN AES_SYS_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
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

  wire \<const0> ;
  wire [31:2]\^addr ;
  wire clk;
  wire [9:0]\^data_out ;
  wire done;
  wire enc_dec;
  wire key_gen_Done;
  wire key_gen_start;
  wire nrst;
  wire start;
  wire [0:0]\^write_en ;

  assign addr[31:2] = \^addr [31:2];
  assign addr[1] = \<const0> ;
  assign addr[0] = \<const0> ;
  assign data_out[31] = \<const0> ;
  assign data_out[30] = \<const0> ;
  assign data_out[29] = \<const0> ;
  assign data_out[28] = \<const0> ;
  assign data_out[27] = \<const0> ;
  assign data_out[26] = \<const0> ;
  assign data_out[25] = \<const0> ;
  assign data_out[24] = \<const0> ;
  assign data_out[23] = \<const0> ;
  assign data_out[22] = \<const0> ;
  assign data_out[21] = \<const0> ;
  assign data_out[20] = \<const0> ;
  assign data_out[19] = \<const0> ;
  assign data_out[18] = \<const0> ;
  assign data_out[17] = \<const0> ;
  assign data_out[16] = \<const0> ;
  assign data_out[15] = \<const0> ;
  assign data_out[14] = \<const0> ;
  assign data_out[13] = \<const0> ;
  assign data_out[12] = \<const0> ;
  assign data_out[11] = \<const0> ;
  assign data_out[10] = \<const0> ;
  assign data_out[9:0] = \^data_out [9:0];
  assign write_en[3] = \^write_en [0];
  assign write_en[2] = \^write_en [0];
  assign write_en[1] = \^write_en [0];
  assign write_en[0] = \^write_en [0];
  GND GND
       (.G(\<const0> ));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_AES inst
       (.addr(\^addr ),
        .clk(clk),
        .data_out(\^data_out ),
        .done(done),
        .enc_dec(enc_dec),
        .key_gen_Done(key_gen_Done),
        .key_gen_start(key_gen_start),
        .nrst(nrst),
        .start(start),
        .write_en(\^write_en ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
