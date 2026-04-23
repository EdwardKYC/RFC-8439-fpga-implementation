module RFC8439 (
    input clk, 
    input rst, 
    input en,
    input constant      [31:0],
    input nonce         [31:0],
    input key           [31:0],
    output Src_RAM_addr [31:0],
    output Src_RAM_mode,
    output Src_RAM_D    [31:0],
    input  Src_RAM_Q    [31:0],
    output cipher       [31:0],
    output MAC          [31:0],
    output Dst_RAM_addr [31:0],
    output Dst_RAM_en,
    output Dst_RAM_mode,
    output Dst_RAM_D    [31:0],
    input Dst_RAM_Q     [31:0];
);
    
endmodule