`timescale 1ns/1ps

`define CYCLE 28.0
`define MAX_CYCLE 2000000

module tb_rfc8439_multi;

    localparam MSG_BYTES       = 4096;
    localparam HEADER_BYTES    = 48;
    localparam VIDEO_MEM_WORDS = 262144;
    localparam SRC_MEM_WORDS   = VIDEO_MEM_WORDS;
    localparam DST_MEM_WORDS   = VIDEO_MEM_WORDS;

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

    reg [31:0] src_mem [0:SRC_MEM_WORDS-1];
    reg [31:0] dst_mem [0:DST_MEM_WORDS-1];

    reg [31:0] video_info      [0:1];
    reg [31:0] video_golden_ct [0:VIDEO_MEM_WORDS-1];

    integer cycle_count;
    integer start_cycle;
    integer done_cycle;
    integer total_cycles;
    real    throughput_mb_s;

    integer i;
    integer error;
    integer video_error;

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

    task clear_runtime_mems;
    begin
        for (i = 0; i < SRC_MEM_WORDS; i = i + 1) begin
            src_mem[i] = 32'd0;
        end

        for (i = 0; i < DST_MEM_WORDS; i = i + 1) begin
            dst_mem[i] = 32'd0;
        end

        for (i = 0; i < VIDEO_MEM_WORDS; i = i + 1) begin
            video_golden_ct[i] = 32'd0;
        end
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
                    $display("  [VIDEO CT FAIL] byte=%0d Exp=%02x Got=%02x",
                             byte_idx, exp_b, got_b);
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
        $display("== RFC8439 4096B ENCRYPT TEST, DIRECT NEW SRC LAYOUT");
        $display("=======================================================");

        clear_runtime_mems();

        $readmemh("../testcase/small_tb_info.txt", video_info);
        $readmemh("../testcase/Src_RAM_data.txt", src_mem);
        $readmemh("../testcase/Dst_RAM_data.txt", video_golden_ct);

        if (video_info[0] != 32'd0) begin
            $display("[TB WARNING] testcase AD length is %0d, expected 0", video_info[0]);
        end

        if (video_info[1] != MSG_BYTES) begin
            $display("[TB WARNING] testcase MSG length is %0d, expected %0d",
                     video_info[1], MSG_BYTES);
        end

        ad_length    = 32'd0;
        msg_length   = MSG_BYTES;
        mode_decrypt = 1'b0;

        $display("AD length        = %0d bytes", ad_length);
        $display("MSG length       = %0d bytes", msg_length);
        $display("Src RAM layout   = key 32B + nonce 12B + padding 4B + plaintext 4096B");
        $display("Mode             = encryption only");
        $display("Golden check     = ciphertext only, 4096 bytes");
        $display("Src[0] key word  = %08x", src_mem[0]);
        $display("Src[8] nonce word= %08x", src_mem[8]);
        $display("Src[12] PT word  = %08x", src_mem[12]);

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
        $display("== RFC8439 Testbench, direct SrcRAM testcase layout");
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