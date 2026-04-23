`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 300000

`ifdef syn
    `include "/cad/designkit/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v"
    `include "chacha20_syn.v"
`else
    `include "chacha20.v"
`endif

module tb_chacha;

    // 定義影像參數 (以 32-bit word 計算)
    localparam integer W = 256;
    localparam integer H = 256;
    localparam integer N = (W * H) / 4; // 16384 words

    reg         clk;
    reg         rst;
    reg         en;
    wire        done;

    // Src_RAM (Image ROM) 介面
    wire        Img_cen;
    wire [13:0] Img_addr; // $clog2(16384) = 14
    wire [31:0] Img_Q;

    // Dst_RAM (Ans SRAM) 介面
    wire        Ans_cen;
    wire        Ans_wen;
    wire [13:0] Ans_addr;
    wire [31:0] Ans_D;
    wire [31:0] Ans_Q;

    // 儲存 Golden Answer 的陣列
    reg [31:0]  Golden_ANS [0:N-1];
    integer     error;
    integer     i;

    // ==========================================
    // 時脈產生
    // ==========================================
    always #(`CYCLE / 2.0) clk = ~clk;

    // ==========================================
    // DUT 實例化
    // ==========================================
    chacha20 dut (
        .clk        (clk),
        .rst        (rst),
        .en         (en),
        .done       (done),
        
        .Img_cen    (Img_cen),
        .Img_addr   (Img_addr),
        .Img_Q      (Img_Q),
        
        .Ans_cen    (Ans_cen),
        .Ans_wen    (Ans_wen),
        .Ans_addr   (Ans_addr),
        .Ans_D      (Ans_D),
        .Ans_Q      (Ans_Q)
    );

    // ==========================================
    // MEM32 模組實例化
    // ==========================================
    // 來源記憶體 (唯讀模式: WEN 綁定為高電位 1'b1)
    MEM32 #(.depth(N)) Src_RAM (
        .clk (clk),
        .rst (1'b0),
        .A   (Img_addr),
        .CEN (Img_cen),
        .WEN (1'b1), 
        .D   (32'd0),
        .Q   (Img_Q)
    );

    // 目的記憶體 (可讀可寫)
    MEM32 #(.depth(N)) Dst_RAM (
        .clk (clk),
        .rst (rst),
        .A   (Ans_addr),
        .CEN (Ans_cen),
        .WEN (Ans_wen),
        .D   (Ans_D),
        .Q   (Ans_Q)
    );

    // ==========================================
    // 主測試流程
    // ==========================================
    initial begin
        clk   = 0;
        rst   = 0;
        en    = 0;
        error = 0;

        $display("        ****************************");
        $display("        ** Simulation Start   **");
        $display("        ****************************\n");

        // 載入測試資料
        $readmemh("chacha_test.txt", Src_RAM.memory);
        $readmemh("chacha_answer.txt", Golden_ANS);

        // Reset 程序
        rst = 1;
        #(5 * `CYCLE);
        rst = 0;

        // 啟動硬體
        en = 1;
        @(posedge clk);
        en = 0;

        // 等待運算完成
        wait(done);
        @(posedge clk);

        $display("Computation Done. Starting Verification...");

        // 比對結果
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

        // 顯示測試結果
        if (error === 0) begin
            $display("-------------------------------------------------------------");
            $display(" █████╗ ██╗     ██╗         ██████╗  █████╗ ███████╗███████╗");
            $display("██╔══██╗██║     ██║         ██╔══██╗██╔══██╗██╔════╝██╔════╝");
            $display("███████║██║     ██║         ██████╔╝███████║███████╗███████╗");
            $display("██╔══██║██║     ██║         ██╔═══╝ ██╔══██║╚════██║╚════██║");
            $display("██║  ██║███████╗███████╗    ██║     ██║  ██║███████║███████║");
            $display("╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝");
            $display("-------------------------------------------------------------");
            $display("TB RESULT : PASS");
        end else begin
            $display("-------------------------------------------------------------");
            $display("\n");
            $display("        ****************************               ");
            $display("        **                        **       |\\__||  ");
            $display("        **  OOPS!!                **      / X,X  | ");
            $display("        **                        **    /_____   | ");
            $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
            $display("        **                        **  |^ ^ ^ ^ |w| ");
            $display("        ****************************   \\m___m__|_|");
            $display("         Totally has %0d errors                     ", err);
            $display("\n");
            $display("-------------------------------------------------------------");
            $display("TB RESULT : FAIL");
        end

        $finish;
    end

    // ==========================================
    // Timeout 保護機制
    // ==========================================
    initial begin
        #(`MAX_CYCLE * `CYCLE)
        $display("-------------------------------------------------------------");
        $display("-- Reach Max cycle!!!!!!");
        $display("-- Please raise DONE signal after completion");
        $display("-- Simulation terminated");
        $display("-------------------------------------------------------------");
        $finish;
    end

    // ==========================================
    // 產生 FSDB 波形檔與 SDF 標註
    // ==========================================
    initial begin
        $fsdbDumpfile("Chacha20.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_chacha);
    end

    `ifdef syn
    initial begin
        $sdf_annotate("Chacha20_syn.sdf", dut);
    end
    `endif

endmodule

// ==========================================
// 提供的 MEM32 模組 (維持原樣)
// ==========================================
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
      if (~WEN && ~CEN)
        memory[A] <= D;
      if (~CEN)
        latched_A <= A;
    end
  end

  always @(negedge clk) begin
    if (~CEN)
      latched_A_neg <= latched_A;
  end

  always @(*) begin
    if (~CEN)
      Q = memory[latched_A_neg];
    else
      Q = 32'hzzzz_zzzz;
  end
endmodule