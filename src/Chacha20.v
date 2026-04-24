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
    
    localparam IDLE = 2'd0, CALC = 2'd1, ADD = 2'd2, DONE = 2'd3;

    reg [2:0] state, next_state;
    reg [3:0] round_cnt;
    reg [255:0] key_buf;
    reg [95:0] nonce_buf;
    reg [31:0] counter_buf;
    reg [511:0] keystream_buf;
    

    assign keystream = key_buf;

    always @(posedge clk or posedge rst) begin
        if(rst) start <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        if(rst) next_state = IDLE;
        else begin
            case (state)
                IDLE: next_state = (start) ? CALC : IDLE;
                CALC: next_state = (round_cnt == 4'd10) ? ADD : CALC; 
                ADD: next_state = DONE;
                DONE: next_state = IDLE;
            endcase
        end
    end


endmodule
