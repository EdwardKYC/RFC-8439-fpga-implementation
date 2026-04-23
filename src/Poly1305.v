module poly1305_core (
    input  wire          clk,
    input  wire          rst,
    input  wire          valid_in,   // 告訴引擎：data_in 資料有效，請吃進去算
    output reg           ready_out,  // 告訴 FSM：我算完這輪了，可以餵下一塊
    input  wire [255:0]  mac_key,// 這把 256-bit Key 是 FSM 在 Counter=0 時，從 ChaCha20 拿來接進來的
    input  wire [127:0]  data_in,// 對應 C API 中的 ad (關聯資料) 或 c (密文) 經過 FSM 切出來的 16-Byte 區塊    
    input  wire          pad_bit,// 安全性填充位元：用來附加在資料結尾的 0x01 (讓資料變 129-bit)    
    input  wire          finalize,// 對應 C API 中的 mlen/adlen：當 FSM 餵完最後一個「長度區塊」時拉高此訊號
    output reg  [127:0]  mac_tag,    
    output reg           tag_valid   // 告訴 FSM：最終 Tag 出爐了！
);

endmodule
