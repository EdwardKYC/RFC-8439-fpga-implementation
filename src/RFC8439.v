module RFC8439 (
    input  wire        clk,
    input  wire        rst,

    input  wire        start,        // 啟動訊號 (取代單純的 en)
    input  wire        mode_decrypt, // 0: 加密模式, 1: 解密模式
    output reg         done,         // 運算完成通知
    output reg         mac_error,    // 解密時的 MAC 驗證失敗警告

    input  wire [31:0] msg_length,   // 明文/密文的總 Byte 數
    input  wire [31:0] ad_length,    // 附加關聯資料(AD)的總 Byte 數

    input  wire [3:0]  config_addr,  // 決定現在寫入的是 Key[0~7] 還是 Nonce[0~2]
    input  wire [31:0] config_data,  // 32-bit 配置資料
    input  wire        config_we,    // 配置資料寫入致能 (Write Enable)

    output wire [31:0] Src_RAM_addr,
    output wire        Src_RAM_en,   
    output wire        Src_RAM_we,   // Write Enable
    output wire [31:0] Src_RAM_D,    // 寫入資料 (通常來源端只讀不寫，可保留)
    input  wire [31:0] Src_RAM_Q,    // 讀出資料

    output wire [31:0] Dst_RAM_addr,
    output wire        Dst_RAM_en,   
    output wire        Dst_RAM_we,   // Write Enable
    output wire [31:0] Dst_RAM_D,    // 寫入資料
    input  wire [31:0] Dst_RAM_Q     // 讀出資料 (通常目的端只寫不讀)
);


endmodule