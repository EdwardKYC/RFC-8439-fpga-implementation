`timescale 1ns / 1ps

module Cycle_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        start, // 接收來自 GPIO 的 start 訊號
    input  wire        done,  // 接收來自 RFC8439 的 done 訊號
    output reg  [31:0] count  // 輸出給另一個 GPIO 讀取
);

    reg is_running;
    reg start_d;
    wire start_pulse;

    // 邊緣觸發偵測 (與 RFC8439 的啟動邏輯完全同步)
    assign start_pulse = start & ~start_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_d <= 1'b0;
        end else begin
            start_d <= start;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count      <= 32'd0;
            is_running <= 1'b0;
        end else begin
            // 收到 start 脈衝，歸零並開始計時
            if (start_pulse) begin
                count      <= 32'd0;
                is_running <= 1'b1;
            end 
            // 收到 RFC8439 的 done 訊號，停止計時
            else if (done) begin
                is_running <= 1'b0;
            end 
            // 正在運行中，每個 clock cycle 加 1
            else if (is_running) begin
                count <= count + 32'd1;
            end
        end
    end

endmodule