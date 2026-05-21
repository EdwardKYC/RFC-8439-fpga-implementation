`timescale 1ns/1ps

`define CYCLE 10.0
`define MAX_CYCLE 300000

// ==========================================
// 根據外部 define 決定要讀取的測試檔案
// 在 VCS 編譯時加入參數： +define+T2 (以此類推)
// ==========================================
`ifdef T1
    `define TEST_FILE  "../testcase/chacha_keystream.txt"
    `define TEST_KEY   256'h1f1e1d1c_1b1a1918_17161514_13121110_0f0e0d0c_0b0a0908_07060504_03020100
    `define TEST_NONCE 96'h00000000_4a000000_09000000
    `define TEST_COUNT 32'd0
`elsif T2
    `define TEST_FILE  "../chacha_test2.txt"
    `define TEST_KEY   256'h0000000000000000000000000000000000000000000000000000000000000000
    `define TEST_NONCE 96'h000000000000000000000000
    `define TEST_COUNT 32'd0
`elsif T3
    `define TEST_FILE  "../chacha_test3.txt"
    `define TEST_KEY   256'h0000000000000000000000000000000000000000000000000000000000000000
    `define TEST_NONCE 96'h000000000000000000000000
    `define TEST_COUNT 32'd1
`elsif T4
    `define TEST_FILE  "../chacha_test4.txt"
    `define TEST_KEY   256'h0000000000000000000000000000000000000000000000000000000000000001
    `define TEST_NONCE 96'h000000000000000000000000
    `define TEST_COUNT 32'd1
`elsif T5
    `define TEST_FILE  "../chacha_test5.txt"
    `define TEST_KEY   256'h00ff000000000000000000000000000000000000000000000000000000000000
    `define TEST_NONCE 96'h000000000000000000000000
    `define TEST_COUNT 32'd2
`elsif T6
    `define TEST_FILE  "../chacha_test6.txt"
    `define TEST_KEY   256'h0000000000000000000000000000000000000000000000000000000000000000
    `define TEST_NONCE 96'h000000000000000000000002
    `define TEST_COUNT 32'd0
`else
    `define TEST_FILE  "../chacha_test.txt" 
    `define TEST_KEY   256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
    `define TEST_NONCE 96'h000000090000004a00000000
    `define TEST_COUNT 32'd1
`endif

`ifdef syn
    `include "/cad/designkit/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v"
    `include "Chacha20_syn.v"
`endif

module tb_chacha;

    localparam integer N = 16384; 

    reg         clk;
    reg         rst;

    reg         start;
    wire        ready;

    reg [255:0] key;
    reg [95:0]  nonce;
    reg [31:0]  counter;
    wire [511:0] keystream;

    reg [31:0]  Golden_ANS [0:N-1];
    integer     error;
    integer     w; 

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

    initial begin
        clk     = 0;
        rst     = 0;
        start   = 0;
        error   = 0;
        
        key     = `TEST_KEY;
        nonce   = `TEST_NONCE;
        counter = `TEST_COUNT;

        $display("        ********************************************");
        $display("        ** Chacha20 Simulation Start (Single) **");
        $display("        ** Loading Test File: %s", `TEST_FILE);
        $display("        ********************************************\n");

        $readmemh(`TEST_FILE, Golden_ANS);

        rst = 1;
        #(3 * `CYCLE);
        rst = 0;

        $display("Starting Single Keystream Generation and Verification...");

        #(`CYCLE);
        @(negedge clk); 
        start = 1;       
        @(negedge clk); 
        start = 0;            
        
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
            if (keystream[w*32 +: 32] !== Golden_ANS[w]) begin
                $display("Error at Word [%2d]! Expected: %08x, Got: %08x", 
                          w, Golden_ANS[w], keystream[w*32 +: 32]);
                error = error + 1;
            end
        end
        
        @(posedge clk);

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

    initial begin
        #(`MAX_CYCLE * `CYCLE)
        $display("\n-- Reach Max cycle!!!!!! Simulation terminated.");
        $finish;
    end

    initial begin
        $fsdbDumpfile("Chacha20.fsdb");
        $fsdbDumpvars();
        $fsdbDumpvars("+struct", "+mda", tb_chacha);
    end

endmodule