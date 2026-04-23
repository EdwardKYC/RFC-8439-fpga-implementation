module Chacha20 (
    input  wire          clk,
    input  wire          rst,
    input  wire          start,      // 告訴引擎：開始算下一塊
    output reg           ready,      // 告訴 FSM：512-bit finish
    input  wire [255:0]  key,        
    input  wire [95:0]   nonce,      
    input  wire [31:0]   counter,    // 0: 生產 MAC Key, 1+: 生產加密密鑰流
    output wire [511:0]  keystream   
);
// 註：C API 中的 nsec (Secret Nonce) 在標準 RFC 8439 通常不用，硬體直接忽略。

endmodule
