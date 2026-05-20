`timescale 1ns/1ps

`define CYCLE 28.0
`define MAX_CYCLE 2000000

module tb_rfc8439_multi;

    // =====================================================
    // New testbench parameters
    // =====================================================
    localparam MSG_BYTES       = 4096;
    localparam KEY_BYTES       = 32;
    localparam NONCE_BYTES     = 12;
    localparam HEADER_BYTES    = 48;    // 32B key + 12B nonce + 4B padding
    localparam HEADER_WORDS    = 12;

    // 4096B message + 48B header = 4144B = 1036 words.
    // Keep old video-sized memory margin for compatibility.
    localparam VIDEO_MEM_WORDS = 262144;
    localparam SRC_MEM_WORDS   = VIDEO_MEM_WORDS;
    localparam DST_MEM_WORDS   = VIDEO_MEM_WORDS;

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
    // Testcase memories
    // =====================================================
    // Old video_case_info layout:
    // video_info[0] = old AD length, only used to skip old source AAD
    // video_info[1] = old message length
    reg [31:0] video_info [0:1];

    // Read old source into temp, then repack into new Src RAM layout:
    // new src_mem = [key][nonce][padding][plaintext]
    reg [31:0] video_src_old    [0:VIDEO_MEM_WORDS-1];
    reg [31:0] video_golden_ct  [0:VIDEO_MEM_WORDS-1];

    integer video_old_ad_len;
    integer video_old_msg_len;
    integer video_error;

    integer cycle_count;
    integer start_cycle;
    integer done_cycle;
    integer total_cycles;
    real    throughput_mb_s;

    integer i;
    integer error;

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
    // Cycle counter
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    // =====================================================
    // SRAM behavior, word addressing
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
    // Config ports are removed.
    // Key and nonce must be read from Src RAM after start.
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
    // Helper functions / tasks
    // =====================================================
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

    task put_byte_to_src_mem;
        input integer byte_addr;
        input [7:0] data;
        integer word_addr;
        integer byte_offset;
    begin
        word_addr   = byte_addr / 4;
        byte_offset = byte_addr % 4;

        case (byte_offset)
            0: src_mem[word_addr][7:0]   = data;
            1: src_mem[word_addr][15:8]  = data;
            2: src_mem[word_addr][23:16] = data;
            3: src_mem[word_addr][31:24] = data;
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

        for (i = 0; i < VIDEO_MEM_WORDS; i = i + 1) begin
            video_src_old[i]   = 32'd0;
            video_golden_ct[i] = 32'd0;
        end
    end
    endtask

    task load_new_src_ram_layout;
        integer byte_idx;
        integer old_src_byte_idx;
        integer old_word_idx;
        integer old_byte_offset;
        reg [7:0] pt_b;
    begin
        // New Src RAM layout:
        // word 0~7   : 256-bit key, little endian words
        // word 8~10  : 96-bit nonce, little endian words
        // word 11    : padding word
        // word 12~   : 4096-byte plaintext

        // Key bytes: 80 81 82 ... 9f
        src_mem[0]  = 32'h83828180;
        src_mem[1]  = 32'h87868584;
        src_mem[2]  = 32'h8b8a8988;
        src_mem[3]  = 32'h8f8e8d8c;
        src_mem[4]  = 32'h93929190;
        src_mem[5]  = 32'h97969594;
        src_mem[6]  = 32'h9b9a9998;
        src_mem[7]  = 32'h9f9e9d9c;

        // Nonce bytes: 07 00 00 00 40 41 42 43 44 45 46 47
        src_mem[8]  = 32'h00000007;
        src_mem[9]  = 32'h43424140;
        src_mem[10] = 32'h47464544;

        // Padding to align plaintext to next word boundary after 44 bytes.
        src_mem[11] = 32'h00000000;

        for (byte_idx = 0; byte_idx < MSG_BYTES; byte_idx = byte_idx + 1) begin
            // Old video_src_encrypt layout was [AAD][Plaintext].
            // Skip old AD bytes and copy only plaintext.
            old_src_byte_idx = video_old_ad_len + byte_idx;
            old_word_idx = old_src_byte_idx / 4;
            old_byte_offset = old_src_byte_idx % 4;
            pt_b = get_byte_from_word_mem(video_src_old[old_word_idx], old_byte_offset);

            put_byte_to_src_mem(HEADER_BYTES + byte_idx, pt_b);
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

    task verify_video_ciphertext;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        video_error = 0;

        for (byte_idx = 0; byte_idx < MSG_BYTES; byte_idx = byte_idx + 1) begin
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
            $display("  [VIDEO CT PASS] all %0d bytes matched", MSG_BYTES);
        end else begin
            $display("  [VIDEO CT FAIL] total mismatch bytes = %0d", video_error);
        end
    end
    endtask

    task run_video_encrypt_benchmark;
    begin
        $display("");
        $display("=======================================================");
        $display("== RFC8439 4096B ENCRYPT TEST, KEY/NONCE FROM SRC RAM");
        $display("=======================================================");

        clear_runtime_mems();

        $readmemh("../testcase/video_case_info.txt", video_info);
        $readmemh("../testcase/video_src_encrypt.txt", video_src_old);
        $readmemh("../testcase/video_golden_ct.txt", video_golden_ct);

        video_old_ad_len  = video_info[0];
        video_old_msg_len = video_info[1];

        if (video_old_msg_len < MSG_BYTES) begin
            $display("[TB WARNING] old testcase msg length is %0d, but TB checks %0d bytes", video_old_msg_len, MSG_BYTES);
        end

        load_new_src_ram_layout();

        ad_length    = 32'd0;
        msg_length   = MSG_BYTES[31:0];
        mode_decrypt = 1'b0;

        $display("AD length        = %0d bytes", ad_length);
        $display("MSG length       = %0d bytes", msg_length);
        $display("Src RAM layout   = key 32B + nonce 12B + padding 4B + plaintext 4096B");
        $display("Mode             = encryption only");
        $display("Golden check     = ciphertext only, 4096 bytes");

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

        // CYCLE = 28ns.
        // MB/s = bytes / (cycles * 28ns) / 1e6
        throughput_mb_s = (MSG_BYTES * 1000.0) / (total_cycles * `CYCLE);

        $display("");
        $display("=======================================================");
        $display("4096B ENCRYPT RESULT");
        $display("Start cycle = %0d", start_cycle);
        $display("Done cycle  = %0d", done_cycle);
        $display("Cycles      = %0d", total_cycles);
        $display("Throughput  = %0f MB/s @ cycle=%0f ns", throughput_mb_s, `CYCLE);

        $display("");
        $display("Verifying 4096B ciphertext...");
        verify_video_ciphertext();

        if (video_error == 0) begin
            $display("VERIFY RESULT : PASS");
        end else begin
            $display("VERIFY RESULT : FAIL, errors = %0d", video_error);
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

        error        = 0;
        video_error  = 0;

        cycle_count  = 0;
        start_cycle  = 0;
        done_cycle   = 0;
        total_cycles = 0;
        throughput_mb_s = 0.0;

        clear_runtime_mems();

        $display("");
        $display("=======================================================");
        $display("== RFC8439 Testbench, config removed");
        $display("=======================================================");

        rst = 1'b1;
        #(5 * `CYCLE);
        @(negedge clk);
        rst = 1'b0;
        #(2 * `CYCLE);

        run_video_encrypt_benchmark();

        #(5 * `CYCLE);

        $display("");
        if (error == 0) begin
            $display("TB RESULT : PASS");
        end else begin
            $display("TB RESULT : FAIL, errors = %0d", error);
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
