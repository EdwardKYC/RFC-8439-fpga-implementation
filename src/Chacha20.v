`include "Quarter_round.v"

module Chacha20 (
    input  wire          clk,
    input  wire          rst,
    input  wire          start,      
    output reg           ready,      // 告訴 FSM：512-bit finish
    input  wire [255:0]  key,        
    input  wire [95:0]   nonce,      
    input  wire [31:0]   counter,    // 0: 生產 MAC Key, 1+: 生產加密密鑰流
    output wire [511:0]  keystream   
);
    integer i;
    localparam IDLE = 2'd0, CALC = 2'd1, ADD = 2'd2, DONE = 2'd3;
    localparam CONSTANT1 = 32'h61707865, CONSTANT2 = 32'h3320646e, CONSTANT3 = 32'h79622d32, CONSTANT4 = 32'h6b206574;

    reg [1:0] state, next_state;
    reg [3:0] round_cnt;
    reg [31:0] init_buf[15:0];
    reg [31:0] keystream_buf[15:0];

    wire [31:0] col_out[15:0];
    wire [31:0] diagonal_out[15:0];

    assign keystream = {keystream_buf[15], keystream_buf[14], keystream_buf[13], keystream_buf[12],
                        keystream_buf[11], keystream_buf[10],keystream_buf[9], keystream_buf[8],
                        keystream_buf[7], keystream_buf[6],keystream_buf[5], keystream_buf[4],
                        keystream_buf[3], keystream_buf[2],keystream_buf[1], keystream_buf[0]};

    assign ready = (state == DONE);

    Quarter_round Col1(.a(keystream_buf[0]), .b(keystream_buf[4]), .c(keystream_buf[8]),
                       .d(keystream_buf[12]), .out_a(col_out[0]), .out_b(col_out[4]),
                       .out_c(col_out[8]), .out_d(col_out[12]));
    Quarter_round Col2(.a(keystream_buf[1]), .b(keystream_buf[5]), .c(keystream_buf[9]),
                       .d(keystream_buf[13]), .out_a(col_out[1]), .out_b(col_out[5]),
                       .out_c(col_out[9]), .out_d(col_out[13]));
    Quarter_round Col3(.a(keystream_buf[2]), .b(keystream_buf[6]), .c(keystream_buf[10]),
                       .d(keystream_buf[14]), .out_a(col_out[2]), .out_b(col_out[6]),
                       .out_c(col_out[10]), .out_d(col_out[14]));
    Quarter_round Col4(.a(keystream_buf[3]), .b(keystream_buf[7]), .c(keystream_buf[11]),
                       .d(keystream_buf[15]), .out_a(col_out[3]), .out_b(col_out[7]),
                       .out_c(col_out[11]), .out_d(col_out[15]));

    Quarter_round Diag1(.a(col_out[0]), .b(col_out[5]), .c(col_out[10]),
                       .d(col_out[15]), .out_a(diagonal_out[0]), .out_b(diagonal_out[5]),
                       .out_c(diagonal_out[10]), .out_d(diagonal_out[15]));
    Quarter_round Diag2(.a(col_out[1]), .b(col_out[6]), .c(col_out[11]),
                       .d(col_out[12]), .out_a(diagonal_out[1]), .out_b(diagonal_out[6]),
                       .out_c(diagonal_out[11]), .out_d(diagonal_out[12]));
    Quarter_round Diag3(.a(col_out[2]), .b(col_out[7]), .c(col_out[8]),
                       .d(col_out[13]), .out_a(diagonal_out[2]), .out_b(diagonal_out[7]),
                       .out_c(diagonal_out[8]), .out_d(diagonal_out[13]));
    Quarter_round Diag4(.a(col_out[3]), .b(col_out[4]), .c(col_out[9]),
                       .d(col_out[14]), .out_a(diagonal_out[3]), .out_b(diagonal_out[4]),
                       .out_c(diagonal_out[9]), .out_d(diagonal_out[14]));
    
                    

    always @(posedge clk or posedge rst) begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        if(rst) next_state = IDLE;
        else begin
            case (state)
                IDLE: next_state = (start) ? CALC : IDLE;
                CALC: next_state = (round_cnt == 4'd9) ? ADD : CALC; 
                ADD: next_state = DONE;
                DONE: next_state = IDLE;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) round_cnt <= 4'd0;
        else round_cnt <= (state == CALC) ? round_cnt + 4'd1 : 4'd0;
    end

    always @(posedge clk or posedge rst) begin
         case (state)
            IDLE: begin
                if(start) begin
                    init_buf[0] <= CONSTANT1;
                    init_buf[1] <= CONSTANT2;
                    init_buf[2] <= CONSTANT3;
                    init_buf[3] <= CONSTANT4;
                    keystream_buf[0] <= CONSTANT1;
                    keystream_buf[1] <= CONSTANT2;
                    keystream_buf[2] <= CONSTANT3;
                    keystream_buf[3] <= CONSTANT4;
                    for (i = 0; i < 8; i = i+1) begin
                        init_buf[4+i] <= key[i*32 +:32];
                        keystream_buf[4+i] <= key[i*32 +: 32];
                    end
                    init_buf[12] <= counter;
                    init_buf[13] <= nonce[31:0];
                    init_buf[14] <= nonce[63:32];
                    init_buf[15] <= nonce[95:64];
                    keystream_buf[12] <= counter;
                    keystream_buf[13] <= nonce[31:0];
                    keystream_buf[14] <= nonce[63:32];
                    keystream_buf[15] <= nonce[95:64];
                end
            end
            CALC: begin
                for(i = 0; i < 16; i = i+1) keystream_buf[i] <= diagonal_out[i];
            end
            ADD: begin
                for(i = 0; i < 16; i = i+1) keystream_buf[i] <= keystream_buf[i] + init_buf[i];
            end
         endcase
    end
endmodule
