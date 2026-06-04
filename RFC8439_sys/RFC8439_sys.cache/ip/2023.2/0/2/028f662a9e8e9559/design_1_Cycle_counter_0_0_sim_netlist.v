// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat May 23 02:08:58 2026
// Host        : LAPTOP-9PRMHLIN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_Cycle_counter_0_0_sim_netlist.v
// Design      : design_1_Cycle_counter_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_Cycle_counter
   (count,
    start,
    clk,
    rst,
    done);
  output [31:0]count;
  input start;
  input clk;
  input rst;
  input done;

  wire clk;
  wire [31:0]count;
  wire \count[11]_i_2_n_0 ;
  wire \count[11]_i_3_n_0 ;
  wire \count[11]_i_4_n_0 ;
  wire \count[11]_i_5_n_0 ;
  wire \count[15]_i_2_n_0 ;
  wire \count[15]_i_3_n_0 ;
  wire \count[15]_i_4_n_0 ;
  wire \count[15]_i_5_n_0 ;
  wire \count[19]_i_2_n_0 ;
  wire \count[19]_i_3_n_0 ;
  wire \count[19]_i_4_n_0 ;
  wire \count[19]_i_5_n_0 ;
  wire \count[23]_i_2_n_0 ;
  wire \count[23]_i_3_n_0 ;
  wire \count[23]_i_4_n_0 ;
  wire \count[23]_i_5_n_0 ;
  wire \count[27]_i_2_n_0 ;
  wire \count[27]_i_3_n_0 ;
  wire \count[27]_i_4_n_0 ;
  wire \count[27]_i_5_n_0 ;
  wire \count[31]_i_1_n_0 ;
  wire \count[31]_i_3_n_0 ;
  wire \count[31]_i_4_n_0 ;
  wire \count[31]_i_5_n_0 ;
  wire \count[31]_i_6_n_0 ;
  wire \count[3]_i_2_n_0 ;
  wire \count[3]_i_3_n_0 ;
  wire \count[3]_i_4_n_0 ;
  wire \count[3]_i_5_n_0 ;
  wire \count[3]_i_6_n_0 ;
  wire \count[7]_i_2_n_0 ;
  wire \count[7]_i_3_n_0 ;
  wire \count[7]_i_4_n_0 ;
  wire \count[7]_i_5_n_0 ;
  wire \count_reg[11]_i_1_n_0 ;
  wire \count_reg[11]_i_1_n_1 ;
  wire \count_reg[11]_i_1_n_2 ;
  wire \count_reg[11]_i_1_n_3 ;
  wire \count_reg[11]_i_1_n_4 ;
  wire \count_reg[11]_i_1_n_5 ;
  wire \count_reg[11]_i_1_n_6 ;
  wire \count_reg[11]_i_1_n_7 ;
  wire \count_reg[15]_i_1_n_0 ;
  wire \count_reg[15]_i_1_n_1 ;
  wire \count_reg[15]_i_1_n_2 ;
  wire \count_reg[15]_i_1_n_3 ;
  wire \count_reg[15]_i_1_n_4 ;
  wire \count_reg[15]_i_1_n_5 ;
  wire \count_reg[15]_i_1_n_6 ;
  wire \count_reg[15]_i_1_n_7 ;
  wire \count_reg[19]_i_1_n_0 ;
  wire \count_reg[19]_i_1_n_1 ;
  wire \count_reg[19]_i_1_n_2 ;
  wire \count_reg[19]_i_1_n_3 ;
  wire \count_reg[19]_i_1_n_4 ;
  wire \count_reg[19]_i_1_n_5 ;
  wire \count_reg[19]_i_1_n_6 ;
  wire \count_reg[19]_i_1_n_7 ;
  wire \count_reg[23]_i_1_n_0 ;
  wire \count_reg[23]_i_1_n_1 ;
  wire \count_reg[23]_i_1_n_2 ;
  wire \count_reg[23]_i_1_n_3 ;
  wire \count_reg[23]_i_1_n_4 ;
  wire \count_reg[23]_i_1_n_5 ;
  wire \count_reg[23]_i_1_n_6 ;
  wire \count_reg[23]_i_1_n_7 ;
  wire \count_reg[27]_i_1_n_0 ;
  wire \count_reg[27]_i_1_n_1 ;
  wire \count_reg[27]_i_1_n_2 ;
  wire \count_reg[27]_i_1_n_3 ;
  wire \count_reg[27]_i_1_n_4 ;
  wire \count_reg[27]_i_1_n_5 ;
  wire \count_reg[27]_i_1_n_6 ;
  wire \count_reg[27]_i_1_n_7 ;
  wire \count_reg[31]_i_2_n_1 ;
  wire \count_reg[31]_i_2_n_2 ;
  wire \count_reg[31]_i_2_n_3 ;
  wire \count_reg[31]_i_2_n_4 ;
  wire \count_reg[31]_i_2_n_5 ;
  wire \count_reg[31]_i_2_n_6 ;
  wire \count_reg[31]_i_2_n_7 ;
  wire \count_reg[3]_i_1_n_0 ;
  wire \count_reg[3]_i_1_n_1 ;
  wire \count_reg[3]_i_1_n_2 ;
  wire \count_reg[3]_i_1_n_3 ;
  wire \count_reg[3]_i_1_n_4 ;
  wire \count_reg[3]_i_1_n_5 ;
  wire \count_reg[3]_i_1_n_6 ;
  wire \count_reg[3]_i_1_n_7 ;
  wire \count_reg[7]_i_1_n_0 ;
  wire \count_reg[7]_i_1_n_1 ;
  wire \count_reg[7]_i_1_n_2 ;
  wire \count_reg[7]_i_1_n_3 ;
  wire \count_reg[7]_i_1_n_4 ;
  wire \count_reg[7]_i_1_n_5 ;
  wire \count_reg[7]_i_1_n_6 ;
  wire \count_reg[7]_i_1_n_7 ;
  wire done;
  wire is_running;
  wire rst;
  wire start;
  wire start_d;
  wire [3:3]\NLW_count_reg[31]_i_2_CO_UNCONNECTED ;

  LUT3 #(
    .INIT(8'h8A)) 
    \count[11]_i_2 
       (.I0(count[11]),
        .I1(start_d),
        .I2(start),
        .O(\count[11]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[11]_i_3 
       (.I0(count[10]),
        .I1(start_d),
        .I2(start),
        .O(\count[11]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[11]_i_4 
       (.I0(count[9]),
        .I1(start_d),
        .I2(start),
        .O(\count[11]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[11]_i_5 
       (.I0(count[8]),
        .I1(start_d),
        .I2(start),
        .O(\count[11]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[15]_i_2 
       (.I0(count[15]),
        .I1(start_d),
        .I2(start),
        .O(\count[15]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[15]_i_3 
       (.I0(count[14]),
        .I1(start_d),
        .I2(start),
        .O(\count[15]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[15]_i_4 
       (.I0(count[13]),
        .I1(start_d),
        .I2(start),
        .O(\count[15]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[15]_i_5 
       (.I0(count[12]),
        .I1(start_d),
        .I2(start),
        .O(\count[15]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[19]_i_2 
       (.I0(count[19]),
        .I1(start_d),
        .I2(start),
        .O(\count[19]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[19]_i_3 
       (.I0(count[18]),
        .I1(start_d),
        .I2(start),
        .O(\count[19]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[19]_i_4 
       (.I0(count[17]),
        .I1(start_d),
        .I2(start),
        .O(\count[19]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[19]_i_5 
       (.I0(count[16]),
        .I1(start_d),
        .I2(start),
        .O(\count[19]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[23]_i_2 
       (.I0(count[23]),
        .I1(start_d),
        .I2(start),
        .O(\count[23]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[23]_i_3 
       (.I0(count[22]),
        .I1(start_d),
        .I2(start),
        .O(\count[23]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[23]_i_4 
       (.I0(count[21]),
        .I1(start_d),
        .I2(start),
        .O(\count[23]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[23]_i_5 
       (.I0(count[20]),
        .I1(start_d),
        .I2(start),
        .O(\count[23]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[27]_i_2 
       (.I0(count[27]),
        .I1(start_d),
        .I2(start),
        .O(\count[27]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[27]_i_3 
       (.I0(count[26]),
        .I1(start_d),
        .I2(start),
        .O(\count[27]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[27]_i_4 
       (.I0(count[25]),
        .I1(start_d),
        .I2(start),
        .O(\count[27]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[27]_i_5 
       (.I0(count[24]),
        .I1(start_d),
        .I2(start),
        .O(\count[27]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'h4F44)) 
    \count[31]_i_1 
       (.I0(start_d),
        .I1(start),
        .I2(done),
        .I3(is_running),
        .O(\count[31]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[31]_i_3 
       (.I0(count[31]),
        .I1(start_d),
        .I2(start),
        .O(\count[31]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[31]_i_4 
       (.I0(count[30]),
        .I1(start_d),
        .I2(start),
        .O(\count[31]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[31]_i_5 
       (.I0(count[29]),
        .I1(start_d),
        .I2(start),
        .O(\count[31]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[31]_i_6 
       (.I0(count[28]),
        .I1(start_d),
        .I2(start),
        .O(\count[31]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[3]_i_2 
       (.I0(count[0]),
        .I1(start_d),
        .I2(start),
        .O(\count[3]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[3]_i_3 
       (.I0(count[3]),
        .I1(start_d),
        .I2(start),
        .O(\count[3]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[3]_i_4 
       (.I0(count[2]),
        .I1(start_d),
        .I2(start),
        .O(\count[3]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[3]_i_5 
       (.I0(count[1]),
        .I1(start_d),
        .I2(start),
        .O(\count[3]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h45)) 
    \count[3]_i_6 
       (.I0(count[0]),
        .I1(start_d),
        .I2(start),
        .O(\count[3]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[7]_i_2 
       (.I0(count[7]),
        .I1(start_d),
        .I2(start),
        .O(\count[7]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[7]_i_3 
       (.I0(count[6]),
        .I1(start_d),
        .I2(start),
        .O(\count[7]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[7]_i_4 
       (.I0(count[5]),
        .I1(start_d),
        .I2(start),
        .O(\count[7]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h8A)) 
    \count[7]_i_5 
       (.I0(count[4]),
        .I1(start_d),
        .I2(start),
        .O(\count[7]_i_5_n_0 ));
  FDCE \count_reg[0] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[3]_i_1_n_7 ),
        .Q(count[0]));
  FDCE \count_reg[10] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[11]_i_1_n_5 ),
        .Q(count[10]));
  FDCE \count_reg[11] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[11]_i_1_n_4 ),
        .Q(count[11]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[11]_i_1 
       (.CI(\count_reg[7]_i_1_n_0 ),
        .CO({\count_reg[11]_i_1_n_0 ,\count_reg[11]_i_1_n_1 ,\count_reg[11]_i_1_n_2 ,\count_reg[11]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[11]_i_1_n_4 ,\count_reg[11]_i_1_n_5 ,\count_reg[11]_i_1_n_6 ,\count_reg[11]_i_1_n_7 }),
        .S({\count[11]_i_2_n_0 ,\count[11]_i_3_n_0 ,\count[11]_i_4_n_0 ,\count[11]_i_5_n_0 }));
  FDCE \count_reg[12] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[15]_i_1_n_7 ),
        .Q(count[12]));
  FDCE \count_reg[13] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[15]_i_1_n_6 ),
        .Q(count[13]));
  FDCE \count_reg[14] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[15]_i_1_n_5 ),
        .Q(count[14]));
  FDCE \count_reg[15] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[15]_i_1_n_4 ),
        .Q(count[15]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[15]_i_1 
       (.CI(\count_reg[11]_i_1_n_0 ),
        .CO({\count_reg[15]_i_1_n_0 ,\count_reg[15]_i_1_n_1 ,\count_reg[15]_i_1_n_2 ,\count_reg[15]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[15]_i_1_n_4 ,\count_reg[15]_i_1_n_5 ,\count_reg[15]_i_1_n_6 ,\count_reg[15]_i_1_n_7 }),
        .S({\count[15]_i_2_n_0 ,\count[15]_i_3_n_0 ,\count[15]_i_4_n_0 ,\count[15]_i_5_n_0 }));
  FDCE \count_reg[16] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[19]_i_1_n_7 ),
        .Q(count[16]));
  FDCE \count_reg[17] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[19]_i_1_n_6 ),
        .Q(count[17]));
  FDCE \count_reg[18] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[19]_i_1_n_5 ),
        .Q(count[18]));
  FDCE \count_reg[19] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[19]_i_1_n_4 ),
        .Q(count[19]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[19]_i_1 
       (.CI(\count_reg[15]_i_1_n_0 ),
        .CO({\count_reg[19]_i_1_n_0 ,\count_reg[19]_i_1_n_1 ,\count_reg[19]_i_1_n_2 ,\count_reg[19]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[19]_i_1_n_4 ,\count_reg[19]_i_1_n_5 ,\count_reg[19]_i_1_n_6 ,\count_reg[19]_i_1_n_7 }),
        .S({\count[19]_i_2_n_0 ,\count[19]_i_3_n_0 ,\count[19]_i_4_n_0 ,\count[19]_i_5_n_0 }));
  FDCE \count_reg[1] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[3]_i_1_n_6 ),
        .Q(count[1]));
  FDCE \count_reg[20] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[23]_i_1_n_7 ),
        .Q(count[20]));
  FDCE \count_reg[21] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[23]_i_1_n_6 ),
        .Q(count[21]));
  FDCE \count_reg[22] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[23]_i_1_n_5 ),
        .Q(count[22]));
  FDCE \count_reg[23] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[23]_i_1_n_4 ),
        .Q(count[23]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[23]_i_1 
       (.CI(\count_reg[19]_i_1_n_0 ),
        .CO({\count_reg[23]_i_1_n_0 ,\count_reg[23]_i_1_n_1 ,\count_reg[23]_i_1_n_2 ,\count_reg[23]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[23]_i_1_n_4 ,\count_reg[23]_i_1_n_5 ,\count_reg[23]_i_1_n_6 ,\count_reg[23]_i_1_n_7 }),
        .S({\count[23]_i_2_n_0 ,\count[23]_i_3_n_0 ,\count[23]_i_4_n_0 ,\count[23]_i_5_n_0 }));
  FDCE \count_reg[24] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[27]_i_1_n_7 ),
        .Q(count[24]));
  FDCE \count_reg[25] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[27]_i_1_n_6 ),
        .Q(count[25]));
  FDCE \count_reg[26] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[27]_i_1_n_5 ),
        .Q(count[26]));
  FDCE \count_reg[27] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[27]_i_1_n_4 ),
        .Q(count[27]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[27]_i_1 
       (.CI(\count_reg[23]_i_1_n_0 ),
        .CO({\count_reg[27]_i_1_n_0 ,\count_reg[27]_i_1_n_1 ,\count_reg[27]_i_1_n_2 ,\count_reg[27]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[27]_i_1_n_4 ,\count_reg[27]_i_1_n_5 ,\count_reg[27]_i_1_n_6 ,\count_reg[27]_i_1_n_7 }),
        .S({\count[27]_i_2_n_0 ,\count[27]_i_3_n_0 ,\count[27]_i_4_n_0 ,\count[27]_i_5_n_0 }));
  FDCE \count_reg[28] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[31]_i_2_n_7 ),
        .Q(count[28]));
  FDCE \count_reg[29] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[31]_i_2_n_6 ),
        .Q(count[29]));
  FDCE \count_reg[2] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[3]_i_1_n_5 ),
        .Q(count[2]));
  FDCE \count_reg[30] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[31]_i_2_n_5 ),
        .Q(count[30]));
  FDCE \count_reg[31] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[31]_i_2_n_4 ),
        .Q(count[31]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[31]_i_2 
       (.CI(\count_reg[27]_i_1_n_0 ),
        .CO({\NLW_count_reg[31]_i_2_CO_UNCONNECTED [3],\count_reg[31]_i_2_n_1 ,\count_reg[31]_i_2_n_2 ,\count_reg[31]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[31]_i_2_n_4 ,\count_reg[31]_i_2_n_5 ,\count_reg[31]_i_2_n_6 ,\count_reg[31]_i_2_n_7 }),
        .S({\count[31]_i_3_n_0 ,\count[31]_i_4_n_0 ,\count[31]_i_5_n_0 ,\count[31]_i_6_n_0 }));
  FDCE \count_reg[3] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[3]_i_1_n_4 ),
        .Q(count[3]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[3]_i_1 
       (.CI(1'b0),
        .CO({\count_reg[3]_i_1_n_0 ,\count_reg[3]_i_1_n_1 ,\count_reg[3]_i_1_n_2 ,\count_reg[3]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\count[3]_i_2_n_0 }),
        .O({\count_reg[3]_i_1_n_4 ,\count_reg[3]_i_1_n_5 ,\count_reg[3]_i_1_n_6 ,\count_reg[3]_i_1_n_7 }),
        .S({\count[3]_i_3_n_0 ,\count[3]_i_4_n_0 ,\count[3]_i_5_n_0 ,\count[3]_i_6_n_0 }));
  FDCE \count_reg[4] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[7]_i_1_n_7 ),
        .Q(count[4]));
  FDCE \count_reg[5] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[7]_i_1_n_6 ),
        .Q(count[5]));
  FDCE \count_reg[6] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[7]_i_1_n_5 ),
        .Q(count[6]));
  FDCE \count_reg[7] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[7]_i_1_n_4 ),
        .Q(count[7]));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \count_reg[7]_i_1 
       (.CI(\count_reg[3]_i_1_n_0 ),
        .CO({\count_reg[7]_i_1_n_0 ,\count_reg[7]_i_1_n_1 ,\count_reg[7]_i_1_n_2 ,\count_reg[7]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\count_reg[7]_i_1_n_4 ,\count_reg[7]_i_1_n_5 ,\count_reg[7]_i_1_n_6 ,\count_reg[7]_i_1_n_7 }),
        .S({\count[7]_i_2_n_0 ,\count[7]_i_3_n_0 ,\count[7]_i_4_n_0 ,\count[7]_i_5_n_0 }));
  FDCE \count_reg[8] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[11]_i_1_n_7 ),
        .Q(count[8]));
  FDCE \count_reg[9] 
       (.C(clk),
        .CE(\count[31]_i_1_n_0 ),
        .CLR(rst),
        .D(\count_reg[11]_i_1_n_6 ),
        .Q(count[9]));
  FDCE is_running_reg
       (.C(clk),
        .CE(1'b1),
        .CLR(rst),
        .D(\count[31]_i_1_n_0 ),
        .Q(is_running));
  FDCE start_d_reg
       (.C(clk),
        .CE(1'b1),
        .CLR(rst),
        .D(start),
        .Q(start_d));
endmodule

(* CHECK_LICENSE_TYPE = "design_1_Cycle_counter_0_0,Cycle_counter,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "Cycle_counter,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    rst,
    start,
    done,
    count);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 40000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input rst;
  input start;
  input done;
  output [31:0]count;

  wire clk;
  wire [31:0]count;
  wire done;
  wire rst;
  wire start;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_Cycle_counter inst
       (.clk(clk),
        .count(count),
        .done(done),
        .rst(rst),
        .start(start));
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
