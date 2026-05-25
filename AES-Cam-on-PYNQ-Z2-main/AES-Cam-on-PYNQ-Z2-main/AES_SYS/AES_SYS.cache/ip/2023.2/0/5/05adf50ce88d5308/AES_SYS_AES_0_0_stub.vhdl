-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Thu Jun 12 01:59:49 2025
-- Host        : DESKTOP-8UU9KV6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ AES_SYS_AES_0_0_stub.vhdl
-- Design      : AES_SYS_AES_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    clk : in STD_LOGIC;
    nrst : in STD_LOGIC;
    start : in STD_LOGIC;
    enc_dec : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    key_in : in STD_LOGIC_VECTOR ( 127 downto 0 );
    key_gen_start : in STD_LOGIC;
    key_gen_Done : out STD_LOGIC;
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    write_en : out STD_LOGIC_VECTOR ( 3 downto 0 );
    done : out STD_LOGIC
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,nrst,start,enc_dec,data_in[31:0],key_in[127:0],key_gen_start,key_gen_Done,data_out[31:0],addr[31:0],write_en[3:0],done";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "AES,Vivado 2023.2";
begin
end;
