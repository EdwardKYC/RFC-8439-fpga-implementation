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

    // 定義測資長度 (依據 65536 bits = 2048 bytes = 16384 個 32-bit words)
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
    integer     i, w;

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
        
        // 預設 Key 與 Nonce (依據前次 Python 腳本設定)
        key     = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        nonce   = 96'h000000000000000000000000;
        
        // 根據需求，測試資料可能從 counter 0 開始 (生成 Poly1305 key)
        counter = 32'd0;

        $display("        ********************************************");
        $display("        ** Chacha20 Simulation Start      **");
        $display("        ** Loading Test File: %s", `TEST_FILE);
        $display("        ********************************************\n");

        // 讀取 Golden Keystream Answer
        $readmemh(`TEST_FILE, Golden_ANS);

        // 系統重置
        rst = 1;
        #(5 * `CYCLE);
        rst = 0;

        $display("Starting Keystream Generation and Verification...");

        // 每次處理 16 個 Word (512 bits = 1 Block)
        for (i = 0; i < N; i = i + 16) begin
            // 1. 發送 Start 訊號
            start = 1;
            @(posedge clk);
            start = 0;            
            
            // 2. 等待 ready 訊號為 High (加入 Timeout 防呆機制避免無限卡死)
            fork
                begin
                    // 持續等待直到 ready 拉高
                    wait(ready === 1'b1);
                end
                begin
                    #(`CYCLE * 1000); // 如果等了 1000 個 cycle 還沒 ready 就切斷
                    $display("\n[錯誤] Timeout! DUT did not assert 'ready' signal for Block %0d", i/16);
                    $finish;
                end
            join_any
            disable fork; // 觸發後關閉未執行的分支
            
            // 3. 在 ready 為 high 的當下，進行 Keystream 比對
            for (w = 0; w < 16; w = w + 1) begin
                if (i + w < N) begin
                    // 擷取 keystream 對應的 32-bit (Little-Endian 對齊)
                    if (keystream[w*32 +: 32] !== Golden_ANS[i + w]) begin
                        $display("Error at Block [%4d] Word [%2d] (Total Word %5d)! Expected: %08x, Got: %08x", 
                                  i/16, w, i+w, Golden_ANS[i+w], keystream[w*32 +: 32]);
                        error = error + 1;
                        if (error > 20) begin
                            $display("Too many errors, aborting verification...");
                            break;
                        end
                    end
                end
            end
            
            // 如果錯誤過多，直接跳出外部迴圈
            if (error > 20) break;
            
            // 4. 等待一個 clock 讓 ready 降下，並推進 Counter 進入下一個 Block
            @(posedge clk);
            counter = counter + 1;
        end

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
            $display("TB RESULT : PASS (%0d Blocks Verified)", N/16);
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