// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat May 16 12:58:11 2026
// Host        : LAPTOP-9PRMHLIN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_blk_mem_gen_0_1_sim_netlist.v
// Design      : design_1_blk_mem_gen_0_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_blk_mem_gen_0_1,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    rsta,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    web,
    addrb,
    dinb,
    doutb,
    rsta_busy,
    rstb_busy);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *) input rsta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [3:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [31:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB RST" *) input rstb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [31:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [31:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;
  output rsta_busy;
  output rstb_busy;

  wire [31:0]addra;
  wire [31:0]addrb;
  wire clka;
  wire [31:0]dina;
  wire [31:0]dinb;
  wire [31:0]douta;
  wire [31:0]doutb;
  wire ena;
  wire enb;
  wire rsta;
  wire rsta_busy;
  wire rstb;
  wire rstb_busy;
  wire [3:0]wea;
  wire [3:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "32" *) 
  (* C_ADDRB_WIDTH = "32" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "1" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "1" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "1" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     10.7492 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "1" *) 
  (* C_HAS_RSTB = "1" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "NONE" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "2048" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "1" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "4" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "2048" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_7 U0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addra[12:2],1'b0,1'b0}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addrb[12:2],1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[31:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(rsta),
        .rsta_busy(rsta_busy),
        .rstb(rstb),
        .rstb_busy(rstb_busy),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[31:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jLV29U0rrfMIZhYJzdoUrPoqB9eHQ5NXmWyCdqnN3Wgm+GU4C3zthrN1m4QGiaj0thPCIynZbX+0
7yjtkv+T5ByJ6NhiofAwWseGLvPXlYu6ERAPvi4SAYpF2VUqQHtPAbPmnPubGdDRgIEpeobF7hsz
rEcpEru1pyiScUriyuo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vsoizVrOONWw/DhjRLEYrtRmtji+Ok63CbpSg/l9VnoKAi8tAzqRbQ57atGB2N6IGGbKHkbK2Uzh
EHgWvYZeyt4hE+bpQX91vc9PNxfjQMGzPoFD3jCWk30EmEk+AND39eWx+DhJ8xhFuucoOQ2GwyAk
B+Mjs15naPE7DvlHel8hnD4dfSdYhGKp96oozu8JeBto8aHG6poOuYkxSwaut7NCI+mabCkMxtMp
RrydgmRuTvhRTbJMyx5CxFSZTRDrS5aU1vaRlnMiqKCI7g2KY9pemYaJsFeVodBuo6IyKGynyEhs
wr+VtUhQDtaVhMkwB95WwmMoDk9F2L5Au1I+TQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
W081dPMCWhKs5YlQD7n3zvf7+PTcnb8eFWxoVs8+zHLkxDMA1klITbsfztGYvJFce8Yao5XQLLqZ
oUE5Pq2arq+zwICFUcLjdMsmP1WmL82znHOPHm83zNwrxWMloHkySAqzFbgJeHa973uZqj0M8ydc
sYmzCYVlGVjt0QX0xqA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Zpc3MmdLWaVOv+S4z2POuoyslYoAbWc+Npxq2UyQRtDwf566IId3uwAetolMAgfLo/G3ezuSOXMn
8NznS37h9XvmVrxA50SAux68P87WgkLtiUYqM3CMBKkxNlZ/TR8WzTuQyFdvzkOE9lp8HC7LXnk5
RDsnOM+su46FW7ysY01COslo9Xc7rhs6WFqx29+Xcqk8+ZMLSzaJfuwZdNmJFS3Q1vhlq3ZeYqMl
wMieB731KsPxjxp7VKNHpTbgFryC2isqc4ohBDOt52M/Bz4B/rIpFeHfZ7X3jWSiKtSuBsDN2NXf
EMjfAT248dlK7NxJ+NBNPhS5sLxTiGyQhta57A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rPMYqnkKhJKV1wltOfDrKos9ZbucaoX3WGTuqsdLkGpcKObzslHBwlGrKtWV7bZYmS2SM+QuEMfa
CE+tCUdsSiprp+n5BuSQlJa6BJ8mlqccjoo/JLw2QEmUhyMXQ3TLGomGGoZdeTmMPXhUBAOyLPea
Ddc8mgtTN8Kpy117GOTXDKP+IKJqW01fLrPJpgEhFiJCbyElLgtCRWmI94gX+y4XNVS0Cd1YwNw6
4nHgnEdC7fXARDKcYO3VsWC/pdzPQgursXloNLrVYa6i2xr+8E1V0+nSWwNYQZP7XUIVqXKMU8Ea
bT4acXrRCF/5tJJ5B9JparYI0zxXSbaakn1dIw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mfroTgL8g2pyIXQ/mGO9YHm19cd5mOlJ++qpusOYeVxGmkIhvF4aKx+AyIUz2yGGAeCtOzIasHty
pyqKgZhibSqxcpHgR0m6GOxXXOXJiHaK8NzxUzXeRJovcBI/WjtDhXeb1LRMI1J97jVBtJPJQH0Y
fGOD7jWvkvQwxnrZdyLp6kPWgSIcavHHDbO7iJv4gnyGp6W3/FCDo2RKWNLoW+SNjSdLZ6YRP8a+
ldaGU8TYvJ03KWlmik7repuN6AwxCjg2KeQ+x1sBAEXzROXomuSbvX3ZAo8UiIKAQY1SJumHLG3L
QI/S4Wbl1Hz6LDTsttMwP480gq6+tb6s1E4oWw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QJIabgm8dx/gVHbOQFwt8maOKVHFgkpZTPR6dzD8fqoGo9M9oGPTqBqchtPZWgv2UYFF2KEUSlV4
L3SDXBKrLs+NsAVTcICaEMiEi6j82zj/C1LsPkQfS8RLrg0ab8lbDMb5YqJ7lkHs3iM65x2iN1Mf
66cTgCbkAdl3rDpab75btpTQt5ZKiq5CSY3RZfyIW0uWbTGTELm6liuRKM9+K8BQwTU7A+FFFQBA
/9eJwQYzNNA/iwoYJ2WTPd6pBlzXriNLu9M+/2bYicNBSuH1PBR9v2ESrTB6k7EiV1zvBXV9NuG/
sFt4MumWMuSNwP2W38bQATxxW/l0IrmaXGOC/w==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
lhKf/Vgj6pHpme1ji4HVe36BU8pMkam/2I9lFeyOiBnIbzgdEGfLJBcEvkL33A7s0hxa6LFbHnkT
upgMpPjmIghBz3xUQ13vpiY152thFec6qvlcdg1r+GTmnBOSFl6g/OfZ3eFUhfsve6ZjQHpXnKFo
a55hN2+eP1EG9+VxGeM7XkHaeFhEIry52qtnmg072KEFIwRiGs2d/TJ4AqupuIdIiP1kTN9k+oqa
2ta1vdtqPY0dDHqrf+5YSd0CejkhQeCqg/bauLP3755SwdOPRgooG5ANT8hUpTiFMFXtU+GC9NSp
evJtMHUy1NbgMmhFHO+w3URLEdjSaBxZPD7YLdWkF65jY526tJzoek+BzEKoBaGfCaY7O1nHKXm+
89k3rPUy0Xo4/0nHpno+N/Db09heJPbnGsCwN/l+KnR6Lz8kvWziBjZe0ijOkKI+T12y3T1VeOtY
H/aqtNlQt1mhFwrbw6ezaAiDPVbCQXnly6b4tbb8+nFsxWOGIGAfLozB

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PNsQ8uEcQYrl+GaDuBaq1tQ5br5aAdaqHnyrc0NVu/JnQUk53jaiLx8Oz5fNACvWelUUk2/C+P5I
b2rbU1bb/dC6TqC5J1N0yoMYRYw58u4Lrl8Kgqgt9Rlph5Qgzzfxp+oblXF/pO4mRyAXpZhpNkFT
0Ar9BUtPOTOtJ9/g53SRnZ6GjxzfeD+25J4fcXBNo2gCTgUkwiLSsJRwTB/cJmn+dZPwPdIOHEP9
TkfDK+OrbLYO3T+DFBTCMRNH2NB1J9sc5s+nPU8iYnjgPTo6HoGW+LIlCz6yNJMZzJzoeW708utc
0fJXkT7vLDVh7olvy3V9AAY8Do0YR1kiZlhVhQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zAz8RnGHFebkJFAS+gjC+mXHW7m7We+JgSmIz15mS01u/4+9Ng0sJfkeXOClmVPTQ2Mp2Yuv6/6f
ehzUTcANilWsqLM6Q1FToCPNX/NTqodlcHirGM7b5R9yevouNT/aqH12nmbunBQmBHmehNutdCjG
r6Z7kZgeZ2ZE7MMOF0rTy1XHEPkqgMNTRoS8R/pPWPTW4/j+bn3aJj0Q/fTz4Gi3mbSUKWs2fREQ
UKiuolNJkN6DiDvhlVYHUyytXNJG44ikmBXehoQQRLapkYaxnQmMRT1ok9uY6pKoy71CtvJ3Mt2x
EQv1GU2i4qQyAOwa0mkEohWXduicU6tDz3zQwQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TK3eE9V+v1z2P1KjG4GrjhA1n3qDOpNzLGXdtjnjhF0QBFPSuhC+nmNqTPOb3p2a9r5KD0miY3Cd
+KpjH6Ao09E2/LD2Go4aLQh6vP+9BldlSKEwCGfx2NjBQrXWVH21lQR7IRjOvyTOclpd7SgtUJLw
dvebETyLiKr9C6RfnIBeptuCA3iJlXfwkh6I0JfzD5WBizQkotioZmmrXv5105pCXQ4Ta1WThFsA
2ll9dZeSjEDHUxxhfyfjryv9m4VL89ZDU/rGITsdptwB1BC1jLqmPDymY05lyECnjA6NIR5GGfI4
K2y2f4GfikKoN5r9IOvFzw963Wm82ZZPtXOKGg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 57680)
`pragma protect data_block
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
`pragma protect end_protected
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
