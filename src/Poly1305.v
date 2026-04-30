module Poly1305 (
    input  wire          clk,
    input  wire          rst,
    input  wire          valid_in,   // 告訴引擎：data_in 資料有效，請吃進去算
    output reg           ready_out,  // 告訴 FSM：我算完這輪了，可以餵下一塊
    input  wire [255:0]  mac_key,    // 從 ChaCha20 拿來的 256-bit Key
    input  wire [127:0]  data_in,    // 16-Byte 區塊
    input  wire          pad_bit,    // 安全性填充位元
    input  wire          finalize,   // 當 FSM 餵完最後一個「長度區塊」時拉高此訊號
    output reg  [127:0]  mac_tag,    
    output reg           tag_valid   // 告訴 FSM：最終 Tag 出爐了！
);

    // ==========================================
    // 參數與內部變數宣告
    // ==========================================
    localparam [2:0] ST_IDLE = 3'd0,
                     ST_M1   = 3'd1, // 計算 A0 * R0
                     ST_M2   = 3'd2, // 計算 A1 * R0
                     ST_M3   = 3'd3, // 計算 A0 * R1
                     ST_M4   = 3'd4, // 計算 A1 * R1
                     ST_REDU = 3'd5, // 組合結果並進行 Modulo 降維
                     ST_FIN  = 3'd6;

    reg [2:0]   state, next_state;
    reg [130:0] acc;
    reg [129:0] r_reg;
    reg [127:0] s_reg;
    reg         is_first, is_final;

    reg [131:0] p0;
    reg [132:0] p_mid;
    reg [65:0]  mul_a, mul_b;

    // ==========================================
    // 組合邏輯運算 (Combinational Math)
    // ==========================================
    wire [129:0] r_mask = 130'h0_0FFF_FFFC_0FFF_FFFC_0FFF_FFFC_0FFFFFFF;
    wire [64:0]  a0 = acc[64:0];
    wire [65:0]  a1 = acc[130:65];
    wire [64:0]  r0 = r_reg[64:0];
    wire [64:0]  r1 = r_reg[129:65];
    wire [131:0] mul_out = mul_a * mul_b;

    // ST_REDU: Modulo 降維預先計算
    wire [140:0] temp_acc_w = p0 + {p_mid[64:0], 65'd0} + ({p_mid[132:65], 2'b00} + p_mid[132:65]) + ({mul_out, 2'b00} + mul_out);
    wire [130:0] redu_val_w = temp_acc_w[129:0] + ({temp_acc_w[140:130], 2'b00} + temp_acc_w[140:130]);

    // ST_FIN: 最終 Tag 預先計算
    wire [130:0] final_val_pre = acc[129:0] + ({acc[130], 2'b00} + acc[130]);
    wire [130:0] final_val_mod = (final_val_pre >= 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb) ? (final_val_pre - 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb) : final_val_pre;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= ST_IDLE;
        else     state <= next_state;
    end

    always @(*) begin
        next_state = state; // 預設保持當前狀態
        case (state)
            ST_IDLE: if (valid_in) next_state = ST_M1;
            ST_M1:   next_state = ST_M2;
            ST_M2:   next_state = ST_M3;
            ST_M3:   next_state = ST_M4;
            ST_M4:   next_state = ST_REDU;
            ST_REDU: next_state = is_final ? ST_FIN : ST_IDLE;
            ST_FIN:  next_state = ST_IDLE;
            default: next_state = ST_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc      <= 131'd0;
            is_first <= 1'b1;
            is_final <= 1'b0;
            r_reg    <= 130'd0;
            s_reg    <= 128'd0;
            p0       <= 132'd0;
            p_mid    <= 133'd0;
            mul_a    <= 66'd0;
            mul_b    <= 66'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (valid_in) begin
                        is_final <= finalize;
                        if (is_first) begin
                            r_reg    <= {2'b00, mac_key[127:0]} & r_mask;
                            s_reg    <= mac_key[255:128];
                            acc      <= {2'b00, pad_bit, data_in};
                            is_first <= 1'b0;
                        end else begin
                            acc      <= acc + {2'b00, pad_bit, data_in};
                        end
                    end
                end
                ST_M1: begin // 準備計算 A0*R0
                    mul_a <= a0; mul_b <= r0;
                end
                ST_M2: begin // 準備計算 A1*R0，並存下 A0*R0
                    p0    <= mul_out;
                    mul_a <= a1; mul_b <= r0;
                end
                ST_M3: begin // 準備計算 A0*R1，並存下 A1*R0
                    p_mid <= mul_out;
                    mul_a <= a0; mul_b <= r1;
                end
                ST_M4: begin // 準備計算 A1*R1，並累加 A0*R1
                    p_mid <= p_mid + mul_out;
                    mul_a <= a1; mul_b <= r1;
                end
                ST_REDU: begin
                    acc <= redu_val_w; // 載入降維計算結果
                end
                ST_FIN: begin
                    acc      <= 131'd0;
                    is_first <= 1'b1;
                end
            endcase
        end
    end

    // 輸出控制
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready_out <= 1'b1;
            tag_valid <= 1'b0;
            mac_tag   <= 128'd0;
        end else begin
            if (state == ST_IDLE && valid_in)
                ready_out <= 1'b0;
            else if (next_state == ST_IDLE)
                ready_out <= 1'b1;
            if (state == ST_FIN) begin
                mac_tag   <= final_val_mod[127:0] + s_reg;
                tag_valid <= 1'b1;
            end else if (state == ST_IDLE && valid_in) begin
                tag_valid <= 1'b0;
            end
        end
    end

endmodule
