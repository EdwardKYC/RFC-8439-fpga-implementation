`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 300000

// ==========================================
// 根據外部 define 決定要讀取的測試檔案
// 在 VCS 編譯時加入參數： +define+T2 (以此類推)
// ==========================================
`ifdef T1
    `define TEST_FILE "../chacha_test.txt"
`elsif T2
    `define TEST_FILE "../chacha_test2.txt"
`elsif T3
    `define TEST_FILE "../chacha_test3.txt"
`elsif T4
    `define TEST_FILE "../chacha_test4.txt"
`elsif T5
    `define TEST_FILE "../chacha_test5.txt"
`elsif T6
    `define TEST_FILE "../chacha_test6.txt"
`else
    `define TEST_FILE "../chacha_test.txt" // 預設值
`endif

`ifdef syn
    `include "/cad/designkit/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v"
    `include "Chacha20_syn.v"
`endif

module tb_chacha;

    // 定義測資長度 (因為只測一筆，N 其實可以設為 16 就好，但保留原本大小不影響)
    localparam integer N = 16384; 

    reg         clk;
    reg         rst;

    reg         start;
    wire        ready;

    reg [255:0] key;
    reg [95:0]  nonce;
    reg [31:0]  counter;
    wire [511:0] keystream;

    // 內部驗證變數 (儲存黃金答案)
    reg [31:0]  Golden_ANS [0:N-1];
    integer     error;
    integer     w; // 移除了原本的 i，因為不需要外部迴圈了

    // ==========================================
    // 時脈產生
    // ==========================================
    always #(`CYCLE / 2.0) clk = ~clk;

    // ==========================================
    // DUT 實例化
    // ==========================================
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

    // ==========================================
    // 主控制與驗證流程
    // ==========================================
    initial begin
        clk     = 0;
        rst     = 0;
        start   = 0;
        error   = 0;
        
        // 預設 Key 與 Nonce
        key     = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        nonce   = 96'h000000000000000000000000;
        
        // 注意：這裡依據你上傳的 TB 版本是 1
        counter = 32'd0;

        $display("        ********************************************");
        $display("        ** Chacha20 Simulation Start (Single) **");
        $display("        ** Loading Test File: %s", `TEST_FILE);
        $display("        ********************************************\n");

        // 讀取 Golden Keystream Answer
        $readmemh(`TEST_FILE, Golden_ANS);

        // 系統重置
        rst = 1;
        #(5 * `CYCLE);
        rst = 0;

        $display("Starting Single Keystream Generation and Verification...");

        // ==========================================
        // 單次觸發與比對邏輯 (移除了外層 for 迴圈)
        // ==========================================
        #(`CYCLE);
        
        // 1. 發送 Start 訊號
        @(negedge clk); 
        start = 1;
        
        @(negedge clk); 
        start = 0;            
        
        // 2. 等待 ready 訊號為 High
        fork
            begin
                wait(ready === 1'b1);
                @(negedge clk); 
            end
            begin
                #(`CYCLE * 1000); 
                $display("\n[錯誤] Timeout! DUT did not assert 'ready' signal.");
                $finish;
            end
        join_any
        disable fork; 
        
        // 3. 在 ready 為 high 的當下，進行 Keystream 比對 (只比對前 16 個 Words)
        for (w = 0; w < 16; w = w + 1) begin
            // 擷取 keystream 對應的 32-bit (Little-Endian 對齊)
            if (keystream[w*32 +: 32] !== Golden_ANS[w]) begin
                $display("Error at Word [%2d]! Expected: %08x, Got: %08x", 
                          w, Golden_ANS[w], keystream[w*32 +: 32]);
                error = error + 1;
            end
        end
        
        // 4. 等待一個 clock 讓狀態機收尾
        @(posedge clk);

        // ==========================================
        // 結算與報告輸出
        // ==========================================
        $display("\nComputation Done. Verification Finished.");
        if (error === 0) begin
            $display("-------------------------------------------------------------");
            $display(" █████╗ ██╗     ██╗         ██████╗  █████╗ ███████╗███████╗");
            $display("██╔══██╗██║     ██║         ██╔══██╗██╔══██╗██╔════╝██╔════╝");
            $display("███████║██║     ██║         ██████╔╝███████║███████╗███████╗");
            $display("██╔══██║██║     ██║         ██╔═══╝ ██╔══██║╚════██║╚════██║");
            $display("██║  ██║███████╗███████╗    ██║     ██║  ██║███████║███████║");
            $display("╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝");
            $display("-------------------------------------------------------------");
            $display("TB RESULT : PASS (1 Block Verified)"); // 改為 1 Block
        end else begin
            $display("-------------------------------------------------------------");
            $display("        **************************** ");
            $display("        ** ** |\\__||  ");
            $display("        ** OOPS!!                 ** / X,X  | ");
            $display("        ** ** /_____   | ");
            $display("        ** Simulation Failed!!    ** /^ ^ ^ \\  |");
            $display("        ** ** |^ ^ ^ ^ |w| ");
            $display("        **************************** \\m___m__|_|");
            $display("         Totally has %0d errors                     ", error);
            $display("-------------------------------------------------------------");
            $display("TB RESULT : FAIL");
        end

        $finish;
    end

    // ==========================================
    // 系統安全 Timeout (保護機制)
    // ==========================================
    initial begin
        #(`MAX_CYCLE * `CYCLE)
        $display("\n-- Reach Max cycle!!!!!! Simulation terminated.");
        $finish;
    end

    // ==========================================
    // 波形輸出
    // ==========================================
    initial begin
        $fsdbDumpfile("Chacha20.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_chacha);
    end

endmodule