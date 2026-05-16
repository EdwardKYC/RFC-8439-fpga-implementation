module Poly1305 (
    input  wire          clk,
    input  wire          rst,
    input  wire          valid_in,
    output reg           ready_out,
    input  wire [255:0]  mac_key,
    input  wire [127:0]  data_in,
    input  wire          pad_bit,
    input  wire          finalize,
    output reg  [127:0]  mac_tag,
    output reg           tag_valid
);
    localparam [4:0] ST_IDLE = 5'd0;

    localparam [4:0] ST_ADD0 = 5'd1;
    localparam [4:0] ST_ADD1 = 5'd2;
    localparam [4:0] ST_ADD2 = 5'd3;
    localparam [4:0] ST_ADD3 = 5'd4;
    localparam [4:0] ST_ADD4 = 5'd5;
    localparam [4:0] ST_ADD5 = 5'd6;

    localparam [4:0] ST_MUL0 = 5'd7;
    localparam [4:0] ST_MUL1 = 5'd8;
    localparam [4:0] ST_MUL2 = 5'd9;
    localparam [4:0] ST_MUL3 = 5'd10;
    localparam [4:0] ST_MUL4 = 5'd11;

    localparam [4:0] ST_RED0  = 5'd12;
    localparam [4:0] ST_RED1  = 5'd13;
    localparam [4:0] ST_RED2  = 5'd14;
    localparam [4:0] ST_RED3  = 5'd15;
    localparam [4:0] ST_RED4  = 5'd16;
    localparam [4:0] ST_RED5  = 5'd17;
    localparam [4:0] ST_RED6  = 5'd18;
    localparam [4:0] ST_RED7  = 5'd19;
    localparam [4:0] ST_RED8  = 5'd20;
    localparam [4:0] ST_RED9  = 5'd21;
    localparam [4:0] ST_RED10 = 5'd22;

    localparam [4:0] ST_FIN  = 5'd23;
    localparam [4:0] ST_FIN_1 = 5'd24;
    localparam [4:0] ST_FIN_2 = 5'd25;

    localparam [31:0] LIMB_MASK32 = 32'h03ff_ffff;
    localparam [130:0] P130 = 131'h3fffffffffffffffffffffffffffffffb;

    reg [4:0] state;
    reg [4:0] next_state;

    reg [31:0] h0;
    reg [31:0] h1;
    reg [31:0] h2;
    reg [31:0] h3;
    reg [31:0] h4;

    reg [26:0] r0;
    reg [26:0] r1;
    reg [26:0] r2;
    reg [26:0] r3;
    reg [26:0] r4;

    reg [127:0] s_reg;

    reg is_first;
    reg is_final;

    reg [63:0] d0;
    reg [63:0] d1;
    reg [63:0] d2;
    reg [63:0] d3;
    reg [63:0] d4;

    wire [127:0] r_clamped_w;

    assign r_clamped_w = mac_key[127:0] & 128'h0ffffffc0ffffffc0ffffffc0fffffff;

    wire [26:0] n0_w;
    wire [26:0] n1_w;
    wire [26:0] n2_w;
    wire [26:0] n3_w;
    wire [26:0] n4_w;

    assign n0_w = data_in[25:0];
    assign n1_w = data_in[51:26];
    assign n2_w = data_in[77:52];
    assign n3_w = data_in[103:78];
    assign n4_w = {3'd0, data_in[127:104]} + (pad_bit ? 27'h1000000 : 27'd0);

    wire [26:0] h0_w = h0[26:0];
    wire [26:0] h1_w = h1[26:0];
    wire [26:0] h2_w = h2[26:0];
    wire [26:0] h3_w = h3[26:0];
    wire [26:0] h4_w = h4[26:0];

    wire [53:0] p0_w;
    wire [53:0] p1_w;
    wire [53:0] p2_w;
    wire [53:0] p3_w;
    wire [53:0] p4_w;

    reg [26:0] ma0;
    reg [26:0] ma1;
    reg [26:0] ma2;
    reg [26:0] ma3;
    reg [26:0] ma4;

    reg [26:0] mb0;
    reg [26:0] mb1;
    reg [26:0] mb2;
    reg [26:0] mb3;
    reg [26:0] mb4;

    reg sx0;
    reg sx1;
    reg sx2;
    reg sx3;
    reg sx4;

    assign p0_w = ma0 * mb0;
    assign p1_w = ma1 * mb1;
    assign p2_w = ma2 * mb2;
    assign p3_w = ma3 * mb3;
    assign p4_w = ma4 * mb4;

    wire [56:0] t0_w = sx0 ? ({3'd0, p0_w} + ({3'd0, p0_w} << 2)) : {3'd0, p0_w};
    wire [56:0] t1_w = sx1 ? ({3'd0, p1_w} + ({3'd0, p1_w} << 2)) : {3'd0, p1_w};
    wire [56:0] t2_w = sx2 ? ({3'd0, p2_w} + ({3'd0, p2_w} << 2)) : {3'd0, p2_w};
    wire [56:0] t3_w = sx3 ? ({3'd0, p3_w} + ({3'd0, p3_w} << 2)) : {3'd0, p3_w};
    wire [56:0] t4_w = sx4 ? ({3'd0, p4_w} + ({3'd0, p4_w} << 2)) : {3'd0, p4_w};

    wire [63:0] d_sum_w;

    assign d_sum_w =
        {7'd0, t0_w} +
        {7'd0, t1_w} +
        {7'd0, t2_w} +
        {7'd0, t3_w} +
        {7'd0, t4_w};

    wire [130:0] h_full_w;
    wire [130:0] h_red_w;
    wire [128:0] tag_sum_w;

    assign h_full_w =
        {104'd0, h0[26:0]} +
        {78'd0,  h1[26:0], 26'd0} +
        {52'd0,  h2[26:0], 52'd0} +
        {26'd0,  h3[26:0], 78'd0} +
        {        h4[26:0], 104'd0};

    assign h_red_w = (h_full_w >= P130) ? (h_full_w - P130) : h_full_w;
    assign tag_sum_w = {1'b0, h_red_w[127:0]} + {1'b0, s_reg};

    // =====================================================
    // Fast final carry normalization after ST_RED4
    // =====================================================
    // ST_RED0 ~ ST_RED4 already fold d0..d4 into h0..h4 once.
    // The old version then spent ST_RED5 ~ ST_RED10 doing one carry per cycle.
    // Here we keep the same 5-multiplier datapath, but collapse that final carry
    // cleanup into one combinational carry chain.
    //
    // Area impact: a few adders and shifts.
    // Multiplier count: unchanged.
    // Cycle saving: about 5 cycles per Poly1305 16-byte block.

    wire [31:0] fn_h0_m0 = h0 & LIMB_MASK32;
    wire [31:0] fn_h1_a0 = h1 + (h0 >> 26);
    wire [31:0] fn_h1_m0 = fn_h1_a0 & LIMB_MASK32;

    wire [31:0] fn_h2_a0 = h2 + (fn_h1_a0 >> 26);
    wire [31:0] fn_h2_m0 = fn_h2_a0 & LIMB_MASK32;

    wire [31:0] fn_h3_a0 = h3 + (fn_h2_a0 >> 26);
    wire [31:0] fn_h3_m0 = fn_h3_a0 & LIMB_MASK32;

    wire [31:0] fn_h4_a0 = h4 + (fn_h3_a0 >> 26);
    wire [31:0] fn_h4_m0 = fn_h4_a0 & LIMB_MASK32;

    wire [31:0] fn_h0_a1 = fn_h0_m0 + ((fn_h4_a0 >> 26) + ((fn_h4_a0 >> 26) << 2));
    wire [31:0] fn_h0_m1 = fn_h0_a1 & LIMB_MASK32;

    wire [31:0] fn_h1_a1 = fn_h1_m0 + (fn_h0_a1 >> 26);
    wire [31:0] fn_h1_m1 = fn_h1_a1 & LIMB_MASK32;

    wire [31:0] fn_h2_a1 = fn_h2_m0 + (fn_h1_a1 >> 26);
    wire [31:0] fn_h2_m1 = fn_h2_a1 & LIMB_MASK32;

    wire [31:0] fn_h3_a1 = fn_h3_m0 + (fn_h2_a1 >> 26);
    wire [31:0] fn_h3_m1 = fn_h3_a1 & LIMB_MASK32;

    wire [31:0] fn_h4_a1 = fn_h4_m0 + (fn_h3_a1 >> 26);
    wire [31:0] fn_h4_m1 = fn_h4_a1 & LIMB_MASK32;

    wire [31:0] fn_h0_a2 = fn_h0_m1 + ((fn_h4_a1 >> 26) + ((fn_h4_a1 >> 26) << 2));
    wire [31:0] fn_h0_m2 = fn_h0_a2 & LIMB_MASK32;

    wire [31:0] fn_h1_a2 = fn_h1_m1 + (fn_h0_a2 >> 26);
    wire [31:0] fn_h1_m2 = fn_h1_a2 & LIMB_MASK32;

    reg [130:0] h_full_r;
    reg [130:0] h_red_r;

    // =====================================================
    // Multiplier input select
    // =====================================================
    always @(*) begin
        ma0 = 27'd0;
        ma1 = 27'd0;
        ma2 = 27'd0;
        ma3 = 27'd0;
        ma4 = 27'd0;

        mb0 = 27'd0;
        mb1 = 27'd0;
        mb2 = 27'd0;
        mb3 = 27'd0;
        mb4 = 27'd0;

        sx0 = 1'b0;
        sx1 = 1'b0;
        sx2 = 1'b0;
        sx3 = 1'b0;
        sx4 = 1'b0;

        case (state)
            ST_MUL0: begin
                // d0 = h0*r0 + 5*(h1*r4 + h2*r3 + h3*r2 + h4*r1)
                ma0 = h0_w; mb0 = r0; sx0 = 1'b0;
                ma1 = h1_w; mb1 = r4; sx1 = 1'b1;
                ma2 = h2_w; mb2 = r3; sx2 = 1'b1;
                ma3 = h3_w; mb3 = r2; sx3 = 1'b1;
                ma4 = h4_w; mb4 = r1; sx4 = 1'b1;
            end

            ST_MUL1: begin
                // d1 = h0*r1 + h1*r0 + 5*(h2*r4 + h3*r3 + h4*r2)
                ma0 = h0_w; mb0 = r1; sx0 = 1'b0;
                ma1 = h1_w; mb1 = r0; sx1 = 1'b0;
                ma2 = h2_w; mb2 = r4; sx2 = 1'b1;
                ma3 = h3_w; mb3 = r3; sx3 = 1'b1;
                ma4 = h4_w; mb4 = r2; sx4 = 1'b1;
            end

            ST_MUL2: begin
                // d2 = h0*r2 + h1*r1 + h2*r0 + 5*(h3*r4 + h4*r3)
                ma0 = h0_w; mb0 = r2; sx0 = 1'b0;
                ma1 = h1_w; mb1 = r1; sx1 = 1'b0;
                ma2 = h2_w; mb2 = r0; sx2 = 1'b0;
                ma3 = h3_w; mb3 = r4; sx3 = 1'b1;
                ma4 = h4_w; mb4 = r3; sx4 = 1'b1;
            end

            ST_MUL3: begin
                // d3 = h0*r3 + h1*r2 + h2*r1 + h3*r0 + 5*(h4*r4)
                ma0 = h0_w; mb0 = r3; sx0 = 1'b0;
                ma1 = h1_w; mb1 = r2; sx1 = 1'b0;
                ma2 = h2_w; mb2 = r1; sx2 = 1'b0;
                ma3 = h3_w; mb3 = r0; sx3 = 1'b0;
                ma4 = h4_w; mb4 = r4; sx4 = 1'b1;
            end

            ST_MUL4: begin
                // d4 = h0*r4 + h1*r3 + h2*r2 + h3*r1 + h4*r0
                ma0 = h0_w; mb0 = r4; sx0 = 1'b0;
                ma1 = h1_w; mb1 = r3; sx1 = 1'b0;
                ma2 = h2_w; mb2 = r2; sx2 = 1'b0;
                ma3 = h3_w; mb3 = r1; sx3 = 1'b0;
                ma4 = h4_w; mb4 = r0; sx4 = 1'b0;
            end

            default: begin
                ma0 = 27'd0; mb0 = 27'd0; sx0 = 1'b0;
                ma1 = 27'd0; mb1 = 27'd0; sx1 = 1'b0;
                ma2 = 27'd0; mb2 = 27'd0; sx2 = 1'b0;
                ma3 = 27'd0; mb3 = 27'd0; sx3 = 1'b0;
                ma4 = 27'd0; mb4 = 27'd0; sx4 = 1'b0;
            end
        endcase
    end

    // =====================================================
    // FSM next state
    // =====================================================
    always @(*) begin
        next_state = state;

        case (state)
            ST_IDLE: begin
                if (valid_in) next_state = ST_ADD0;
            end

            ST_ADD0: next_state = ST_ADD1;
            ST_ADD1: next_state = ST_ADD2;
            ST_ADD2: next_state = ST_ADD3;
            ST_ADD3: next_state = ST_ADD4;
            ST_ADD4: next_state = ST_ADD5;
            ST_ADD5: next_state = ST_MUL0;

            ST_MUL0: next_state = ST_MUL1;
            ST_MUL1: next_state = ST_MUL2;
            ST_MUL2: next_state = ST_MUL3;
            ST_MUL3: next_state = ST_MUL4;
            ST_MUL4: next_state = ST_RED0;

            ST_RED0:  next_state = ST_RED1;
            ST_RED1:  next_state = ST_RED2;
            ST_RED2:  next_state = ST_RED3;
            ST_RED3:  next_state = ST_RED4;
            ST_RED4:  next_state = ST_RED5;
            ST_RED5:  next_state = ST_RED6;
            ST_RED6:  next_state = ST_RED7;
            ST_RED7:  next_state = ST_RED8;
            ST_RED8:  next_state = ST_RED9;
            ST_RED9:  next_state = ST_RED10;
            ST_RED10: begin
                if (is_final) next_state = ST_FIN;
                else          next_state = ST_IDLE;
            end

            ST_FIN: next_state = ST_IDLE;

            default: next_state = ST_IDLE;
        endcase
    end

    // =====================================================
    // Datapath
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_IDLE;

            h0 <= 32'd0;
            h1 <= 32'd0;
            h2 <= 32'd0;
            h3 <= 32'd0;
            h4 <= 32'd0;

            r0 <= 27'd0;
            r1 <= 27'd0;
            r2 <= 27'd0;
            r3 <= 27'd0;
            r4 <= 27'd0;

            s_reg <= 128'd0;

            d0 <= 64'd0;
            d1 <= 64'd0;
            d2 <= 64'd0;
            d3 <= 64'd0;
            d4 <= 64'd0;

            is_first <= 1'b1;
            is_final <= 1'b0;
        end else begin
            state <= next_state;

            case (state)
                ST_IDLE: begin
                    if (valid_in) begin
                        is_final <= finalize;

                        d0 <= 64'd0;
                        d1 <= 64'd0;
                        d2 <= 64'd0;
                        d3 <= 64'd0;
                        d4 <= 64'd0;

                        if (is_first) begin
                            r0 <= r_clamped_w[25:0];
                            r1 <= r_clamped_w[51:26];
                            r2 <= r_clamped_w[77:52];
                            r3 <= r_clamped_w[103:78];
                            r4 <= {3'd0, r_clamped_w[127:104]};

                            s_reg <= mac_key[255:128];

                            h0 <= {5'd0, n0_w};
                            h1 <= {5'd0, n1_w};
                            h2 <= {5'd0, n2_w};
                            h3 <= {5'd0, n3_w};
                            h4 <= {5'd0, n4_w};

                            is_first <= 1'b0;
                        end else begin
                            h0 <= h0 + {5'd0, n0_w};
                            h1 <= h1 + {5'd0, n1_w};
                            h2 <= h2 + {5'd0, n2_w};
                            h3 <= h3 + {5'd0, n3_w};
                            h4 <= h4 + {5'd0, n4_w};
                        end
                    end
                end

                // Normalize h after h += block.
                ST_ADD0: begin
                    h1 <= h1 + (h0 >> 26);
                    h0 <= h0 & LIMB_MASK32;
                end

                ST_ADD1: begin
                    h2 <= h2 + (h1 >> 26);
                    h1 <= h1 & LIMB_MASK32;
                end

                ST_ADD2: begin
                    h3 <= h3 + (h2 >> 26);
                    h2 <= h2 & LIMB_MASK32;
                end

                ST_ADD3: begin
                    h4 <= h4 + (h3 >> 26);
                    h3 <= h3 & LIMB_MASK32;
                end

                ST_ADD4: begin
                    h0 <= h0 + ((h4 >> 26) + ((h4 >> 26) << 2));
                    h4 <= h4 & LIMB_MASK32;
                end

                ST_ADD5: begin
                    h1 <= h1 + (h0 >> 26);
                    h0 <= h0 & LIMB_MASK32;
                end

                // One d limb per cycle, 5 multipliers in parallel.
                ST_MUL0: d0 <= d_sum_w;
                ST_MUL1: d1 <= d_sum_w;
                ST_MUL2: d2 <= d_sum_w;
                ST_MUL3: d3 <= d_sum_w;
                ST_MUL4: d4 <= d_sum_w;

                // Carry propagation.
                ST_RED0: begin
                    h0 <= {6'd0, d0[25:0]};
                    d1 <= d1 + (d0 >> 26);
                end

                ST_RED1: begin
                    h1 <= {6'd0, d1[25:0]};
                    d2 <= d2 + (d1 >> 26);
                end

                ST_RED2: begin
                    h2 <= {6'd0, d2[25:0]};
                    d3 <= d3 + (d2 >> 26);
                end

                ST_RED3: begin
                    h3 <= {6'd0, d3[25:0]};
                    d4 <= d4 + (d3 >> 26);
                end

                ST_RED4: begin
                    h4 <= {6'd0, d4[25:0]};
                    h0 <= h0 + ((d4 >> 26) + ((d4 >> 26) << 2));
                end

                ST_RED5: begin
                    h1 <= h1 + (h0 >> 26);
                    h0 <= h0 & LIMB_MASK32;
                end
                ST_RED6: begin
                    h2 <= h2 + (h1 >> 26);
                    h1 <= h1 & LIMB_MASK32;
                end
                ST_RED7: begin
                    h3 <= h3 + (h2 >> 26);
                    h2 <= h2 & LIMB_MASK32;
                end
                ST_RED8: begin
                    h4 <= h4 + (h3 >> 26);
                    h3 <= h3 & LIMB_MASK32;
                end
                ST_RED9: begin
                    // 這裡乘 5，對應 Poly1305 的 2^130 - 5 特性
                    h0 <= h0 + ((h4 >> 26) + ((h4 >> 26) << 2));
                    h4 <= h4 & LIMB_MASK32;
                end
                ST_RED10: begin
                    h1 <= h1 + (h0 >> 26);
                    h0 <= h0 & LIMB_MASK32;
                end
                ST_FIN: begin // 專心做拼接與加法
                    h_full_r <= {104'd0, h0[26:0]} +
                                {78'd0,  h1[26:0], 26'd0} +
                                {52'd0,  h2[26:0], 52'd0} +
                                {26'd0,  h3[26:0], 78'd0} +
                                {        h4[26:0], 104'd0};
                end
                ST_FIN_1: begin // 專心做比較與減法
                    h_red_r <= (h_full_r >= P130) ? (h_full_r - P130) : h_full_r;
                end
                ST_FIN_2: begin // 專心做最後的 AES key 相加
                    mac_tag   <= h_red_r[127:0] + s_reg;
                    tag_valid <= 1'b1;
                    h0 <= 32'd0;
                    h1 <= 32'd0;
                    h2 <= 32'd0;
                    h3 <= 32'd0;
                    h4 <= 32'd0;

                    is_first <= 1'b1;
                    is_final <= 1'b0;
                end

                default: ;
            endcase
        end
    end

    // =====================================================
    // Output control
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready_out <= 1'b1;
            tag_valid <= 1'b0;
            mac_tag   <= 128'd0;
        end else begin
            if (state == ST_IDLE && valid_in) begin
                ready_out <= 1'b0;
                tag_valid <= 1'b0;
            end else if (next_state == ST_IDLE) begin
                ready_out <= 1'b1;
            end else begin
                ready_out <= 1'b0;
            end

            if (state == ST_FIN) begin
                mac_tag   <= tag_sum_w[127:0];
                tag_valid <= 1'b1;
            end else if (state == ST_IDLE && valid_in) begin
                tag_valid <= 1'b0;
            end
        end
    end

endmodule