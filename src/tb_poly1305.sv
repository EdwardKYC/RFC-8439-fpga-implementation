`timescale 1ns/1ps

`define CYCLE 10.0
// 因為有 20 萬個 Blocks，每個 Block 至少需要 1~2 個 Cycle
// 把最大 Cycle 數拉高到 500 萬，避免 Timeout
`define MAX_CYCLE 5000000 

module tb_poly;

    // ==========================================
    // 參數定義區
    // ==========================================
    parameter TEST_CASE_COUNT = 100;     // 與 Python 產生的數量一致
    // 總行數 = 200835 個 Blocks + (100 個 Test Case * 3 行標頭) = 201135 行
    // 為了安全起見，我們宣告 250000 行
    parameter MAX_TEST_LINES  = 250000;  
    parameter MAX_ANS_LINES   = 100;     

    // ==========================================
    // 訊號宣告區
    // ==========================================
    reg          clk;
    reg          rst;
    
    // DUT Inputs
    reg          valid_in;
    reg  [255:0] mac_key;
    reg  [127:0] data_in;
    reg          pad_bit;
    reg          finalize;

    // DUT Outputs
    wire         ready_out;
    wire [127:0] mac_tag;
    wire         tag_valid;

    // 讀檔記憶體
    reg [127:0] test_mem [0:MAX_TEST_LINES-1];
    reg [127:0] ans_mem  [0:MAX_ANS_LINES-1];

    // 內部控制變數
    integer ptr;         
    integer tc, b;       
    integer msg_len;     
    integer num_blocks;  
    integer total_error; 

    // ==========================================
    // Clock 生成
    // ==========================================
    always #(`CYCLE / 2.0) clk = ~clk;

    // ==========================================
    // 實例化 DUT (Poly1305 模組)
    // ==========================================
    Poly1305 dut (
        .clk        (clk),
        .rst        (rst),
        .valid_in   (valid_in),
        .ready_out  (ready_out),
        .mac_key    (mac_key),
        .data_in    (data_in),
        .pad_bit    (pad_bit),
        .finalize   (finalize),
        .mac_tag    (mac_tag),
        .tag_valid  (tag_valid)
    );

    // ==========================================
    // 主控制流程 (自動化驗證 FSM)
    // ==========================================
    initial begin
        // 1. 初始狀態設定
        clk         = 0;
        rst         = 0;
        valid_in    = 0;
        pad_bit     = 0;
        finalize    = 0;
        data_in     = 128'd0;
        mac_key     = 256'd0;
        total_error = 0;
        ptr         = 0;

        $display("\n=======================================================");
        $display("==  Poly1305 Mass-Testbench (100 Cases)              ==");
        $display("=======================================================\n");

        // 2. 讀取測資 (請確保檔名與路徑正確)
        // 由於資料量龐大，讀取時會稍微花一點時間
        $readmemh("../poly_test.txt", test_mem);
        $readmemh("../poly_answer.txt", ans_mem);
        $display("[INFO] Text files loaded into memory.\n");
        
        // 3. Reset 流程
        rst = 1;
        #(5 * `CYCLE);
        rst = 0;
        #(2 * `CYCLE);

        // 4. 開始連續測試
        for (tc = 0; tc < TEST_CASE_COUNT; tc = tc + 1) begin
            $display("-------------------------------------------------------");
            $display(">> Starting Test Case %0d...", tc + 1);

            // [讀取 Key]
            mac_key[127:0]   = test_mem[ptr];       // Key: r
            mac_key[255:128] = test_mem[ptr + 1];   // Key: s
            ptr = ptr + 2;

            // [讀取訊息長度]
            msg_len = test_mem[ptr];
            ptr = ptr + 1;

            // 計算需要的 16-byte Block 數量
            if (msg_len == 0) 
                num_blocks = 0;
            else 
                num_blocks = (msg_len + 15) / 16;
            
            $display("   Message Length: %0d Bytes, Total Blocks: %0d", msg_len, num_blocks);

            // [連續餵入 Data Blocks]
            for (b = 0; b < num_blocks; b = b + 1) begin
                
                // 等待引擎 ready_out 拉高，確保可以收資料
                wait(ready_out == 1'b1);
                @(negedge clk); 
                
                data_in  = test_mem[ptr]; 
                valid_in = 1'b1;
                pad_bit  = 1'b1; // RFC 8439 規定每個 block 後面都要補 0x01
                
                // 若為最後一塊，觸發 finalize
                if (b == num_blocks - 1) begin
                    finalize = 1'b1;
                end else begin
                    finalize = 1'b0;
                end
                
                // 維持 1 Cycle 後撤銷訊號
                @(negedge clk);
                valid_in = 1'b0;
                pad_bit  = 1'b0;
                finalize = 1'b0;
                data_in  = 128'd0;
                
                ptr = ptr + 1; 
            end

            // [等待引擎運算並給出最終 Tag]
            wait(tag_valid == 1'b1);
            @(negedge clk);

            // [核對正確性]
            if (mac_tag !== ans_mem[tc]) begin
                $display("   [FAIL] Tag Mismatch!");
                $display("          Expected : %032x", ans_mem[tc]);
                $display("          Got      : %032x", mac_tag);
                total_error = total_error + 1;
            end else begin
                $display("   [PASS] Tag Verified Successfully.");
            end
            
            // 每個 Test Case 之間等待幾拍，讓引擎徹底回到 Idle 狀態
            #(10 * `CYCLE);
        end

        // 5. 輸出總結
        $display("=======================================================");
        if (total_error == 0) begin
            $display("==  ALL TESTS PASSED! YOU NAILED IT!                 ==");
        end else begin
            $display("==  TEST FAILED with %0d errors.                        ==", total_error);
        end
        $display("=======================================================\n");

        $finish;
    end

    // ==========================================
    // Timeout 保護機制
    // ==========================================
    initial begin
        #(`MAX_CYCLE * `CYCLE);
        $display("!! REACHED MAX CYCLE !! Simulation Timeout.");
        $finish;
    end

    // ==========================================
    // 波形輸出 (FSDB) - 預設關閉以防硬碟爆滿
    // ==========================================
    `ifdef syn
        // 合成後 Netlist 的波形設定放這裡
    `else
        // 若要觀看波形除錯，請將底下四行取消註解
        // initial begin
        //     $fsdbDumpfile("Poly1305.fsdb");
        //     $fsdbDumpvars();
        //     $fsdbDumpvars("+struct", "+mda", tb_poly);
        // end
    `endif

endmodule