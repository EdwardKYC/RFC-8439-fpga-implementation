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
    localparam [2:0] ST_IDLE = 3'd0,
                     ST_M1   = 3'd1, // 計算 A0 * R0
                     ST_M2   = 3'd2, // 計算 A1 * R0
                     ST_M3   = 3'd3, // 計算 A0 * R1
                     ST_M4   = 3'd4, // 計算 A1 * R1
                     ST_REDU = 3'd5, // 組合結果並進行 Modulo 降維
                     ST_FIN  = 3'd6;

    reg [2:0] state;

    reg [130:0] acc;            // 累加器 (保持在 ~131 bits)
    reg [129:0] r_reg;
    reg [127:0] s_reg;
    reg         is_first;
    reg         is_final;

    // 中間乘積暫存器
    reg [131:0] p0;             // 儲存 A0 * R0
    reg [132:0] p_mid;          // 儲存 (A1*R0 + A0*R1)
    reg [140:0] temp_acc;
    reg [130:0] final_val;
    
    // 分割輸入以便小型乘法器使用 (65-bit limbs)
    // acc = A1 * 2^65 + A0
    wire [64:0] a0 = acc[64:0];
    wire [65:0] a1 = acc[130:65];
    
    // r = R1 * 2^65 + R0
    wire [64:0] r0 = r_reg[64:0];
    wire [64:0] r1 = r_reg[129:65];

    // 共享乘法器元件
    reg  [65:0] mul_a, mul_b;
    wire [131:0] mul_out = mul_a * mul_b;

    // RFC 8439 Mask
    wire [129:0] r_mask = 130'h0_0FFF_FFFC_0FFF_FFFC_0FFF_FFFC_0FFFFFFF;

    // ==========================================
    // 核心 FSM
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= ST_IDLE;
            ready_out <= 1'b1;
            tag_valid <= 1'b0;
            acc       <= 131'd0;
            is_first  <= 1'b1;
            mac_tag   <= 128'd0;

            // 重置中間變數 (非強制，但對 GLS 比較好)
            mul_a <= 66'd0; mul_b <= 66'd0;
            p0 <= 132'd0; p_mid <= 133'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    tag_valid <= 1'b0;
                    ready_out <= 1'b1;
                    if (valid_in) begin
                        ready_out <= 1'b0;
                        is_final  <= finalize;
                        if (is_first) begin
                            r_reg    <= {2'b00, mac_key[127:0]} & r_mask;
                            s_reg    <= mac_key[255:128];
                            acc      <= {2'b00, pad_bit, data_in};
                            is_first <= 1'b0;
                        end else begin
                            acc      <= acc + {2'b00, pad_bit, data_in};
                        end
                        state <= ST_M1;
                    end
                end
                ST_M1: begin// Step 1: A0 * R0
                    mul_a <= a0; mul_b <= r0;
                    state <= ST_M2;
                end
                ST_M2: begin// Step 2: A1 * R0
                    p0    <= mul_out; // 鎖存 A0 * R0
                    mul_a <= a1; mul_b <= r0;
                    state <= ST_M3;
                end
                ST_M3: begin// Step 3: A0 * R1
                    p_mid <= mul_out; // 鎖存 A1 * R0
                    mul_a <= a0; mul_b <= r1;
                    state <= ST_M4;
                end
                ST_M4: begin// Step 4: A1 * R1
                    p_mid <= p_mid + mul_out; // 鎖存 (A1*R0 + A0*R1)
                    mul_a <= a1; mul_b <= r1;
                    state <= ST_REDU;
                end
                ST_REDU: begin
                    temp_acc = p0 + {p_mid[64:0], 65'd0} + ({p_mid[132:65], 2'b00} + p_mid[132:65]) + ({mul_out, 2'b00} + mul_out);
                    acc <= temp_acc[129:0] + ({temp_acc[140:130], 2'b00} + temp_acc[140:130]);

                    if (is_final) state <= ST_FIN;
                    else          state <= ST_IDLE;
                end
                ST_FIN: begin
                    final_val = acc[129:0] + ({acc[130], 2'b00} + acc[130]);

                    if (final_val >= 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb) begin
                        final_val = final_val - 131'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFb;
                    end

                    mac_tag   <= final_val[127:0] + s_reg;
                    tag_valid <= 1'b1;
                    ready_out <= 1'b1;
                    acc       <= 131'd0;
                    is_first  <= 1'b1;
                    state     <= ST_IDLE;
                end
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule