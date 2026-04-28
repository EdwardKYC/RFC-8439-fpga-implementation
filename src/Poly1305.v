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
    // 狀態定義：簡化為 3 個核心狀態
    // ==========================================
    localparam [1:0] ST_IDLE = 2'd0,
                     ST_CALC = 2'd1, // 包含 MUL 與初次 MOD
                     ST_FIN  = 2'd2;

    reg [1:0] state;

    // ==========================================
    // 流水線暫存器
    // ==========================================
    reg [130:0] acc;            // 累加器 (131-bit 夠用)
    reg [129:0] r_reg;
    reg [127:0] s_reg;
    reg         is_first_block;
    
    // 流水線乘法暫存器
    reg [259:0] mul_stage1; 

    // Clamping 遮罩
    wire [129:0] r_mask = 130'h0_0FFF_FFFC_0FFF_FFFC_0FFF_FFFC_0FFFFFFF;

    // ==========================================
    // 快速 Modulo 邏輯 (折疊 MOD1 & MOD2)
    // ==========================================
    // 利用 X * 2^130 + Y = X*5 + Y
    function [130:0] fast_mod(input [259:0] val);
        reg [134:0] reduce;
        begin
            // 這裡一次性處理高位元乘以 5 並加上低位元
            reduce = val[129:0] + (val[259:130] * 3'd5);
            // 第二次微調，確保結果縮小到 131 bits 左右
            fast_mod = reduce[129:0] + (reduce[134:130] * 3'd5);
        end
    endfunction

    // ==========================================
    // 主邏輯
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= ST_IDLE;
            ready_out      <= 1'b1;
            tag_valid      <= 1'b0;
            acc            <= 131'd0;
            is_first_block <= 1'b1;
            mac_tag        <= 128'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    tag_valid <= 1'b0;
                    ready_out <= 1'b1;
                    if (valid_in) begin
                        ready_out <= 1'b0;
                        if (is_first_block) begin
                            r_reg <= {2'b00, mac_key[127:0]} & r_mask;
                            s_reg <= mac_key[255:128];
                            is_first_block <= 1'b0;
                        end
                        // 第一步：直接做加法並開始乘法
                        mul_stage1 <= (acc + {2'b00, pad_bit, data_in}) * ((is_first_block) ? ({2'b00, mac_key[127:0]} & r_mask) : r_reg);
                        if (finalize) state <= ST_FIN;
                        else          state <= ST_CALC;
                    end
                end

                ST_CALC: begin
                    acc <= fast_mod(mul_stage1);
                    ready_out <= 1'b1;
                    if (valid_in) begin
                        ready_out <= 1'b0;
                        // 直接餵入下一個 Block 的乘法
                        mul_stage1 <= (fast_mod(mul_stage1) + {2'b00, pad_bit, data_in}) * r_reg;
                        if (finalize) state <= ST_FIN;
                        else          state <= ST_CALC;
                    end else begin
                        state <= ST_IDLE;
                    end
                end

                ST_FIN: begin
                    reg [130:0] final_acc;
                    final_acc = fast_mod(mul_stage1);

                    if (final_acc >= 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb) begin
                        final_acc = final_acc - 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb;
                    end
                    mac_tag   <= final_acc[127:0] + s_reg;
                    tag_valid <= 1'b1;
                    acc       <= 131'd0;
                    is_first_block <= 1'b1;
                    state     <= ST_IDLE;
                end
            endcase
        end
    end
endmodule