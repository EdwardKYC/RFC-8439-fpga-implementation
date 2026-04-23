`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 300000

`ifdef syn
    `include "/cad/designkit/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v"
    `include "Chacha20_syn.v"
`endif

module tb_chacha;

    localparam integer W = 256;
    localparam integer H = 256;
    localparam integer N = (W * H) / 4; 

    reg         clk;
    reg         rst;

    reg         start;
    wire        ready;
    reg [255:0] key;
    reg [95:0]  nonce;
    reg [31:0]  counter;
    wire [511:0] keystream;

    wire        Img_cen = 1'b1;
    wire [13:0] Img_addr = 14'd0;
    wire [31:0] Img_Q;

    wire        Ans_cen = 1'b1;
    wire        Ans_wen = 1'b1;
    wire [13:0] Ans_addr = 14'd0;
    wire [31:0] Ans_D = 32'd0;
    wire [31:0] Ans_Q;

    // 內部驗證變數
    reg [31:0]  Golden_ANS [0:N-1];
    integer     error;
    integer     i, w;
    integer     f_out_matrix;

    always #(`CYCLE / 2.0) clk = ~clk;

    Chacha20 dut (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .ready      (ready),
        .key        (key),
        .nonce      (nonce),
        .counter    (counter),
        .keystream  (keystream)
    );

    MEM32 #(.depth(N)) Src_RAM (
        .clk (clk),
        .rst (1'b0),
        .A   (Img_addr),
        .CEN (Img_cen),
        .WEN (1'b1), 
        .D   (32'd0),
        .Q   (Img_Q)
    );

    MEM32 #(.depth(N)) Dst_RAM (
        .clk (clk),
        .rst (rst),
        .A   (Ans_addr),
        .CEN (Ans_cen),
        .WEN (Ans_wen),
        .D   (Ans_D),
        .Q   (Ans_Q)
    );

    task dump_ans_matrix_to_file;
        integer r, c;
        integer word_idx;
        reg [31:0] cur_word;
        begin
            f_out_matrix = $fopen("chacha_matrix.txt", "w");
            if (f_out_matrix == 0) begin
                $display("Failed to open chacha_matrix.txt");
                $finish;
            end

            for (r = 0; r < H; r = r + 1) begin
                for (c = 0; c < W; c = c + 4) begin 
                    word_idx = (r * W + c) / 4;
                    cur_word = Dst_RAM.memory[word_idx];
                    $fwrite(f_out_matrix, "%02x %02x %02x %02x ",
                            cur_word[7:0], cur_word[15:8], cur_word[23:16], cur_word[31:24]);
                end
                $fwrite(f_out_matrix, "\n");
            end

            $fclose(f_out_matrix);
            $display("Matrix dumped to chacha_matrix.txt");
        end
    endtask

    initial begin
        clk     = 0;
        rst     = 0;
        start   = 0;
        error   = 0;
        key     = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        nonce   = 96'h000000000000000000000000;
        counter = 32'd1;

        $display("        ****************************");
        $display("        ** Simulation Start   **");
        $display("        ****************************\n");

        $readmemh("../chacha_test.txt", Src_RAM.memory);
        $readmemh("../chacha_answer.txt", Golden_ANS);

        rst = 1;
        #(5 * `CYCLE);
        rst = 0;

        $display("Starting Encryption Process...");

        for (i = 0; i < N; i = i + 16) begin
            start = 1;
            @(posedge clk);
            start = 0;            
            
            @(posedge clk);

            for (w = 0; w < 16; w = w + 1) begin
                if (i + w < N) begin
                    Dst_RAM.memory[i + w] = Src_RAM.memory[i + w] ^ keystream[w*32 +: 32];
                end
            end
            
            counter = counter + 1;
        end

        $display("Computation Done. Starting Verification...");

        for (i = 0; i < N; i = i + 1) begin
            if (Dst_RAM.memory[i] !== Golden_ANS[i]) begin
                $display("Error at Word [%5d]! Expected: %08x, Got: %08x", i, Golden_ANS[i], Dst_RAM.memory[i]);
                error = error + 1;
                if (error > 20) begin
                    $display("Too many errors, aborting verification...");
                    break;
                end
            end
        end

        if (error === 0) begin
            $display("-------------------------------------------------------------");
            $display("TB RESULT : PASS");
            dump_ans_matrix_to_file();
        end else begin
            $display("-------------------------------------------------------------");
            $display("Totally has %0d errors", error);
            $display("TB RESULT : FAIL");
        end

        $finish;
    end

    initial begin
        #(`MAX_CYCLE * `CYCLE)
        $display("-- Reach Max cycle!!!!!! Simulation terminated.");
        $finish;
    end

    initial begin
        $fsdbDumpfile("Chacha20.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_chacha);
    end

endmodule

module MEM32 #(parameter integer depth=65536) (
  input  wire                         clk,
  input  wire                         rst,
  input  wire [$clog2(depth)-1:0]     A,
  input  wire                         CEN,
  input  wire                         WEN,
  input  wire [31:0]                  D,
  output reg  [31:0]                  Q
);
  reg [$clog2(depth)-1:0] latched_A;
  reg [$clog2(depth)-1:0] latched_A_neg;
  reg [31:0] memory [0:depth-1];
  integer j;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (j = 0; j < depth; j = j + 1)
        memory[j] <= 32'd0;
    end
    else begin
      if (~WEN && ~CEN) memory[A] <= D;
      if (~CEN) latched_A <= A;
    end
  end

  always @(negedge clk) begin
    if (~CEN) latched_A_neg <= latched_A;
  end

  always @(*) begin
    if (~CEN) Q = memory[latched_A_neg];
    else Q = 32'hzzzz_zzzz;
  end
endmodule