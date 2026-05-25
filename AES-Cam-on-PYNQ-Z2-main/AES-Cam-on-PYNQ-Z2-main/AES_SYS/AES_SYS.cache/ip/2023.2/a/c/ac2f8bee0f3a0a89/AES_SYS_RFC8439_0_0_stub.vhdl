-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Tue May 26 03:29:23 2026
-- Host        : LAPTOP-JHH6RF8B running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ AES_SYS_RFC8439_0_0_stub.vhdl
-- Design      : AES_SYS_RFC8439_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    start : in STD_LOGIC;
    mode_decrypt : in STD_LOGIC;
    done : out STD_LOGIC;
    mac_error : out STD_LOGIC;
    msg_length : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ad_length : in STD_LOGIC_VECTOR ( 31 downto 0 );
    Src_RAM_addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    Src_RAM_en : out STD_LOGIC;
    Src_RAM_we : out STD_LOGIC_VECTOR ( 3 downto 0 );
    Src_RAM_D : out STD_LOGIC_VECTOR ( 31 downto 0 );
    Src_RAM_Q : in STD_LOGIC_VECTOR ( 31 downto 0 );
    Dst_RAM_addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    Dst_RAM_en : out STD_LOGIC;
    Dst_RAM_we : out STD_LOGIC_VECTOR ( 3 downto 0 );
    Dst_RAM_D : out STD_LOGIC_VECTOR ( 31 downto 0 );
    Dst_RAM_Q : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rst,start,mode_decrypt,done,mac_error,msg_length[31:0],ad_length[31:0],Src_RAM_addr[31:0],Src_RAM_en,Src_RAM_we[3:0],Src_RAM_D[31:0],Src_RAM_Q[31:0],Dst_RAM_addr[31:0],Dst_RAM_en,Dst_RAM_we[3:0],Dst_RAM_D[31:0],Dst_RAM_Q[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "RFC8439,Vivado 2023.2";
begin
end;
