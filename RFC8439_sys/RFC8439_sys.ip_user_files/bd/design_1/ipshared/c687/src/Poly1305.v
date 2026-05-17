/*
 * -------------------------------------------------------------------------
 * Poly1305 MAC 核心加速器 (Radix-2^26, 5-Stage Pipelined, SCS Architecture)
 * -------------------------------------------------------------------------
 * 已修正:
 * 1. 增加 data_in, s_val, finalize 的鎖存器(Latch)，對齊 Pipeline 時序。
 * 2. 修正 ST_FREEZE1 中的 Verilog 位移截斷 (Bit-width Truncation) 問題。
 * 3. 擴展 h_full 為 132-bit 防止極端進位溢出。
 */

module Poly1305 (
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_in,
    input  wire [255:0] mac_key,
    input  wire [127:0] data_in,
    input  wire         pad_bit,
    input  wire         finalize,
    output reg          ready_out,
    output reg  [127:0] mac_tag,
    output reg          tag_valid
);

    // =========================================================================
    // 參數定義
    // =========================================================================
    // GF(2^130-5) 質數定義 (擴充至 132-bit 以匹配 h_full)
    localparam [131:0] P130 = 132'h03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB; 
    
    localparam [3:0] ST_IDLE    = 4'd0;
    localparam [3:0] ST_ADD     = 4'd1;
    localparam [3:0] ST_MUL     = 4'd2;
    localparam [3:0] ST_SUM     = 4'd3;
    localparam [3:0] ST_CARRY1  = 4'd4;
    localparam [3:0] ST_CARRY2  = 4'd5;
    localparam [3:0] ST_WAIT    = 4'd6;
    localparam [3:0] ST_FREEZE1 = 4'd7;
    localparam [3:0] ST_FREEZE2 = 4'd8;
    localparam [3:0] ST_DONE    = 4'd9;

    reg [3:0] current_state, next_state;

    // =========================================================================
    // 輸入截取與分解邏輯 (Combinational)
    // =========================================================================
    wire [127:0] r_clamped = mac_key[127:0] & 128'h0ffffffc_0ffffffc_0ffffffc_0fffffff;
    wire [127:0] s_val     = mac_key[255:128];

    wire [25:0] r0_w = r_clamped[25:0];
    wire [25:0] r1_w = r_clamped[51:26];
    wire [25:0] r2_w = r_clamped[77:52];
    wire [25:0] r3_w = r_clamped[103:78];
    wire [25:0] r4_w = {2'b00, r_clamped[127:104]};

    wire [28:0] r1_5_w = r1_w * 5;
    wire [28:0] r2_5_w = r2_w * 5;
    wire [28:0] r3_5_w = r3_w * 5;
    wire [28:0] r4_5_w = r4_w * 5;

    wire [25:0] c0_w = data_in[25:0];
    wire [25:0] c1_w = data_in[51:26];
    wire [25:0] c2_w = data_in[77:52];
    wire [25:0] c3_w = data_in[103:78];
    wire [25:0] c4_w = {1'b0, pad_bit, data_in[127:104]};

    // =========================================================================
    // 內部管線化暫存器
    // =========================================================================
    // 控制與輸入鎖存 (重要修正)
    reg finalize_req;
    reg [127:0] s_val_reg;
    reg [25:0] c0, c1, c2, c3, c4;

    reg [25:0] r0, r1, r2, r3, r4;
    reg [28:0] r1_5, r2_5, r3_5, r4_5;

    reg [27:0] h0, h1, h2, h3, h4;
    reg [27:0] H0_add, H1_add, H2_add, H3_add, H4_add;

    reg [55:0] p00, p01, p02, p03, p04;
    reg [55:0] p10, p11, p12, p13, p14;
    reg [55:0] p20, p21, p22, p23, p24;
    reg [55:0] p30, p31, p32, p33, p34;
    reg [55:0] p40, p41, p42, p43, p44;

    reg [59:0] d0, d1, d2, d3, d4;
    reg [39:0] hc0, hc1, hc2, hc3, hc4;

    // 寬度擴充至 132-bit 防止 Carry Overflow (重要修正)
    reg  [131:0] h_full;
    wire [131:0] h_sub = h_full - P130;
    wire [129:0] h_mod = (h_full >= P130) ? h_sub[129:0] : h_full[129:0];

    // =========================================================================
    // FSM: State Register
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= ST_IDLE;
        else     current_state <= next_state;
    end

    // =========================================================================
    // FSM: Next State Logic
    // =========================================================================
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:    if (valid_in) next_state = ST_ADD;
            ST_ADD:     next_state = ST_MUL;
            ST_MUL:     next_state = ST_SUM;
            ST_SUM:     next_state = ST_CARRY1;
            ST_CARRY1:  next_state = ST_CARRY2;
            ST_CARRY2:  begin
                            // 修正：檢查鎖存的 finalize_req 確保不漏接
                            if (finalize_req) next_state = ST_FREEZE1;
                            else              next_state = ST_WAIT;
                        end
            ST_WAIT:    begin
                            if (valid_in) next_state = ST_ADD;
                            else if (finalize_req || finalize) next_state = ST_FREEZE1;
                        end
            ST_FREEZE1: next_state = ST_FREEZE2;
            ST_FREEZE2: next_state = ST_DONE;
            ST_DONE:    next_state = ST_IDLE;
            default:    next_state = ST_IDLE;
        endcase
    end

    // =========================================================================
    // FSM: Output & Data Path
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready_out <= 1'b0;
            tag_valid <= 1'b0;
            mac_tag   <= 128'd0;
            
            finalize_req <= 1'b0;
            s_val_reg <= 128'd0;
            c0 <= 26'd0; c1 <= 26'd0; c2 <= 26'd0; c3 <= 26'd0; c4 <= 26'd0;

            h0 <= 28'd0; h1 <= 28'd0; h2 <= 28'd0; h3 <= 28'd0; h4 <= 28'd0;
            r0 <= 26'd0; r1 <= 26'd0; r2 <= 26'd0; r3 <= 26'd0; r4 <= 26'd0;
            r1_5 <= 29'd0; r2_5 <= 29'd0; r3_5 <= 29'd0; r4_5 <= 29'd0;
            
            // ... (為縮減版面，略去初始化其餘管線站 p, d, hc 的歸零，建議實務上可保留或利用 rst 統一處理)
            h_full <= 132'd0;
        end else begin
            tag_valid <= 1'b0;

            if (next_state == ST_IDLE || next_state == ST_WAIT)
                ready_out <= 1'b1;
            else
                ready_out <= 1'b0;

            // --- 訊號鎖存邏輯 (解決 Issue #2 & #3) ---
            if (valid_in && (current_state == ST_IDLE || current_state == ST_WAIT)) begin
                c0 <= c0_w; c1 <= c1_w; c2 <= c2_w; c3 <= c3_w; c4 <= c4_w;
                if (finalize) finalize_req <= 1'b1;
            end
            
            // --- 核心資料路徑 ---
            case (current_state)
                ST_IDLE: begin
                    h0 <= 28'd0; h1 <= 28'd0; h2 <= 28'd0; h3 <= 28'd0; h4 <= 28'd0;
                    if (valid_in) begin
                        r0 <= r0_w; r1 <= r1_w; r2 <= r2_w; r3 <= r3_w; r4 <= r4_w;
                        r1_5 <= r1_5_w; r2_5 <= r2_5_w; r3_5 <= r3_5_w; r4_5 <= r4_5_w;
                        s_val_reg <= s_val; // 鎖存 s_val 供最後階段使用
                    end
                end

                ST_ADD: begin
                    // 修正：使用鎖存的 c 暫存器，確保資料正確
                    H0_add <= h0 + c0;
                    H1_add <= h1 + c1;
                    H2_add <= h2 + c2;
                    H3_add <= h3 + c3;
                    H4_add <= h4 + c4;
                end

                ST_MUL: begin
                    p00 <= H0_add * r0;   p01 <= H0_add * r1;   p02 <= H0_add * r2;   p03 <= H0_add * r3;   p04 <= H0_add * r4;
                    p10 <= H1_add * r0;   p11 <= H1_add * r1;   p12 <= H1_add * r2;   p13 <= H1_add * r3;   p14 <= H1_add * r4_5;  
                    p20 <= H2_add * r0;   p21 <= H2_add * r1;   p22 <= H2_add * r2;   p23 <= H2_add * r3_5; p24 <= H2_add * r4_5;
                    p30 <= H3_add * r0;   p31 <= H3_add * r1;   p32 <= H3_add * r2_5; p33 <= H3_add * r3_5; p34 <= H3_add * r4_5;
                    p40 <= H4_add * r0;   p41 <= H4_add * r1_5; p42 <= H4_add * r2_5; p43 <= H4_add * r3_5; p44 <= H4_add * r4_5;
                end

                ST_SUM: begin
                    d0 <= p00 + p14 + p23 + p32 + p41;
                    d1 <= p01 + p10 + p24 + p33 + p42;
                    d2 <= p02 + p11 + p20 + p34 + p43;
                    d3 <= p03 + p12 + p21 + p30 + p44;
                    d4 <= p04 + p13 + p22 + p31 + p40;
                end

                ST_CARRY1: begin
                    hc0 <= d0[25:0] + (d4 >> 26) * 5;
                    hc1 <= d1[25:0] + (d0 >> 26);
                    hc2 <= d2[25:0] + (d1 >> 26);
                    hc3 <= d3[25:0] + (d2 >> 26);
                    hc4 <= d4[25:0] + (d3 >> 26);
                end

                ST_CARRY2: begin
                    h0 <= hc0[25:0] + (hc4 >> 26) * 5;
                    h1 <= hc1[25:0] + (hc0 >> 26);
                    h2 <= hc2[25:0] + (hc1 >> 26);
                    h3 <= hc3[25:0] + (hc2 >> 26);
                    h4 <= hc4[25:0] + (hc3 >> 26);
                end

                ST_FREEZE1: begin
                    // 修正：強制顯式補 0 (Zero-Padding) 擴展位元寬度，避免 Shift Truncation
                    h_full <= ({104'd0, h0}) + 
                              ({104'd0, h1} << 26) + 
                              ({104'd0, h2} << 52) + 
                              ({104'd0, h3} << 78) + 
                              ({104'd0, h4} << 104);
                end

                ST_FREEZE2: begin
                    // 修正：使用鎖存的 s_val_reg
                    mac_tag <= h_mod[127:0] + s_val_reg;
                end

                ST_DONE: begin
                    tag_valid <= 1'b1;
                    finalize_req <= 1'b0; // 運算結束，清空狀態
                end
            endcase
        end
    end

endmodule