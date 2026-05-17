module Chacha20 (
    input  wire          clk,
    input  wire          rst,
    input  wire          start,      
    output wire          ready,      
    input  wire [255:0]  key,        
    input  wire [95:0]   nonce,      
    input  wire [31:0]   counter,    
    output wire [511:0]  keystream   
);
    integer i, j;
    localparam IDLE         = 3'd0, 
               CALC_COL_H1  = 3'd1, 
               CALC_COL_H2  = 3'd2, 
               CALC_DIAG_H1 = 3'd3, 
               CALC_DIAG_H2 = 3'd4, 
               ADD          = 3'd5, 
               DONE         = 3'd6;
    
    localparam CONSTANT1 = 32'h61707865, CONSTANT2 = 32'h3320646e, CONSTANT3 = 32'h79622d32, CONSTANT4 = 32'h6b206574;

    reg [2:0] state, next_state;
    reg [3:0] round_cnt;
    reg [31:0] init_buf[0:15];
    reg [31:0] keystream_buf[0:15];

    // Pipeline Registers (取代原本龐大的 col_buf)
    reg [31:0] pipe_a [0:3];
    reg [31:0] pipe_b [0:3];
    reg [31:0] pipe_c [0:3];
    reg [31:0] pipe_d [0:3];

    wire [31:0] h1_in_a [0:3], h1_in_b [0:3], h1_in_c [0:3], h1_in_d [0:3];
    wire [31:0] h1_out_a[0:3], h1_out_b[0:3], h1_out_c[0:3], h1_out_d[0:3];
    wire [31:0] h2_out_a[0:3], h2_out_b[0:3], h2_out_c[0:3], h2_out_d[0:3];

    assign keystream = {keystream_buf[15], keystream_buf[14], keystream_buf[13], keystream_buf[12],
                        keystream_buf[11], keystream_buf[10],keystream_buf[9], keystream_buf[8],
                        keystream_buf[7], keystream_buf[6],keystream_buf[5], keystream_buf[4],
                        keystream_buf[3], keystream_buf[2],keystream_buf[1], keystream_buf[0]};

    assign ready = (state == DONE);

    // ==========================================
    // Datapath Routing (MUX 控制)
    // ==========================================
    wire is_col = (state == CALC_COL_H1);

    assign h1_in_a[0] = keystream_buf[0];
    assign h1_in_a[1] = keystream_buf[1];
    assign h1_in_a[2] = keystream_buf[2];
    assign h1_in_a[3] = keystream_buf[3];

    assign h1_in_b[0] = is_col ? keystream_buf[4] : keystream_buf[5];
    assign h1_in_b[1] = is_col ? keystream_buf[5] : keystream_buf[6];
    assign h1_in_b[2] = is_col ? keystream_buf[6] : keystream_buf[7];
    assign h1_in_b[3] = is_col ? keystream_buf[7] : keystream_buf[4];

    assign h1_in_c[0] = is_col ? keystream_buf[8]  : keystream_buf[10];
    assign h1_in_c[1] = is_col ? keystream_buf[9]  : keystream_buf[11];
    assign h1_in_c[2] = is_col ? keystream_buf[10] : keystream_buf[8];
    assign h1_in_c[3] = is_col ? keystream_buf[11] : keystream_buf[9];

    assign h1_in_d[0] = is_col ? keystream_buf[12] : keystream_buf[15];
    assign h1_in_d[1] = is_col ? keystream_buf[13] : keystream_buf[12];
    assign h1_in_d[2] = is_col ? keystream_buf[14] : keystream_buf[13];
    assign h1_in_d[3] = is_col ? keystream_buf[15] : keystream_buf[14];

    // ==========================================
    // Submodule Instantiation (Resource Sharing)
    // ==========================================
    Quarter_round_Half1 H1_0 (.a(h1_in_a[0]), .b(h1_in_b[0]), .c(h1_in_c[0]), .d(h1_in_d[0]), .out_a(h1_out_a[0]), .out_b(h1_out_b[0]), .out_c(h1_out_c[0]), .out_d(h1_out_d[0]));
    Quarter_round_Half1 H1_1 (.a(h1_in_a[1]), .b(h1_in_b[1]), .c(h1_in_c[1]), .d(h1_in_d[1]), .out_a(h1_out_a[1]), .out_b(h1_out_b[1]), .out_c(h1_out_c[1]), .out_d(h1_out_d[1]));
    Quarter_round_Half1 H1_2 (.a(h1_in_a[2]), .b(h1_in_b[2]), .c(h1_in_c[2]), .d(h1_in_d[2]), .out_a(h1_out_a[2]), .out_b(h1_out_b[2]), .out_c(h1_out_c[2]), .out_d(h1_out_d[2]));
    Quarter_round_Half1 H1_3 (.a(h1_in_a[3]), .b(h1_in_b[3]), .c(h1_in_c[3]), .d(h1_in_d[3]), .out_a(h1_out_a[3]), .out_b(h1_out_b[3]), .out_c(h1_out_c[3]), .out_d(h1_out_d[3]));

    Quarter_round_Half2 H2_0 (.a(pipe_a[0]), .b(pipe_b[0]), .c(pipe_c[0]), .d(pipe_d[0]), .out_a(h2_out_a[0]), .out_b(h2_out_b[0]), .out_c(h2_out_c[0]), .out_d(h2_out_d[0]));
    Quarter_round_Half2 H2_1 (.a(pipe_a[1]), .b(pipe_b[1]), .c(pipe_c[1]), .d(pipe_d[1]), .out_a(h2_out_a[1]), .out_b(h2_out_b[1]), .out_c(h2_out_c[1]), .out_d(h2_out_d[1]));
    Quarter_round_Half2 H2_2 (.a(pipe_a[2]), .b(pipe_b[2]), .c(pipe_c[2]), .d(pipe_d[2]), .out_a(h2_out_a[2]), .out_b(h2_out_b[2]), .out_c(h2_out_c[2]), .out_d(h2_out_d[2]));
    Quarter_round_Half2 H2_3 (.a(pipe_a[3]), .b(pipe_b[3]), .c(pipe_c[3]), .d(pipe_d[3]), .out_a(h2_out_a[3]), .out_b(h2_out_b[3]), .out_c(h2_out_c[3]), .out_d(h2_out_d[3]));

    // ==========================================
    // FSM Logic
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        if(rst) next_state = IDLE;
        else begin
            case (state)
                IDLE:         next_state = (start) ? CALC_COL_H1 : IDLE;
                CALC_COL_H1:  next_state = CALC_COL_H2;
                CALC_COL_H2:  next_state = CALC_DIAG_H1;
                CALC_DIAG_H1: next_state = CALC_DIAG_H2;
                CALC_DIAG_H2: next_state = (round_cnt == 4'd9) ? ADD : CALC_COL_H1;
                ADD:          next_state = DONE;
                DONE:         next_state = IDLE;
                default:      next_state = IDLE;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) round_cnt <= 4'd0;
        else if (state == IDLE) round_cnt <= 4'd0;
        else if (state == CALC_DIAG_H2) round_cnt <= round_cnt + 4'd1;
    end

    // ==========================================
    // Sequential Datapath 
    // ==========================================
    integer k;
    always @(posedge clk) begin
         case (state)
            IDLE: begin
                if(start) begin
                    init_buf[0] <= CONSTANT1; init_buf[1] <= CONSTANT2;
                    init_buf[2] <= CONSTANT3; init_buf[3] <= CONSTANT4;
                    keystream_buf[0] <= CONSTANT1; keystream_buf[1] <= CONSTANT2;
                    keystream_buf[2] <= CONSTANT3; keystream_buf[3] <= CONSTANT4;
                    
                    for (i = 0; i < 8; i = i + 1) begin
                        init_buf[4+i] <= {key[231 - i*32 -: 8], key[239 - i*32 -: 8], key[247 - i*32 -: 8], key[255 - i*32 -: 8]};
                        keystream_buf[4+i] <= {key[231 - i*32 -: 8], key[239 - i*32 -: 8], key[247 - i*32 -: 8], key[255 - i*32 -: 8]};
                    end
                    init_buf[12] <= counter; keystream_buf[12] <= counter;
                    for (j = 0; j < 3; j = j + 1) begin
                        init_buf[13+j] <= {nonce[71 - j*32 -: 8], nonce[79 - j*32 -: 8], nonce[87 - j*32 -: 8], nonce[95 - j*32 -: 8]};
                        keystream_buf[13+j] <= {nonce[71 - j*32 -: 8], nonce[79 - j*32 -: 8], nonce[87 - j*32 -: 8], nonce[95 - j*32 -: 8]};
                    end
                end
            end
            
            // Phase 1: 擷取上半部的運算結果進入 Pipeline
            CALC_COL_H1, CALC_DIAG_H1: begin
                for (k = 0; k < 4; k = k + 1) begin
                    pipe_a[k] <= h1_out_a[k]; pipe_b[k] <= h1_out_b[k];
                    pipe_c[k] <= h1_out_c[k]; pipe_d[k] <= h1_out_d[k];
                end
            end

            // Phase 2: 將下半部的運算結果依 Column 的 Index 寫回
            CALC_COL_H2: begin
                keystream_buf[0] <= h2_out_a[0]; keystream_buf[4] <= h2_out_b[0]; keystream_buf[8] <= h2_out_c[0]; keystream_buf[12] <= h2_out_d[0];
                keystream_buf[1] <= h2_out_a[1]; keystream_buf[5] <= h2_out_b[1]; keystream_buf[9] <= h2_out_c[1]; keystream_buf[13] <= h2_out_d[1];
                keystream_buf[2] <= h2_out_a[2]; keystream_buf[6] <= h2_out_b[2]; keystream_buf[10]<= h2_out_c[2]; keystream_buf[14] <= h2_out_d[2];
                keystream_buf[3] <= h2_out_a[3]; keystream_buf[7] <= h2_out_b[3]; keystream_buf[11]<= h2_out_c[3]; keystream_buf[15] <= h2_out_d[3];
            end
            
            // Phase 2: 將下半部的運算結果依 Diagonal 的 Index 寫回
            CALC_DIAG_H2: begin
                keystream_buf[0] <= h2_out_a[0]; keystream_buf[5] <= h2_out_b[0]; keystream_buf[10]<= h2_out_c[0]; keystream_buf[15] <= h2_out_d[0];
                keystream_buf[1] <= h2_out_a[1]; keystream_buf[6] <= h2_out_b[1]; keystream_buf[11]<= h2_out_c[1]; keystream_buf[12] <= h2_out_d[1];
                keystream_buf[2] <= h2_out_a[2]; keystream_buf[7] <= h2_out_b[2]; keystream_buf[8] <= h2_out_c[2]; keystream_buf[13] <= h2_out_d[2];
                keystream_buf[3] <= h2_out_a[3]; keystream_buf[4] <= h2_out_b[3]; keystream_buf[9] <= h2_out_c[3]; keystream_buf[14] <= h2_out_d[3];
            end

            ADD: begin
                for(i = 0; i < 16; i = i+1) keystream_buf[i] <= keystream_buf[i] + init_buf[i];
            end
         endcase
    end
endmodule

module Quarter_round_Half1 (
    input  [31:0] a, b, c, d,
    output [31:0] out_a, out_b, out_c, out_d
);
    wire [31:0] a1, b1, c1, d1;
    wire [31:0] d_xor1, b_xor1;
    
    assign a1 = a + b;
    assign d_xor1 = d ^ a1;
    assign d1 = {d_xor1[15:0], d_xor1[31:16]};
    
    assign c1 = c + d1;
    assign b_xor1 = b ^ c1;
    assign b1 = {b_xor1[19:0], b_xor1[31:20]};
    
    assign out_a = a1;
    assign out_b = b1;
    assign out_c = c1;
    assign out_d = d1;
endmodule

module Quarter_round_Half2 (
    input  [31:0] a, b, c, d,
    output [31:0] out_a, out_b, out_c, out_d
);
    wire [31:0] a2, b2, c2, d2;
    wire [31:0] d_xor2, b_xor2;
    
    assign a2 = a + b;
    assign d_xor2 = d ^ a2;
    assign d2 = {d_xor2[23:0], d_xor2[31:24]};
    
    assign c2 = c + d2;
    assign b_xor2 = b ^ c2;
    assign b2 = {b_xor2[24:0], b_xor2[31:25]};
    
    assign out_a = a2;
    assign out_b = b2;
    assign out_c = c2;
    assign out_d = d2;
endmodule