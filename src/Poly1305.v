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
    localparam [5:0] ST_IDLE = 6'd0;

    localparam [5:0] ST_ADD0 = 6'd1;
    localparam [5:0] ST_ADD1 = 6'd2;
    localparam [5:0] ST_ADD2 = 6'd3;
    localparam [5:0] ST_ADD3 = 6'd4;
    localparam [5:0] ST_ADD4 = 6'd5;
    localparam [5:0] ST_ADD5 = 6'd6;

    localparam [5:0] ST_MUL0_LOAD = 6'd7;
    localparam [5:0] ST_MUL0_SAVE = 6'd8;
    localparam [5:0] ST_MUL1_LOAD = 6'd9;
    localparam [5:0] ST_MUL1_SAVE = 6'd10;
    localparam [5:0] ST_MUL2_LOAD = 6'd11;
    localparam [5:0] ST_MUL2_SAVE = 6'd12;
    localparam [5:0] ST_MUL3_LOAD = 6'd13;
    localparam [5:0] ST_MUL3_SAVE = 6'd14;
    localparam [5:0] ST_MUL4_LOAD = 6'd15;
    localparam [5:0] ST_MUL4_SAVE = 6'd16;

    localparam [5:0] ST_RED0 = 6'd17;
    localparam [5:0] ST_RED1 = 6'd18;
    localparam [5:0] ST_RED2 = 6'd19;
    localparam [5:0] ST_RED3 = 6'd20;
    localparam [5:0] ST_RED4 = 6'd21;
    localparam [5:0] ST_RED5 = 6'd22;
    localparam [5:0] ST_RED6 = 6'd23;
    localparam [5:0] ST_RED7 = 6'd24;

    localparam [5:0] ST_FIN_PACK = 6'd25;
    localparam [5:0] ST_FIN_RED  = 6'd26;
    localparam [5:0] ST_FIN_ADD  = 6'd27;
    localparam [5:0] ST_FIN_DONE = 6'd28;

    localparam [31:0] LIMB_MASK32 = 32'h03ff_ffff;
    localparam [130:0] P130 = 131'h3fffffffffffffffffffffffffffffffb;

    reg [5:0] state;
    reg [5:0] next_state;

    reg [31:0] h0, h1, h2, h3, h4;
    reg [26:0] r0, r1, r2, r3, r4;
    reg [127:0] s_reg;

    reg is_first;
    reg is_final;

    reg [63:0] d0, d1, d2, d3, d4;

    reg [130:0] h_full_reg;
    reg [130:0] h_red_reg;
    reg [127:0] tag_sum_reg;

    wire [127:0] r_clamped_w;
    assign r_clamped_w = mac_key[127:0] & 128'h0ffffffc0ffffffc0ffffffc0fffffff;

    wire [26:0] n0_w = data_in[25:0];
    wire [26:0] n1_w = data_in[51:26];
    wire [26:0] n2_w = data_in[77:52];
    wire [26:0] n3_w = data_in[103:78];
    wire [26:0] n4_w = {3'd0, data_in[127:104]} + (pad_bit ? 27'h1000000 : 27'd0);

    wire [26:0] h0_w = h0[26:0];
    wire [26:0] h1_w = h1[26:0];
    wire [26:0] h2_w = h2[26:0];
    wire [26:0] h3_w = h3[26:0];
    wire [26:0] h4_w = h4[26:0];

    reg [26:0] ma0, ma1, ma2, ma3, ma4;
    reg [26:0] mb0, mb1, mb2, mb3, mb4;
    reg sx0, sx1, sx2, sx3, sx4;

    wire [53:0] p0_w = ma0 * mb0;
    wire [53:0] p1_w = ma1 * mb1;
    wire [53:0] p2_w = ma2 * mb2;
    wire [53:0] p3_w = ma3 * mb3;
    wire [53:0] p4_w = ma4 * mb4;

    wire [56:0] t0_w = sx0 ? ({3'd0, p0_w} + ({3'd0, p0_w} << 2)) : {3'd0, p0_w};
    wire [56:0] t1_w = sx1 ? ({3'd0, p1_w} + ({3'd0, p1_w} << 2)) : {3'd0, p1_w};
    wire [56:0] t2_w = sx2 ? ({3'd0, p2_w} + ({3'd0, p2_w} << 2)) : {3'd0, p2_w};
    wire [56:0] t3_w = sx3 ? ({3'd0, p3_w} + ({3'd0, p3_w} << 2)) : {3'd0, p3_w};
    wire [56:0] t4_w = sx4 ? ({3'd0, p4_w} + ({3'd0, p4_w} << 2)) : {3'd0, p4_w};

    wire [63:0] d_sum_w =
        {7'd0, t0_w} +
        {7'd0, t1_w} +
        {7'd0, t2_w} +
        {7'd0, t3_w} +
        {7'd0, t4_w};

    wire [31:0] red5_h0_m = h0 & LIMB_MASK32;
    wire [31:0] red5_h1_a = h1 + (h0 >> 26);
    wire [31:0] red5_h1_m = red5_h1_a & LIMB_MASK32;
    wire [31:0] red5_h2_a = h2 + (red5_h1_a >> 26);

    wire [31:0] red6_h2_m = h2 & LIMB_MASK32;
    wire [31:0] red6_h3_a = h3 + (h2 >> 26);
    wire [31:0] red6_h3_m = red6_h3_a & LIMB_MASK32;
    wire [31:0] red6_h4_a = h4 + (red6_h3_a >> 26);

    wire [31:0] red7_h4_m = h4 & LIMB_MASK32;
    wire [31:0] red7_h0_a = h0 + ((h4 >> 26) + ((h4 >> 26) << 2));
    wire [31:0] red7_h0_m = red7_h0_a & LIMB_MASK32;
    wire [31:0] red7_h1_a = h1 + (red7_h0_a >> 26);

    wire [130:0] h_full_w =
        {104'd0, h0[26:0]} +
        {78'd0,  h1[26:0], 26'd0} +
        {52'd0,  h2[26:0], 52'd0} +
        {26'd0,  h3[26:0], 78'd0} +
        {        h4[26:0], 104'd0};

    wire [130:0] h_red_w =
        (h_full_reg >= P130) ? (h_full_reg - P130) : h_full_reg;

    wire [128:0] tag_sum_w =
        {1'b0, h_red_reg[127:0]} + {1'b0, s_reg};

    always @(*) begin
        next_state = state;

        case (state)
            ST_IDLE: if (valid_in) next_state = ST_ADD0;

            ST_ADD0: next_state = ST_ADD1;
            ST_ADD1: next_state = ST_ADD2;
            ST_ADD2: next_state = ST_ADD3;
            ST_ADD3: next_state = ST_ADD4;
            ST_ADD4: next_state = ST_ADD5;
            ST_ADD5: next_state = ST_MUL0_LOAD;

            ST_MUL0_LOAD: next_state = ST_MUL0_SAVE;
            ST_MUL0_SAVE: next_state = ST_MUL1_LOAD;
            ST_MUL1_LOAD: next_state = ST_MUL1_SAVE;
            ST_MUL1_SAVE: next_state = ST_MUL2_LOAD;
            ST_MUL2_LOAD: next_state = ST_MUL2_SAVE;
            ST_MUL2_SAVE: next_state = ST_MUL3_LOAD;
            ST_MUL3_LOAD: next_state = ST_MUL3_SAVE;
            ST_MUL3_SAVE: next_state = ST_MUL4_LOAD;
            ST_MUL4_LOAD: next_state = ST_MUL4_SAVE;
            ST_MUL4_SAVE: next_state = ST_RED0;

            ST_RED0: next_state = ST_RED1;
            ST_RED1: next_state = ST_RED2;
            ST_RED2: next_state = ST_RED3;
            ST_RED3: next_state = ST_RED4;
            ST_RED4: next_state = ST_RED5;
            ST_RED5: next_state = ST_RED6;
            ST_RED6: next_state = ST_RED7;

            ST_RED7: begin
                if (is_final) next_state = ST_FIN_PACK;
                else          next_state = ST_IDLE;
            end

            ST_FIN_PACK: next_state = ST_FIN_RED;
            ST_FIN_RED:  next_state = ST_FIN_ADD;
            ST_FIN_ADD:  next_state = ST_FIN_DONE;
            ST_FIN_DONE: next_state = ST_IDLE;

            default: next_state = ST_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_IDLE;

            h0 <= 32'd0; h1 <= 32'd0; h2 <= 32'd0; h3 <= 32'd0; h4 <= 32'd0;
            r0 <= 27'd0; r1 <= 27'd0; r2 <= 27'd0; r3 <= 27'd0; r4 <= 27'd0;
            s_reg <= 128'd0;

            d0 <= 64'd0; d1 <= 64'd0; d2 <= 64'd0; d3 <= 64'd0; d4 <= 64'd0;

            ma0 <= 27'd0; ma1 <= 27'd0; ma2 <= 27'd0; ma3 <= 27'd0; ma4 <= 27'd0;
            mb0 <= 27'd0; mb1 <= 27'd0; mb2 <= 27'd0; mb3 <= 27'd0; mb4 <= 27'd0;
            sx0 <= 1'b0;  sx1 <= 1'b0;  sx2 <= 1'b0;  sx3 <= 1'b0;  sx4 <= 1'b0;

            h_full_reg <= 131'd0;
            h_red_reg  <= 131'd0;
            tag_sum_reg <= 128'd0;

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

                ST_MUL0_LOAD: begin
                    ma0 <= h0_w; mb0 <= r0; sx0 <= 1'b0;
                    ma1 <= h1_w; mb1 <= r4; sx1 <= 1'b1;
                    ma2 <= h2_w; mb2 <= r3; sx2 <= 1'b1;
                    ma3 <= h3_w; mb3 <= r2; sx3 <= 1'b1;
                    ma4 <= h4_w; mb4 <= r1; sx4 <= 1'b1;
                end

                ST_MUL0_SAVE: d0 <= d_sum_w;

                ST_MUL1_LOAD: begin
                    ma0 <= h0_w; mb0 <= r1; sx0 <= 1'b0;
                    ma1 <= h1_w; mb1 <= r0; sx1 <= 1'b0;
                    ma2 <= h2_w; mb2 <= r4; sx2 <= 1'b1;
                    ma3 <= h3_w; mb3 <= r3; sx3 <= 1'b1;
                    ma4 <= h4_w; mb4 <= r2; sx4 <= 1'b1;
                end

                ST_MUL1_SAVE: d1 <= d_sum_w;

                ST_MUL2_LOAD: begin
                    ma0 <= h0_w; mb0 <= r2; sx0 <= 1'b0;
                    ma1 <= h1_w; mb1 <= r1; sx1 <= 1'b0;
                    ma2 <= h2_w; mb2 <= r0; sx2 <= 1'b0;
                    ma3 <= h3_w; mb3 <= r4; sx3 <= 1'b1;
                    ma4 <= h4_w; mb4 <= r3; sx4 <= 1'b1;
                end

                ST_MUL2_SAVE: d2 <= d_sum_w;

                ST_MUL3_LOAD: begin
                    ma0 <= h0_w; mb0 <= r3; sx0 <= 1'b0;
                    ma1 <= h1_w; mb1 <= r2; sx1 <= 1'b0;
                    ma2 <= h2_w; mb2 <= r1; sx2 <= 1'b0;
                    ma3 <= h3_w; mb3 <= r0; sx3 <= 1'b0;
                    ma4 <= h4_w; mb4 <= r4; sx4 <= 1'b1;
                end

                ST_MUL3_SAVE: d3 <= d_sum_w;

                ST_MUL4_LOAD: begin
                    ma0 <= h0_w; mb0 <= r4; sx0 <= 1'b0;
                    ma1 <= h1_w; mb1 <= r3; sx1 <= 1'b0;
                    ma2 <= h2_w; mb2 <= r2; sx2 <= 1'b0;
                    ma3 <= h3_w; mb3 <= r1; sx3 <= 1'b0;
                    ma4 <= h4_w; mb4 <= r0; sx4 <= 1'b0;
                end

                ST_MUL4_SAVE: d4 <= d_sum_w;

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
                    h0 <= red5_h0_m;
                    h1 <= red5_h1_m;
                    h2 <= red5_h2_a;
                end

                ST_RED6: begin
                    h2 <= red6_h2_m;
                    h3 <= red6_h3_m;
                    h4 <= red6_h4_a;
                end

                ST_RED7: begin
                    h4 <= red7_h4_m;
                    h0 <= red7_h0_m;
                    h1 <= red7_h1_a;
                end

                ST_FIN_PACK: begin
                    h_full_reg <= h_full_w;
                end

                ST_FIN_RED: begin
                    h_red_reg <= h_red_w;
                end

                ST_FIN_ADD: begin
                    tag_sum_reg <= tag_sum_w[127:0];
                end

                ST_FIN_DONE: begin
                    h0 <= 32'd0;
                    h1 <= 32'd0;
                    h2 <= 32'd0;
                    h3 <= 32'd0;
                    h4 <= 32'd0;

                    h_full_reg <= 131'd0;
                    h_red_reg  <= 131'd0;

                    is_first <= 1'b1;
                    is_final <= 1'b0;
                end

                default: ;
            endcase
        end
    end

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

            if (state == ST_FIN_DONE) begin
                mac_tag   <= tag_sum_reg;
                tag_valid <= 1'b1;
            end else if (state == ST_IDLE && valid_in) begin
                tag_valid <= 1'b0;
            end
        end
    end

endmodule