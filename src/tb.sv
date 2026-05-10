`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 2000000

module tb_rfc8439_multi;

    // =====================================================
    // User parameters
    // =====================================================
    localparam NUM_CASES = 58;

    localparam MAX_MSG_WORDS = 256;
    localparam MAX_SRC_WORDS = 320;
    localparam MAX_PT_WORDS  = 256;
    localparam TAG_WORDS     = 4;

    // 480p RGB888 = 640 * 480 * 3 = 921600 bytes.
    // Need about 230400 32-bit words, plus AAD/tag margin.
    localparam VIDEO_MEM_WORDS = 262144;

    localparam SRC_MEM_WORDS = VIDEO_MEM_WORDS;
    localparam DST_MEM_WORDS = VIDEO_MEM_WORDS;

    // =====================================================
    // DUT signals
    // =====================================================
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

    wire [31:0] Src_RAM_addr;
    wire        Src_RAM_en;
    wire        Src_RAM_we;
    wire [31:0] Src_RAM_D;
    reg  [31:0] Src_RAM_Q;

    wire [31:0] Dst_RAM_addr;
    wire        Dst_RAM_en;
    wire [3:0]  Dst_RAM_we;
    wire [31:0] Dst_RAM_D;
    reg  [31:0] Dst_RAM_Q;

    // =====================================================
    // RAM model
    // =====================================================
    reg [31:0] src_mem [0:SRC_MEM_WORDS-1];
    reg [31:0] dst_mem [0:DST_MEM_WORDS-1];

    // =====================================================
    // Multi-case vector memories
    // =====================================================
    // case_info layout:
    // case_info[case_id*2 + 0] = ad_length
    // case_info[case_id*2 + 1] = msg_length
    reg [31:0] case_info       [0:NUM_CASES*2-1];

    reg [31:0] golden_ct_all   [0:NUM_CASES*MAX_MSG_WORDS-1];
    reg [31:0] golden_tag_all  [0:NUM_CASES*TAG_WORDS-1];
    reg [31:0] golden_pt_all   [0:NUM_CASES*MAX_PT_WORDS-1];

    // src_encrypt_all layout per case:
    // [AAD][PT]
    reg [31:0] src_encrypt_all [0:NUM_CASES*MAX_SRC_WORDS-1];

    // src_decrypt_all layout per case:
    // [AAD][CT][TAG]
    reg [31:0] src_decrypt_all [0:NUM_CASES*MAX_SRC_WORDS-1];

    // =====================================================
    // Video speed benchmark memories
    // =====================================================
    reg [31:0] video_info [0:1];

    reg [31:0] video_golden_ct  [0:VIDEO_MEM_WORDS-1];
    reg [31:0] video_golden_tag [0:TAG_WORDS-1];

    integer video_ad_len;
    integer video_msg_len;
    integer video_error;
    integer video_compare_limit;

    integer cycle_count;
    integer start_cycle;
    integer done_cycle;
    integer total_cycles;

    real throughput_mb_s;

    integer i;
    integer case_id;
    integer error;
    integer case_error;

    integer ad_len_int;
    integer msg_len_int;

    // =====================================================
    // Clock
    // =====================================================
    always #(`CYCLE / 2.0) clk = ~clk;
    `ifdef SDF
    initial begin
        $display("[TB] Annotating SDF...");
        $sdf_annotate("../src/RFC8439.sdf", tb_rfc8439_multi.dut);
        $display("[TB] SDF annotation done.");
    end
    `else
    initial begin
        $display("[TB] SDF annotation disabled.");
    end
    `endif

    // =====================================================
    // Cycle counter for speed benchmark
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    // =====================================================
    // SRAM behavior
    // =====================================================
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
            if (Dst_RAM_we[0]) dst_mem[Dst_RAM_addr][7:0]   <= Dst_RAM_D[7:0];
            if (Dst_RAM_we[1]) dst_mem[Dst_RAM_addr][15:8]  <= Dst_RAM_D[15:8];
            if (Dst_RAM_we[2]) dst_mem[Dst_RAM_addr][23:16] <= Dst_RAM_D[23:16];
            if (Dst_RAM_we[3]) dst_mem[Dst_RAM_addr][31:24] <= Dst_RAM_D[31:24];

            Dst_RAM_Q <= dst_mem[Dst_RAM_addr];
        end
    end

    // =====================================================
    // DUT
    // =====================================================
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

    // =====================================================
    // Helper tasks
    // =====================================================
    task write_config(input [3:0] addr, input [31:0] data);
    begin
        @(negedge clk);
        #2;
        config_addr = addr;
        config_data = data;
        config_we   = 1'b1;

        @(negedge clk);
        #2;
        config_we   = 1'b0;
    end
    endtask

    task flip_src_byte(input integer byte_addr);
        integer word_addr;
        integer byte_offset;
    begin
        word_addr = byte_addr / 4;
        byte_offset = byte_addr % 4;

        case (byte_offset)
            0: src_mem[word_addr][7:0]   = src_mem[word_addr][7:0]   ^ 8'h01;
            1: src_mem[word_addr][15:8]  = src_mem[word_addr][15:8]  ^ 8'h01;
            2: src_mem[word_addr][23:16] = src_mem[word_addr][23:16] ^ 8'h01;
            3: src_mem[word_addr][31:24] = src_mem[word_addr][31:24] ^ 8'h01;
        endcase
    end
    endtask

    task clear_runtime_mems;
    begin
        for (i = 0; i < SRC_MEM_WORDS; i = i + 1) begin
            src_mem[i] = 32'd0;
        end

        for (i = 0; i < DST_MEM_WORDS; i = i + 1) begin
            dst_mem[i] = 32'd0;
        end
    end
    endtask

    task load_src_encrypt(input integer cid);
        integer base;
    begin
        clear_runtime_mems();

        base = cid * MAX_SRC_WORDS;

        for (i = 0; i < MAX_SRC_WORDS; i = i + 1) begin
            src_mem[i] = src_encrypt_all[base + i];
        end
    end
    endtask

    task load_src_decrypt(input integer cid);
        integer base;
    begin
        clear_runtime_mems();

        base = cid * MAX_SRC_WORDS;

        for (i = 0; i < MAX_SRC_WORDS; i = i + 1) begin
            src_mem[i] = src_decrypt_all[base + i];
        end
    end
    endtask

    task pulse_start;
    begin
        @(negedge clk);
        #(`CYCLE/4);
        start = 1'b1;

        @(negedge clk);
        #(`CYCLE/4);
        start = 1'b0;
    end
    endtask

    task run_dut(input integer decrypt_mode);
    begin
        @(negedge clk);
        #1;
        mode_decrypt = decrypt_mode[0];

        pulse_start();

        wait(done == 1'b1);
        @(negedge clk);
    end
    endtask

    task verify_ciphertext(input integer cid);
        integer base;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        base = cid * MAX_MSG_WORDS;

        for (byte_idx = 0; byte_idx < msg_len_int; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;

            exp_b = golden_ct_all[base + word_idx] >> (byte_offset * 8);
            got_b = dst_mem[word_idx] >> (byte_offset * 8);

            if (exp_b !== got_b) begin
                $display("  [ENC FAIL] case=%0d CT byte=%0d Exp=%02x Got=%02x", cid, byte_idx, exp_b, got_b);
                error = error + 1;
                case_error = case_error + 1;
            end
        end
    end
    endtask

    task verify_tag(input integer cid);
        integer base;
        integer byte_idx;
        integer mem_idx;
        integer exp_word_idx;
        integer exp_byte_offset;
        integer got_word_idx;
        integer got_byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        base = cid * TAG_WORDS;

        for (byte_idx = 0; byte_idx < 16; byte_idx = byte_idx + 1) begin
            mem_idx = msg_len_int + byte_idx;

            exp_word_idx = byte_idx / 4;
            exp_byte_offset = byte_idx % 4;

            got_word_idx = mem_idx / 4;
            got_byte_offset = mem_idx % 4;

            exp_b = golden_tag_all[base + exp_word_idx] >> (exp_byte_offset * 8);
            got_b = dst_mem[got_word_idx] >> (got_byte_offset * 8);

            if (exp_b !== got_b) begin
                $display("  [ENC FAIL] case=%0d TAG byte=%0d Exp=%02x Got=%02x", cid, byte_idx, exp_b, got_b);
                error = error + 1;
                case_error = case_error + 1;
            end
        end
    end
    endtask

    task verify_plaintext(input integer cid);
        integer base;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        base = cid * MAX_PT_WORDS;

        for (byte_idx = 0; byte_idx < msg_len_int; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;

            exp_b = golden_pt_all[base + word_idx] >> (byte_offset * 8);
            got_b = dst_mem[word_idx] >> (byte_offset * 8);

            if (exp_b !== got_b) begin
                $display("  [DEC FAIL] case=%0d PT byte=%0d Exp=%02x Got=%02x", cid, byte_idx, exp_b, got_b);
                error = error + 1;
                case_error = case_error + 1;
            end
        end
    end
    endtask

    task run_one_case(input integer cid);
    begin
        ad_len_int = case_info[cid*2 + 0];
        msg_len_int = case_info[cid*2 + 1];

        ad_length = ad_len_int;
        msg_length = msg_len_int;

        case_error = 0;

        $display("");
        $display("=======================================================");
        $display("CASE %0d", cid);
        $display("AD length  = %0d", ad_len_int);
        $display("MSG length = %0d", msg_len_int);
        $display("=======================================================");

        // -------------------------
        // Encryption
        // -------------------------
        $display("---> Encryption");

        load_src_encrypt(cid);
        run_dut(0);

        verify_ciphertext(cid);
        verify_tag(cid);

        if (case_error == 0) begin
            $display("  [ENC PASS]");
        end

        // -------------------------
        // Decryption with valid tag
        // -------------------------
        $display("---> Decryption valid tag");

        load_src_decrypt(cid);
        run_dut(1);

        if (mac_error !== 1'b0) begin
            $display("  [DEC FAIL] mac_error asserted on valid tag");
            error = error + 1;
            case_error = case_error + 1;
        end

        verify_plaintext(cid);

        if (case_error == 0) begin
            $display("  [DEC PASS]");
        end

        // -------------------------
        // Decryption with corrupted tag
        // -------------------------
        $display("---> Decryption corrupted tag");

        load_src_decrypt(cid);

        if (msg_len_int + ad_len_int + 5 < 4 * MAX_SRC_WORDS) begin
            flip_src_byte(ad_len_int + msg_len_int + 5);
        end else begin
            flip_src_byte(ad_len_int + msg_len_int);
        end

        run_dut(1);

        if (mac_error !== 1'b1) begin
            $display("  [TAG FAIL] mac_error did not assert on corrupted tag");
            error = error + 1;
            case_error = case_error + 1;
        end else begin
            $display("  [TAG PASS]");
        end

        if (case_error == 0) begin
            $display("CASE %0d PASS", cid);
        end else begin
            $display("CASE %0d FAIL, case_error=%0d", cid, case_error);
        end
    end
    endtask



    function [7:0] get_byte_from_word_mem;
        input [31:0] word;
        input integer byte_offset;
    begin
        case (byte_offset)
            0: get_byte_from_word_mem = word[7:0];
            1: get_byte_from_word_mem = word[15:8];
            2: get_byte_from_word_mem = word[23:16];
            3: get_byte_from_word_mem = word[31:24];
            default: get_byte_from_word_mem = 8'd0;
        endcase
    end
    endfunction

    task verify_video_ciphertext;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        video_error = 0;

        for (byte_idx = 0; byte_idx < video_msg_len; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;

            exp_b = get_byte_from_word_mem(video_golden_ct[word_idx], byte_offset);
            got_b = get_byte_from_word_mem(dst_mem[word_idx], byte_offset);

            if (exp_b !== got_b) begin
                if (video_error < 20) begin
                    $display("  [VIDEO CT FAIL] byte=%0d Exp=%02x Got=%02x", byte_idx, exp_b, got_b);
                end
                video_error = video_error + 1;
            end
        end

        if (video_error == 0) begin
            $display("  [VIDEO CT PASS] all %0d bytes matched", video_msg_len);
        end else begin
            $display("  [VIDEO CT FAIL] total mismatch bytes = %0d", video_error);
        end
    end
    endtask

    task verify_video_tag;
        integer byte_idx;
        integer exp_word_idx;
        integer exp_byte_offset;
        integer got_mem_byte_idx;
        integer got_word_idx;
        integer got_byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        for (byte_idx = 0; byte_idx < 16; byte_idx = byte_idx + 1) begin
            exp_word_idx = byte_idx / 4;
            exp_byte_offset = byte_idx % 4;

            got_mem_byte_idx = video_msg_len + byte_idx;
            got_word_idx = got_mem_byte_idx / 4;
            got_byte_offset = got_mem_byte_idx % 4;

            exp_b = get_byte_from_word_mem(video_golden_tag[exp_word_idx], exp_byte_offset);
            got_b = get_byte_from_word_mem(dst_mem[got_word_idx], got_byte_offset);

            if (exp_b !== got_b) begin
                if (video_error < 20) begin
                    $display("  [VIDEO TAG FAIL] byte=%0d Exp=%02x Got=%02x", byte_idx, exp_b, got_b);
                end
                video_error = video_error + 1;
            end
        end

        if (video_error == 0) begin
            $display("  [VIDEO TAG PASS] 16-byte tag matched");
        end else begin
            $display("  [VIDEO VERIFY FAIL] total mismatch bytes = %0d", video_error);
        end
    end
    endtask


    task run_video_encrypt_benchmark;
    begin
        $display("");
        $display("=======================================================");
        $display("== RFC8439 VIDEO ENCRYPT SPEED BENCHMARK");
        $display("=======================================================");

        clear_runtime_mems();

        // File layout:
        // video_case_info[0] = ad_length
        // video_case_info[1] = msg_length
        //
        // video_src_encrypt layout:
        // [AAD][Plaintext]
        //
        // golden_ct layout:
        // [Ciphertext only]
        //
        // golden_tag layout:
        // [Tag only]
        $readmemh("../testcase/video_case_info.txt", video_info);
        $readmemh("../testcase/video_src_encrypt.txt", src_mem);
        $readmemh("../testcase/video_golden_ct.txt", video_golden_ct);
        $readmemh("../testcase/video_golden_tag.txt", video_golden_tag);

        video_ad_len  = video_info[0];
        video_msg_len = video_info[1];

        ad_length  = video_ad_len[31:0];
        msg_length = video_msg_len[31:0];

        mode_decrypt = 1'b0;

        $display("AD length  = %0d bytes", video_ad_len);
        $display("MSG length = %0d bytes", video_msg_len);
        $display("Mode       = encryption only");
        $display("Golden     = enabled, ciphertext + tag byte check");

        @(negedge clk);
        #2;
        start_cycle = cycle_count;
        start = 1'b1;

        @(negedge clk);
        #2;
        start = 1'b0;

        wait(done == 1'b1);

        done_cycle = cycle_count;
        total_cycles = done_cycle - start_cycle;

        // 100 MHz:
        // MB/s = bytes / cycles * 100,000,000 / 1,000,000
        //      = bytes / cycles * 100
        throughput_mb_s = (video_msg_len * 100.0) / total_cycles;

        $display("");
        $display("=======================================================");
        $display("VIDEO BENCHMARK RESULT");
        $display("Start cycle = %0d", start_cycle);
        $display("Done cycle  = %0d", done_cycle);
        $display("Cycles      = %0d", total_cycles);
        $display("Throughput  = %0f MB/s @ 100MHz", throughput_mb_s);

        $display("");
        $display("Verifying video ciphertext and tag...");
        verify_video_ciphertext();
        verify_video_tag();

        if (video_error == 0) begin
            $display("VIDEO VERIFY RESULT : PASS");
        end else begin
            $display("VIDEO VERIFY RESULT : FAIL, errors = %0d", video_error);
            error = error + video_error;
        end

        $display("=======================================================");
    end
    endtask

    // =====================================================
    // Main
    // =====================================================
    initial begin
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
        case_error   = 0;

        cycle_count  = 0;
        start_cycle  = 0;
        done_cycle   = 0;
        total_cycles = 0;
        throughput_mb_s = 0.0;

        clear_runtime_mems();

        $display("");
        $display("=======================================================");
        $display("== RFC8439 Video Speed Testbench");
        $display("=======================================================");

        rst = 1'b1;
        #(5 * `CYCLE);
        @(negedge clk);
        rst = 1'b0;
        #(2 * `CYCLE);

        // Key bytes: 80 81 82 ... 9f
        // Nonce bytes: 07 00 00 00 40 41 42 43 44 45 46 47
        write_config(4'd0,  32'h83828180);
        write_config(4'd1,  32'h87868584);
        write_config(4'd2,  32'h8b8a8988);
        write_config(4'd3,  32'h8f8e8d8c);
        write_config(4'd4,  32'h93929190);
        write_config(4'd5,  32'h97969594);
        write_config(4'd6,  32'h9b9a9998);
        write_config(4'd7,  32'h9f9e9d9c);
        write_config(4'd8,  32'h00000007);
        write_config(4'd9,  32'h43424140);
        write_config(4'd10, 32'h47464544);

        run_video_encrypt_benchmark();

        #(5 * `CYCLE);

        $display("");
        if (error == 0) begin
            $display("TB RESULT : VIDEO SPEED + VERIFY PASS");
        end else begin
            $display("TB RESULT : VIDEO SPEED + VERIFY FAIL, errors = %0d", error);
        end
        $finish;
    end

    // =====================================================
    // Timeout
    // =====================================================
    initial begin
        #(`MAX_CYCLE * `CYCLE);
        $display("!! REACHED MAX CYCLE !! Simulation Timeout.");
        $finish;
    end

    // =====================================================
    // Waveform
    // =====================================================
    initial begin
        $fsdbDumpfile("RFC8439.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_rfc8439_multi);
    end

endmodule
