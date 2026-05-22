`timescale 1ns/1ps

`define CYCLE 28.0
`define MAX_CYCLE 2000000

module tb_rfc8439_multi;

    localparam MSG_BYTES          = 4096;
    localparam TAG_BYTES          = 16;
    localparam SRC_AAD_BASE_BYTES = 44;
    localparam VIDEO_MEM_WORDS    = 262144;
    localparam SRC_MEM_WORDS      = VIDEO_MEM_WORDS;
    localparam DST_MEM_WORDS      = VIDEO_MEM_WORDS;
    localparam DST_CHECK_BYTES    = MSG_BYTES + TAG_BYTES;

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
    wire [3:0]  Src_RAM_we;
    wire [31:0] Src_RAM_D;
    reg  [31:0] Src_RAM_Q;

    wire [31:0] Dst_RAM_addr;
    wire        Dst_RAM_en;
    wire [3:0]  Dst_RAM_we;
    wire [31:0] Dst_RAM_D;
    reg  [31:0] Dst_RAM_Q;

    reg [31:0] src_mem [0:SRC_MEM_WORDS-1];
    reg [31:0] dst_mem [0:DST_MEM_WORDS-1];

    reg [31:0] video_info        [0:1];
    reg [31:0] video_src_encrypt [0:VIDEO_MEM_WORDS-1];
    reg [31:0] video_golden_dst  [0:VIDEO_MEM_WORDS-1];

    integer cycle_count;
    integer start_cycle;
    integer done_cycle;
    integer total_cycles;
    real    throughput_mb_s;

    integer i;
    integer error;
    integer video_error;
    integer msg_base;

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

    always @(posedge clk or posedge rst) begin
        if (rst) cycle_count <= 0;
        else     cycle_count <= cycle_count + 1;
    end

    always @(posedge clk) begin
        if (Src_RAM_en) begin
            if (|Src_RAM_we) src_mem[Src_RAM_addr] <= Src_RAM_D;
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

    function [31:0] align16;
        input [31:0] byte_addr;
    begin
        align16 = (byte_addr + 32'd15) & 32'hFFFF_FFF0;
    end
    endfunction

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
        for (i = 0; i < SRC_MEM_WORDS; i = i + 1) src_mem[i] = 32'd0;
        for (i = 0; i < DST_MEM_WORDS; i = i + 1) dst_mem[i] = 32'd0;
        for (i = 0; i < VIDEO_MEM_WORDS; i = i + 1) begin
            video_src_encrypt[i] = 32'd0;
            video_golden_dst[i]  = 32'd0;
        end
    end
    endtask

    task clear_dst_mem;
    begin
        for (i = 0; i < DST_MEM_WORDS; i = i + 1) dst_mem[i] = 32'd0;
    end
    endtask

    task build_decrypt_src_ram;
        input integer base;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] data_b;
    begin
        for (byte_idx = 0; byte_idx < base; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;
            data_b = get_byte_from_word_mem(video_src_encrypt[word_idx], byte_offset);
            put_byte_to_src_mem(byte_idx, data_b);
        end

        for (byte_idx = 0; byte_idx < DST_CHECK_BYTES; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;
            data_b = get_byte_from_word_mem(video_golden_dst[word_idx], byte_offset);
            put_byte_to_src_mem(base + byte_idx, data_b);
        end
    end
    endtask

    task verify_encrypt_dst;
        integer byte_idx;
        integer word_idx;
        integer byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        video_error = 0;

        for (byte_idx = 0; byte_idx < DST_CHECK_BYTES; byte_idx = byte_idx + 1) begin
            word_idx = byte_idx / 4;
            byte_offset = byte_idx % 4;

            exp_b = get_byte_from_word_mem(video_golden_dst[word_idx], byte_offset);
            got_b = get_byte_from_word_mem(dst_mem[word_idx], byte_offset);

            if (exp_b !== got_b) begin
                if (video_error < 20) begin
                    if (byte_idx < MSG_BYTES)
                        $display("  [ENC CT FAIL] byte=%0d Exp=%02x Got=%02x", byte_idx, exp_b, got_b);
                    else
                        $display("  [ENC TAG FAIL] tag_byte=%0d Exp=%02x Got=%02x",
                                 byte_idx - MSG_BYTES, exp_b, got_b);
                end
                video_error = video_error + 1;
            end
        end

        if (video_error == 0)
            $display("  [ENC PASS] ciphertext %0d bytes + tag %0d bytes matched", MSG_BYTES, TAG_BYTES);
        else
            $display("  [ENC FAIL] total mismatch bytes = %0d", video_error);
    end
    endtask

    task verify_decrypt_plaintext;
        input integer base;
        integer byte_idx;
        integer exp_byte_addr;
        integer exp_word_idx;
        integer exp_byte_offset;
        integer got_word_idx;
        integer got_byte_offset;
        reg [7:0] exp_b;
        reg [7:0] got_b;
    begin
        video_error = 0;

        for (byte_idx = 0; byte_idx < MSG_BYTES; byte_idx = byte_idx + 1) begin
            exp_byte_addr = base + byte_idx;
            exp_word_idx = exp_byte_addr / 4;
            exp_byte_offset = exp_byte_addr % 4;

            got_word_idx = byte_idx / 4;
            got_byte_offset = byte_idx % 4;

            exp_b = get_byte_from_word_mem(video_src_encrypt[exp_word_idx], exp_byte_offset);
            got_b = get_byte_from_word_mem(dst_mem[got_word_idx], got_byte_offset);

            if (exp_b !== got_b) begin
                if (video_error < 20)
                    $display("  [DEC PT FAIL] byte=%0d Exp=%02x Got=%02x", byte_idx, exp_b, got_b);
                video_error = video_error + 1;
            end
        end

        if (video_error == 0)
            $display("  [DEC PASS] plaintext %0d bytes matched", MSG_BYTES);
        else
            $display("  [DEC FAIL] total mismatch bytes = %0d", video_error);
    end
    endtask

    task pulse_start_and_wait;
    begin
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
        throughput_mb_s = (MSG_BYTES * 1000.0) / (total_cycles * `CYCLE);
    end
    endtask

    task run_encrypt_then_decrypt;
    begin
        $display("");
        $display("=======================================================");
        $display("== RFC8439 ENCRYPT + DECRYPT TEST");
        $display("=======================================================");

        clear_runtime_mems();

        $readmemh("../testcase/video_case_info.txt", video_info);
        $readmemh("../testcase/video_src_encrypt.txt", video_src_encrypt);
        $readmemh("../testcase/video_golden_dst.txt", video_golden_dst);

        if (video_info[1] != MSG_BYTES) begin
            $display("[TB WARNING] testcase MSG length is %0d, expected %0d",
                     video_info[1], MSG_BYTES);
        end

        msg_base = align16(SRC_AAD_BASE_BYTES + video_info[0]);

        // ---------------- Encrypt ----------------
        for (i = 0; i < SRC_MEM_WORDS; i = i + 1) src_mem[i] = video_src_encrypt[i];
        clear_dst_mem();

        ad_length    = video_info[0];
        msg_length   = MSG_BYTES;
        mode_decrypt = 1'b0;

        $display("");
        $display("[ENCRYPT]");
        $display("AD length        = %0d bytes", ad_length);
        $display("MSG length       = %0d bytes", msg_length);
        $display("Message base     = byte %0d, word %0d", msg_base, msg_base / 4);
        $display("Src[0] key word  = %08x", src_mem[0]);
        $display("Src[8] nonce word= %08x", src_mem[8]);
        $display("Src[msg_base] PT = %08x", src_mem[msg_base / 4]);

        pulse_start_and_wait();

        $display("Encrypt cycles   = %0d", total_cycles);
        $display("Encrypt throughput = %0f MB/s @ cycle=%0f ns", throughput_mb_s, `CYCLE);
        $display("Verifying encrypt DstRAM ciphertext + tag...");
        verify_encrypt_dst();

        if (video_error != 0) begin
            error = error + video_error;
        end

        // ---------------- Decrypt ----------------
        build_decrypt_src_ram(msg_base);
        clear_dst_mem();

        ad_length    = video_info[0];
        msg_length   = MSG_BYTES;
        mode_decrypt = 1'b1;

        $display("");
        $display("[DECRYPT]");
        $display("Src RAM layout   = key + nonce + AAD + padding + ciphertext + tag");
        $display("Dst check        = plaintext only, mac_error must be 0");
        $display("Src[msg_base] CT = %08x", src_mem[msg_base / 4]);

        pulse_start_and_wait();

        $display("Decrypt cycles   = %0d", total_cycles);
        $display("Decrypt throughput = %0f MB/s @ cycle=%0f ns", throughput_mb_s, `CYCLE);
        $display("Verifying decrypt DstRAM plaintext...");
        verify_decrypt_plaintext(msg_base);

        if (mac_error !== 1'b0) begin
            $display("  [DEC TAG FAIL] mac_error = %b", mac_error);
            video_error = video_error + 1;
        end else begin
            $display("  [DEC TAG PASS] mac_error = 0");
        end

        if (video_error != 0) begin
            error = error + video_error;
        end

        $display("=======================================================");
    end
    endtask

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
        msg_base = 0;

        clear_runtime_mems();

        $display("");
        $display("=======================================================");
        $display("== RFC8439 Testbench, encrypt then decrypt");
        $display("=======================================================");

        rst = 1'b1;
        #(5 * `CYCLE);
        @(negedge clk);
        rst = 1'b0;
        #(2 * `CYCLE);

        run_encrypt_then_decrypt();

        #(5 * `CYCLE);

        $display("");
        if (error == 0) $display("TB RESULT : PASS");
        else            $display("TB RESULT : FAIL, errors = %0d", error);

        $finish;
    end

    initial begin
        #(`MAX_CYCLE * `CYCLE);
        $display("!! REACHED MAX CYCLE !! Simulation Timeout.");
        $finish;
    end

    initial begin
        $fsdbDumpfile("RFC8439.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_rfc8439_multi);
    end

endmodule