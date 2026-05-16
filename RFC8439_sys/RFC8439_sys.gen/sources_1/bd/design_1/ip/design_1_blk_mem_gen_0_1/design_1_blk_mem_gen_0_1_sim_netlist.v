// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat May 16 12:58:12 2026
// Host        : LAPTOP-9PRMHLIN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/RFC-8439-fpga-implementation/RFC8439_sys/RFC8439_sys.gen/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_1/design_1_blk_mem_gen_0_1_sim_netlist.v
// Design      : design_1_blk_mem_gen_0_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_blk_mem_gen_0_1,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module design_1_blk_mem_gen_0_1
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
  design_1_blk_mem_gen_0_1_blk_mem_gen_v8_4_7 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 57712)
`pragma protect data_block
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
jmDznvw9EkXyXsusvm4Auw1Mqzz3PSJNg6B+Iw==
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
