module Poly1305 (
    input  wire          clk,
    input  wire          rst,
    input  wire          valid_in,   // 告訴引擎：data_in 資料有效，請吃進去算
    output reg           ready_out,  // 告訴 FSM：我算完這輪了，可以餵下一塊
    input  wire [255:0]  mac_key,    // 這把 256-bit Key 是 FSM 在 Counter=0 時，從 ChaCha20 拿來接進來的
    input  wire [127:0]  data_in,    // 對應 C API 中的 ad (關聯資料) 或 c (密文) 經過 FSM 切出來的 16-Byte 區塊    
    input  wire          pad_bit,    // 安全性填充位元：用來附加在資料結尾的 0x01 (讓資料變 129-bit)    
    input  wire          finalize,   // 對應 C API 中的 mlen/adlen：當 FSM 餵完最後一個「長度區塊」時拉高此訊號
    output reg  [127:0]  mac_tag,    
    output reg           tag_valid   // 告訴 FSM：最終 Tag 出爐了！
);

    // ==========================================
    // FSM 狀態定義
    // ==========================================
    localparam [2:0] IDLE  = 3'd0,
                     MUL   = 3'd1,
                     MOD1  = 3'd2,
                     MOD2  = 3'd3,
                     FIN   = 3'd4,
                     DONE  = 3'd5;

    reg [2:0] state;

    // ==========================================
    // 內部暫存器 (Internal Registers)
    // ==========================================
    reg [132:0] acc;            // Accumulator (寬度開到 133 bits 防溢位)
    reg [129:0] r_reg;          // Clamped Key (r)
    reg [127:0] s_reg;          // Key (s)
    reg [259:0] mul_res;        // 130-bit * 130-bit 乘法結果
    reg         is_final;       // 鎖存 finalize 訊號
    reg         is_first_block; // 標記是否為全新訊息的第一塊

    // ==========================================
    // RFC 8439 r_key Clamping 遮罩
    // ==========================================
    // 將特定位元清零：r[3], r[7], r[11], r[15] top 4 bits; r[4], r[8], r[12] bottom 2 bits
    wire [129:0] r_mask = 130'h0_0FFF_FFFC_0FFF_FFFC_0FFF_FFFC_0FFFFFFF;

    // ==========================================
    // 核心 FSM 與資料路徑
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            ready_out      <= 1'b1;  // Reset 後馬上處於可收資料狀態
            tag_valid      <= 1'b0;
            mac_tag        <= 128'd0;
            acc            <= 133'd0;
            r_reg          <= 130'd0;
            s_reg          <= 128'd0;
            mul_res        <= 260'd0;
            is_final       <= 1'b0;
            is_first_block <= 1'b1;  // 預設為全新訊息
        end else begin
            case (state)
                IDLE: begin
                    ready_out <= 1'b1;
                    tag_valid <= 1'b0; 
                    
                    if (valid_in) begin
                        ready_out <= 1'b0;
                        is_final  <= finalize;

                        // [第一塊資料的初始化] 擷取並 Clamp Key
                        if (is_first_block) begin
                            r_reg <= {2'b00, mac_key[127:0]} & r_mask;
                            s_reg <= mac_key[255:128];
                            is_first_block <= 1'b0;
                        end

                        // [累加器] 把目前的輸入資料 (加上 pad_bit) 累加
                        // data_in 是 128-bit，pad_bit 會擺在第 128 個 bit (成為第 129 個 bit)
                        acc <= acc + {4'b0000, pad_bit, data_in};
                        state <= MUL;
                    end
                end

                MUL: begin
                    // 130-bit * 130-bit 乘法
                    mul_res <= acc * r_reg;
                    state   <= MOD1;
                end

                MOD1: begin
                    // 第一次 Modulo 2^130 - 5 降維 
                    // 利用等價數學: X * 2^130 ≡ X * 5 (mod p)
                    // X * 5 可以優化為 (X << 2) + X
                    acc   <= mul_res[129:0] + {mul_res[259:130], 2'b00} + mul_res[259:130];
                    state <= MOD2;
                end

                MOD2: begin
                    // 第二次 Modulo 降維，確保數值收斂在 131 bits 以內
                    acc <= acc[129:0] + {acc[132:130], 2'b00} + acc[132:130];
                    
                    if (is_final)
                        state <= FIN;
                    else
                        state <= IDLE;
                end

                FIN: begin
                    // 最終收尾：進行完美的 Modulo (2^130 - 5)
                    // 如果 acc >= (2^130 - 5)，則 acc + 5 會 >= 2^130
                    if (acc + 5 >= (133'd1 << 130)) begin
                        // 減去 (2^130 - 5) 相當於: 取 (acc + 5) 的低 130 bits
                        acc <= (acc + 5) & ((133'd1 << 130) - 1); 
                    end
                    state <= DONE;
                end

                DONE: begin
                    // 加上 s_reg，並取低 128-bit 作為最終 Tag
                    // (Verilog 會自動捨棄超過 128-bit 的進位，等同於 mod 2^128)
                    mac_tag   <= acc[127:0] + s_reg;
                    tag_valid <= 1'b1;
                    
                    // 清空 accumulator 與狀態，準備迎接下一包獨立的 AEAD 訊息
                    acc            <= 133'd0;
                    is_first_block <= 1'b1;
                    state          <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule