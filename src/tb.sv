`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 100000

module tb_rfc8439;

    // ==========================================
    // 訊號宣告區
    // ==========================================
    reg         clk;
    reg         rst;

    reg         start;
    reg         mode_decrypt;
    wire        done;
    wire        mac_error;

    reg  [31:0] msg_length;
    reg  [31:0] ad_length;

    reg  [3:0]  config_addr;
    reg  [31:0] config_data;
    reg         config_we;

    // Source RAM Interface
    wire [31:0] Src_RAM_addr;
    wire        Src_RAM_en;
    wire        Src_RAM_we;
    wire [31:0] Src_RAM_D;
    reg  [31:0] Src_RAM_Q;

    // Destination RAM Interface
    wire [31:0] Dst_RAM_addr;
    wire        Dst_RAM_en;
    wire        Dst_RAM_we;
    wire [31:0] Dst_RAM_D;
    reg  [31:0] Dst_RAM_Q;

    // 模擬用的記憶體陣列 (256 Words)
    reg  [31:0] src_mem [0:255];
    reg  [31:0] dst_mem [0:255];

    // 驗證用的黃金標準 (Golden Data)
    reg  [31:0] golden_pt  [0:28];
    reg  [31:0] golden_ct  [0:28];
    reg  [31:0] golden_tag [0:3];

    integer i, error;
    integer mem_idx;

    // ==========================================
    // Clock 生成
    // ==========================================
    always #(`CYCLE / 2.0) clk = ~clk;

    // ==========================================
    // SRAM 行為模型 (Behavioral Model)
    // ==========================================
    always @(posedge clk) begin
        if (Src_RAM_en) begin
            if (Src_RAM_we) begin
                src_mem[Src_RAM_addr] <= Src_RAM_D;
            end
            Src_RAM_Q <= src_mem[Src_RAM_addr]; 
        end
    end

    always @(posedge clk) begin
        if (Dst_RAM_en) begin
            if (Dst_RAM_we) begin
                dst_mem[Dst_RAM_addr] <= Dst_RAM_D;
            end
            Dst_RAM_Q <= dst_mem[Dst_RAM_addr];
        end
    end

    // ==========================================
    // 實例化 DUT
    // ==========================================
    RFC8439 #(
        .ADDR_MODE_WORD(1)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .mode_decrypt   (mode_decrypt),
        .done           (done),
        .mac_error      (mac_error),
        .msg_length     (msg_length),
        .ad_length      (ad_length),
        .config_addr    (config_addr),
        .config_data    (config_data),
        .config_we      (config_we),
        .Src_RAM_addr   (Src_RAM_addr),
        .Src_RAM_en     (Src_RAM_en),
        .Src_RAM_we     (Src_RAM_we),
        .Src_RAM_D      (Src_RAM_D),
        .Src_RAM_Q      (Src_RAM_Q),
        .Dst_RAM_addr   (Dst_RAM_addr),
        .Dst_RAM_en     (Dst_RAM_en),
        .Dst_RAM_we     (Dst_RAM_we),
        .Dst_RAM_D      (Dst_RAM_D),
        .Dst_RAM_Q      (Dst_RAM_Q)
    );

    // ==========================================
    // Helper Tasks
    // ==========================================
    task write_config(input [3:0] addr, input [31:0] data);
    begin
        @(negedge clk);
        config_we   = 1'b1;
        config_addr = addr;
        config_data = data;
        @(negedge clk);
        config_we   = 1'b0;
    end
    endtask

    // 神器：以 Byte 為單位的寫入輔助函數 (對付非對齊的 Corner Cases 必備)
    task write_src_byte(input integer byte_addr, input [7:0] data);
        integer word_addr;
        integer byte_offset;
    begin
        word_addr = byte_addr / 4;
        byte_offset = byte_addr % 4;
        case (byte_offset)
            0: src_mem[word_addr][7:0]   = data;
            1: src_mem[word_addr][15:8]  = data;
            2: src_mem[word_addr][23:16] = data;
            3: src_mem[word_addr][31:24] = data;
        endcase
    end
    endtask

    // ==========================================
    // 主控制流程
    // ==========================================
    initial begin
        // 0. 初始化
        clk          = 0;
        rst          = 0;
        start        = 0;
        mode_decrypt = 0;
        msg_length   = 0;
        ad_length    = 0;
        config_we    = 0;
        config_addr  = 0;
        config_data  = 0;
        error        = 0;

        for (i = 0; i < 256; i = i + 1) begin
            src_mem[i] = 32'd0;
            dst_mem[i] = 32'd0;
        end

        // 載入外部測資
        $readmemh("../rfc8439_ct.txt", golden_ct);
        $readmemh("../rfc8439_tag.txt", golden_tag);

        // 建立 Golden Plaintext (114 Bytes) 用於解密驗證
        golden_pt[0]  = 32'h6964614c; golden_pt[1]  = 32'h61207365; golden_pt[2]  = 32'h4720646e; golden_pt[3]  = 32'h6c746e65;
        golden_pt[4]  = 32'h6e656d65; golden_pt[5]  = 32'h20666f20; golden_pt[6]  = 32'h20656874; golden_pt[7]  = 32'h73616c63;
        golden_pt[8]  = 32'h666f2073; golden_pt[9]  = 32'h39392720; golden_pt[10] = 32'h6649203a; golden_pt[11] = 32'h63204920;
        golden_pt[12] = 32'h646c756f; golden_pt[13] = 32'h66666f20; golden_pt[14] = 32'h79207265; golden_pt[15] = 32'h6f20756f;
        golden_pt[16] = 32'h20796c6e; golden_pt[17] = 32'h20656e6f; golden_pt[18] = 32'h20706974; golden_pt[19] = 32'h20726f66;
        golden_pt[20] = 32'h20656874; golden_pt[21] = 32'h75747566; golden_pt[22] = 32'h202c6572; golden_pt[23] = 32'h736e7573;
        golden_pt[24] = 32'h65657263; golden_pt[25] = 32'h6f77206e; golden_pt[26] = 32'h20646c75; golden_pt[27] = 32'h69206562;
        golden_pt[28] = 32'h00002e74;

        $display("\n=======================================================");
        $display("==  RFC 8439 Advanced Corner Case Simulation         ==");
        $display("=======================================================\n");

        rst = 1;
        #(5 * `CYCLE);
        @(negedge clk);
        rst = 0;
        #(2 * `CYCLE);

        // 寫入 Key & Nonce (貫穿所有 Test Case)
        write_config(4'd0, 32'h83828180); write_config(4'd1, 32'h87868584);
        write_config(4'd2, 32'h8b8a8988); write_config(4'd3, 32'h8f8e8d8c);
        write_config(4'd4, 32'h93929190); write_config(4'd5, 32'h97969594);
        write_config(4'd6, 32'h9b9a9998); write_config(4'd7, 32'h9f9e9d9c);
        write_config(4'd8, 32'h00000007); write_config(4'd9, 32'h43424140); write_config(4'd10, 32'h47464544);


        // =======================================================
        // [TC1] Standard Encryption
        // =======================================================
        $display("\n---> [TC1] Starting Standard Encryption Mode ...");
        // 準備 Src_RAM
        src_mem[0] = 32'h53525150; src_mem[1] = 32'hc3c2c1c0; src_mem[2] = 32'hc7c6c5c4; // AAD
        for(i=0; i<29; i++) src_mem[3+i] = golden_pt[i]; // PT

        msg_length   = 32'd114;
        ad_length    = 32'd12;
        mode_decrypt = 1'b0;
        
        @(negedge clk); start = 1'b1;
        @(negedge clk); start = 1'b0;

        wait(done == 1'b1);
        @(negedge clk);

        // 驗證 TC1 (CT & Tag)
        for (i = 0; i < msg_length; i = i + 1) begin
            logic [7:0] exp_b, got_b;
            exp_b = golden_ct[i/4] >> ((i%4)*8);
            got_b = dst_mem[i/4]   >> ((i%4)*8);
            if (exp_b !== got_b) begin
                $display("  [TC1 FAIL] CT Byte %0d Mismatch! Exp: %02x, Got: %02x", i, exp_b, got_b);
                error++;
            end
        end
        for (i = 0; i < 16; i = i + 1) begin
            logic [7:0] exp_b, got_b;
            mem_idx = msg_length + i;
            exp_b = golden_tag[i/4] >> ((i%4)*8);
            got_b = dst_mem[mem_idx/4] >> ((mem_idx%4)*8);
            if (exp_b !== got_b) begin
                $display("  [TC1 FAIL] Tag Byte %0d Mismatch! Exp: %02x, Got: %02x", mem_idx, exp_b, got_b);
                error++;
            end
        end
        if (error == 0) $display("  [TC1 PASS] Encryption Output Verified!");


        // =======================================================
        // [TC2] Standard Decryption
        // =======================================================
        $display("\n---> [TC2] Starting Standard Decryption Mode ...");
        // 清空 Dst_RAM 以防作弊
        for (i = 0; i < 256; i++) dst_mem[i] = 32'd0;
        
        // 準備 Src_RAM (AAD 已經在前面 12 bytes)
        // 寫入 CT (Offset = 12)
        for(i=0; i<114; i++) write_src_byte(12 + i, (golden_ct[i/4] >> ((i%4)*8)) & 8'hFF);
        // 寫入 Tag (Offset = 12 + 114 = 126)
        for(i=0; i<16; i++) write_src_byte(126 + i, (golden_tag[i/4] >> ((i%4)*8)) & 8'hFF);

        msg_length   = 32'd114;
        ad_length    = 32'd12;
        mode_decrypt = 1'b1; // 解密模式
        
        @(negedge clk); start = 1'b1;
        @(negedge clk); start = 1'b0;

        wait(done == 1'b1);
        @(negedge clk);

        // 驗證 TC2 (MAC Error & PT)
        if (mac_error !== 1'b0) begin
            $display("  [TC2 FAIL] mac_error asserted on valid Tag!");
            error++;
        end else begin
            $display("  [TC2 PASS] mac_error is 0 (Correct).");
        end

        for (i = 0; i < msg_length; i = i + 1) begin
            logic [7:0] exp_b, got_b;
            exp_b = golden_pt[i/4] >> ((i%4)*8);
            got_b = dst_mem[i/4]   >> ((i%4)*8);
            if (exp_b !== got_b) begin
                $display("  [TC2 FAIL] Decrypted PT Byte %0d Mismatch! Exp: %02x, Got: %02x", i, exp_b, got_b);
                error++;
            end
        end
        if (error == 0) $display("  [TC2 PASS] Decryption Output Verified!");


        // =======================================================
        // [TC3] MAC Error (Corrupted Tag)
        // =======================================================
        $display("\n---> [TC3] Testing MAC Error Handling ...");
        // 故意弄壞 Src_RAM 裡的 Tag (隨便挑一個 Byte 弄髒它)
        write_src_byte(126 + 5, 8'hEE); 
        
        @(negedge clk); start = 1'b1;
        @(negedge clk); start = 1'b0;

        wait(done == 1'b1);
        @(negedge clk);

        if (mac_error !== 1'b1) begin
            $display("  [TC3 FAIL] mac_error DID NOT assert on corrupted Tag!");
            error++;
        end else begin
            $display("  [TC3 PASS] mac_error asserted successfully.");
        end


        // =======================================================
        // [TC4] Corner Cases (Non-Aligned Lengths & Back-to-Back)
        // =======================================================
        $display("\n---> [TC4] Testing Non-Aligned Lengths (AD=7, MSG=13) ...");
        // 直接使用記憶體裡現存的髒資料來跑，我們只在乎狀態機不會掛掉 (Timeout)
        ad_length    = 32'd7;
        msg_length   = 32'd13;
        mode_decrypt = 1'b0; // 切回加密模式
        
        @(negedge clk); start = 1'b1;
        @(negedge clk); start = 1'b0;

        // 若 FSM 有 Bug，通常會在未對齊的邊界卡在 S_SRC_RD_REQ 導致死迴圈
        wait(done == 1'b1);
        @(negedge clk);
        $display("  [TC4 PASS] Corner Case finished without hanging!");


        // ==========================================
        // 輸出總結
        // ==========================================
        #(5 * `CYCLE);
        $display("\nComputation Done. All Test Cases Finished.");
        if (error === 0) begin
            $display("-------------------------------------------------------------");
            $display(" █████╗ ██╗     ██╗        ██████╗  █████╗ ███████╗███████╗");
            $display("██╔══██╗██║     ██║        ██╔══██╗██╔══██╗██╔════╝██╔════╝");
            $display("███████║██║     ██║        ██████╔╝███████║███████╗███████╗");
            $display("██╔══██║██║     ██║        ██╔═══╝ ██╔══██║╚════██║╚════██║");
            $display("██║  ██║███████╗███████╗    ██║     ██║  ██║███████║███████║");
            $display("╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝");
            $display("-------------------------------------------------------------");
            $display("TB RESULT : PASS (All Advanced Vectors Verified)");
        end else begin
            $display("-------------------------------------------------------------");
            $display("        **************************** ");
            $display("        ** |\\__||  ");
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
    // Timeout 保護機制
    // ==========================================
    initial begin
        #(`MAX_CYCLE * `CYCLE);
        $display("!! REACHED MAX CYCLE !! Simulation Timeout. Possible FSM Deadlock in TC4.");
        $finish;
    end

    // ==========================================
    // 波形輸出
    // ==========================================
    initial begin
        $fsdbDumpfile("RFC8439.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_rfc8439);
    end

endmodule