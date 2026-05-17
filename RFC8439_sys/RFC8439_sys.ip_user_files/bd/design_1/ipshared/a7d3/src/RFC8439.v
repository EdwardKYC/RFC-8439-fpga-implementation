module RFC8439 #(
    parameter ADDR_MODE_WORD = 1
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire        mode_decrypt,
    output reg         done,
    output reg         mac_error,
    input  wire [31:0] msg_length,
    input  wire [31:0] ad_length,
    input  wire [3:0]  config_addr,
    input  wire [31:0] config_data,
    input  wire        config_we,
    output wire [31:0] Src_RAM_addr,
    output wire        Src_RAM_en,
    output wire        Src_RAM_we,
    output wire [31:0] Src_RAM_D,
    input  wire [31:0] Src_RAM_Q,
    output wire [31:0] Dst_RAM_addr,
    output wire        Dst_RAM_en,
    output wire [3:0]  Dst_RAM_we,
    output wire [31:0] Dst_RAM_D,
    input  wire [31:0] Dst_RAM_Q
);

    localparam [4:0] M_IDLE = 5'd0;
    localparam [4:0] M_INIT_KEY = 5'd1;
    localparam [4:0] M_INIT_WAIT = 5'd2;
    localparam [4:0] M_AAD_CHECK = 5'd3;
    localparam [4:0] M_AAD_REQ = 5'd4;
    localparam [4:0] M_AAD_WAIT = 5'd5;
    localparam [4:0] M_AAD_POLY = 5'd6;
    localparam [4:0] M_MSG_CHECK = 5'd7;
    localparam [4:0] M_MSG_KS_REQ = 5'd8;
    localparam [4:0] M_MSG_KS_WAIT = 5'd9;
    localparam [4:0] M_MSG_REQ = 5'd10;
    localparam [4:0] M_MSG_WAIT = 5'd11;
    localparam [4:0] M_MSG_DISP = 5'd12;
    localparam [4:0] M_MSG_WR_WAIT = 5'd13;
    localparam [4:0] M_LEN_POLY = 5'd14;
    localparam [4:0] M_TAG_WAIT = 5'd15;
    localparam [4:0] M_TAG_VERIFY = 5'd16;
    localparam [4:0] M_TAG_VER_WAIT = 5'd17;
    localparam [4:0] M_TAG_WRITE = 5'd18;
    localparam [4:0] M_TAG_WR_WAIT = 5'd19;
    localparam [4:0] M_DONE = 5'd20;

    localparam [1:0] R_IDLE = 2'd0, R_REQ = 2'd1, R_CAP = 2'd2, R_DONE = 2'd3;
    localparam [1:0] W_IDLE = 2'd0, W_WR_REQ = 2'd1, W_DONE = 2'd2;

    reg [255:0] key_cfg;
    reg [95:0]  nonce_cfg;
    reg [31:0]  msg_len_reg, ad_len_reg;
    reg         mode_dec_reg;

    reg [4:0]   main_state, next_main_state;
    reg [1:0]   rd_state, next_rd_state;
    reg [1:0]   wr_state, next_wr_state;

    reg [31:0]  process_pos;
    reg [31:0]  bytes_left;  // [優化] 取代 total_len，消除 32-bit 減法器
    reg [1:0]   chunk_idx;

    reg [511:0] ks_buffer;
    reg [511:0] ks_next_buffer;
    reg         ks_next_valid;
    reg         ks_prefetch_busy;

    reg [255:0] poly_key_reg;
    reg [127:0] tag_buffer;
    reg [31:0]  chacha_counter_reg;

    reg [31:0]  rd_addr;
    reg [4:0]   rd_len;
    reg [2:0]   rd_word_idx;
    reg [127:0] rd_data;
    reg [159:0] raw_rd_buf;
    reg         rd_valid;

    reg [31:0]  wr_addr;
    reg [4:0]   wr_len;
    reg [2:0]   wr_word_idx;
    reg [127:0] wr_buf_reg;
    reg         wr_valid;

    function [31:0] ram_addr_from_byte(input [31:0] byte_addr);
        begin
            if (ADDR_MODE_WORD) ram_addr_from_byte = byte_addr[31:2];
            else ram_addr_from_byte = {byte_addr[31:2], 2'b00};
        end
    endfunction

    // [優化] 直接由 bytes_left 判斷 current_len，無需做減法
    function [4:0] min16(input [31:0] value);
        begin
            min16 = (|value[31:4]) ? 5'd16 : value[4:0];
        end
    endfunction

    function [127:0] mask128(input [4:0] len);
        begin
            case (len)
                5'd0:  mask128 = 128'h00000000000000000000000000000000;
                5'd1:  mask128 = 128'h000000000000000000000000000000ff;
                5'd2:  mask128 = 128'h0000000000000000000000000000ffff;
                5'd3:  mask128 = 128'h00000000000000000000000000ffffff;
                5'd4:  mask128 = 128'h000000000000000000000000ffffffff;
                5'd5:  mask128 = 128'h0000000000000000000000ffffffffff;
                5'd6:  mask128 = 128'h00000000000000000000ffffffffffff;
                5'd7:  mask128 = 128'h000000000000000000ffffffffffffff;
                5'd8:  mask128 = 128'h0000000000000000ffffffffffffffff;
                5'd9:  mask128 = 128'h00000000000000ffffffffffffffffff;
                5'd10: mask128 = 128'h000000000000ffffffffffffffffffff;
                5'd11: mask128 = 128'h0000000000ffffffffffffffffffffff;
                5'd12: mask128 = 128'h00000000ffffffffffffffffffffffff;
                5'd13: mask128 = 128'h000000ffffffffffffffffffffffffff;
                5'd14: mask128 = 128'h0000ffffffffffffffffffffffffffff;
                5'd15: mask128 = 128'h00ffffffffffffffffffffffffffffff;
                5'd16: mask128 = 128'hffffffffffffffffffffffffffffffff;
                default: mask128 = 128'h00000000000000000000000000000000;
            endcase
        end
    endfunction

    // [優化] 產生給 memory write 的 Byte Enable Mask
    function [19:0] get_be_mask(input [4:0] len, input [1:0] offset);
        reg [19:0] base_mask;
        begin
            case (len)
                5'd0:  base_mask = 20'h00000;
                5'd1:  base_mask = 20'h00001;
                5'd2:  base_mask = 20'h00003;
                5'd3:  base_mask = 20'h00007;
                5'd4:  base_mask = 20'h0000F;
                5'd5:  base_mask = 20'h0001F;
                5'd6:  base_mask = 20'h0003F;
                5'd7:  base_mask = 20'h0007F;
                5'd8:  base_mask = 20'h000FF;
                5'd9:  base_mask = 20'h001FF;
                5'd10: base_mask = 20'h003FF;
                5'd11: base_mask = 20'h007FF;
                5'd12: base_mask = 20'h00FFF;
                5'd13: base_mask = 20'h01FFF;
                5'd14: base_mask = 20'h03FFF;
                5'd15: base_mask = 20'h07FFF;
                5'd16: base_mask = 20'h0FFFF;
                default: base_mask = 20'h00000;
            endcase
            get_be_mask = base_mask << offset;
        end
    endfunction

    wire poly_ready_w;
    wire poly_tag_valid_w;
    wire [127:0] poly_tag_w;
    wire chacha_ready_w;
    wire [511:0] chacha_keystream_w;
    
    // [優化] 關鍵路徑縮短，不需用 total_len 減法
    wire [4:0] current_len = min16(bytes_left);

    wire prefetch_from_chunk2_w = (chunk_idx == 2'd2) && (bytes_left > 32'd32);
    wire prefetch_from_chunk3_w = (chunk_idx == 2'd3) && (bytes_left > {27'd0, current_len});

    wire prefetch_start_w = (main_state == M_MSG_WR_WAIT) && wr_valid && !ks_prefetch_busy && !ks_next_valid && (prefetch_from_chunk2_w || prefetch_from_chunk3_w);
    wire chacha_demand_start_w = (main_state == M_INIT_KEY) || ((main_state == M_MSG_KS_REQ) && !ks_prefetch_busy);
    wire chacha_start_w = chacha_demand_start_w || prefetch_start_w;
    wire [31:0] chacha_counter_input_w = (main_state == M_INIT_KEY) ? 32'd0 : chacha_counter_reg;
    wire chacha_msg_ready_w = (main_state == M_MSG_KS_WAIT) && chacha_ready_w;
    wire chacha_prefetch_ready_w = ks_prefetch_busy && chacha_ready_w;

    wire msg_fire_w = (main_state == M_MSG_DISP) && poly_ready_w && (wr_state == W_IDLE);
    wire req_rd_w = (main_state == M_AAD_REQ) || (main_state == M_MSG_REQ) || (main_state == M_TAG_VERIFY);
    wire req_wr_w = msg_fire_w || (main_state == M_TAG_WRITE);

    wire [31:0] rd_addr_w = (main_state == M_TAG_VERIFY) ? (ad_len_reg + msg_len_reg) : (main_state == M_MSG_REQ) ? (ad_len_reg + process_pos) : process_pos;
    wire [4:0]  rd_len_w  = (main_state == M_TAG_VERIFY) ? 5'd16 : current_len;
    wire [31:0] wr_addr_w = (main_state == M_TAG_WRITE) ? msg_len_reg : process_pos;
    wire [4:0]  wr_len_w  = (main_state == M_TAG_WRITE) ? 5'd16 : current_len;
    
    wire [127:0] current_ks = (chunk_idx == 2'd0) ? ks_buffer[127:0] : (chunk_idx == 2'd1) ? ks_buffer[255:128] : (chunk_idx == 2'd2) ? ks_buffer[383:256] : ks_buffer[511:384];

    wire [2:0] rd_total_words = (rd_len > 0) ? (((rd_addr + rd_len - 1) >> 2) - (rd_addr >> 2) + 1) : 3'd0;
    wire [31:0] current_rd_byte_base = (rd_addr & 32'hFFFF_FFFC) + {27'd0, rd_word_idx, 2'b00};

    reg [159:0] raw_rd_buf_next_w;
    always @(*) begin
        raw_rd_buf_next_w = raw_rd_buf;
        case (rd_word_idx)
            3'd0: raw_rd_buf_next_w[31:0]    = Src_RAM_Q;
            3'd1: raw_rd_buf_next_w[63:32]   = Src_RAM_Q;
            3'd2: raw_rd_buf_next_w[95:64]   = Src_RAM_Q;
            3'd3: raw_rd_buf_next_w[127:96]  = Src_RAM_Q;
            3'd4: raw_rd_buf_next_w[159:128] = Src_RAM_Q;
            default: ;
        endcase
    end

    wire [127:0] rd_aligned_w = (raw_rd_buf_next_w >> ({3'd0, rd_addr[1:0]} << 3)) & mask128(rd_len);
    wire [2:0] wr_total_words = (wr_len > 0) ? (((wr_addr + wr_len - 1) >> 2) - (wr_addr >> 2) + 1) : 3'd0;
    wire [31:0] current_wr_byte_base = (wr_addr & 32'hFFFF_FFFC) + {27'd0, wr_word_idx, 2'b00};

    // [優化] Data Path 邏輯層次優化
    wire [127:0] current_len_mask = mask128(current_len);
    wire [127:0] active_data_w = mode_dec_reg ? rd_data : (rd_data ^ current_ks);
    wire [127:0] xor_masked = (rd_data ^ current_ks) & current_len_mask;
    wire [127:0] poly_data_msg = active_data_w & current_len_mask;

    wire [127:0] wr_data_w = (main_state == M_TAG_WRITE) ? tag_buffer : xor_masked;
    wire [127:0] length_block_w = {32'd0, msg_len_reg, 32'd0, ad_len_reg};
    
    wire [127:0] poly_data_w =
        (main_state == M_AAD_POLY) ? (rd_data & current_len_mask) :
        (main_state == M_MSG_DISP) ? poly_data_msg :
        (main_state == M_LEN_POLY) ? length_block_w :
        128'd0;

    wire poly_valid_w = ((main_state == M_AAD_POLY) && poly_ready_w) || msg_fire_w || ((main_state == M_LEN_POLY) && poly_ready_w);
    wire poly_finalize_w = (main_state == M_LEN_POLY);

    assign Src_RAM_en = (rd_state == R_REQ);
    assign Src_RAM_addr = (rd_state == R_REQ) ? ram_addr_from_byte(current_rd_byte_base) : 32'd0;
    assign Src_RAM_we = 1'b0;
    assign Src_RAM_D = 32'd0;

    // ====================================================================
    // [優化] Write Memory Path 完全重構：使用位移器(Shifter)與 LUT 取代加法與比較器
    // ====================================================================
    reg [3:0]  wr_be_w;
    reg [31:0] wr_word_w;
    wire [1:0] wr_offset = wr_addr[1:0];
    
    // 將 128-bit 的 wr_buf_reg 根據 offset (0~3) 位移 0~24 bits，得到 160-bit 暫存結果
    wire [159:0] wr_buf_shifted = {32'd0, wr_buf_reg} << ({6'd0, wr_offset} * 8);
    
    // 獲取 20-bit 的完整 Byte Enable
    wire [19:0] full_wr_be = get_be_mask(wr_len, wr_offset);

    always @(*) begin
        wr_word_w = 32'd0;
        wr_be_w   = 4'd0;
        case (wr_word_idx)
            3'd0: begin wr_word_w = wr_buf_shifted[31:0];    wr_be_w = full_wr_be[3:0];   end
            3'd1: begin wr_word_w = wr_buf_shifted[63:32];   wr_be_w = full_wr_be[7:4];   end
            3'd2: begin wr_word_w = wr_buf_shifted[95:64];   wr_be_w = full_wr_be[11:8];  end
            3'd3: begin wr_word_w = wr_buf_shifted[127:96];  wr_be_w = full_wr_be[15:12]; end
            3'd4: begin wr_word_w = wr_buf_shifted[159:128]; wr_be_w = full_wr_be[19:16]; end
            default: ;
        endcase
    end
    // ====================================================================

    assign Dst_RAM_en = (wr_state == W_WR_REQ);
    assign Dst_RAM_we = (wr_state == W_WR_REQ) ? wr_be_w : 4'b0000;
    assign Dst_RAM_addr = (wr_state == W_WR_REQ) ? ram_addr_from_byte(current_wr_byte_base) : 32'd0;
    assign Dst_RAM_D = (wr_state == W_WR_REQ) ? wr_word_w : 32'd0;

    // Submodules (不變動)
    Chacha20 u_chacha20 (
        .clk       (clk),
        .rst       (rst),
        .start     (chacha_start_w),
        .ready     (chacha_ready_w),
        .key       (key_cfg),
        .nonce     (nonce_cfg),
        .counter   (chacha_counter_input_w),
        .keystream (chacha_keystream_w)
    );
    
    Poly1305 u_poly1305 (
        .clk       (clk),
        .rst       (rst),
        .valid_in  (poly_valid_w),
        .ready_out (poly_ready_w),
        .mac_key   (poly_key_reg),
        .data_in   (poly_data_w),
        .pad_bit   (1'b1),
        .finalize  (poly_finalize_w),
        .mac_tag   (poly_tag_w),
        .tag_valid (poly_tag_valid_w)
    );

    // Config FSM (保持不變)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_cfg <= 256'd0;
            nonce_cfg <= 96'd0;
        end else if (config_we && (main_state == M_IDLE)) begin
            case (config_addr)
                4'd0: key_cfg[255:224] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd1: key_cfg[223:192] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd2: key_cfg[191:160] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd3: key_cfg[159:128] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd4: key_cfg[127:96] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd5: key_cfg[95:64] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd6: key_cfg[63:32] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd7: key_cfg[31:0] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd8: nonce_cfg[95:64] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd9: nonce_cfg[63:32] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                4'd10: nonce_cfg[31:0] <= {config_data[7:0], config_data[15:8], config_data[23:16], config_data[31:24]};
                default: ;
            endcase
        end
    end

    // FSM State Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            main_state <= M_IDLE;
            rd_state <= R_IDLE;
            wr_state <= W_IDLE;
        end else begin
            main_state <= next_main_state;
            rd_state <= next_rd_state;
            wr_state <= next_wr_state;
        end
    end

    // Main FSM Logic (使用 bytes_left 簡化跳轉條件)
    always @(*) begin
        next_main_state = main_state;
        case (main_state)
            M_IDLE: if (start) next_main_state = M_INIT_KEY;
            M_INIT_KEY: next_main_state = M_INIT_WAIT;
            M_INIT_WAIT: if (chacha_ready_w) next_main_state = M_AAD_CHECK;
            M_AAD_CHECK: if (bytes_left != 0) next_main_state = M_AAD_REQ; else next_main_state = M_MSG_CHECK;
            M_AAD_REQ: next_main_state = M_AAD_WAIT;
            M_AAD_WAIT: if (rd_valid) next_main_state = M_AAD_POLY;
            M_AAD_POLY: if (poly_ready_w) next_main_state = M_AAD_CHECK;
            M_MSG_CHECK: begin
                if (bytes_left != 0) begin
                    if (chunk_idx == 2'd0) begin
                        if (ks_next_valid) next_main_state = M_MSG_REQ;
                        else if (ks_prefetch_busy) next_main_state = M_MSG_KS_WAIT;
                        else next_main_state = M_MSG_KS_REQ;
                    end else begin
                        next_main_state = M_MSG_REQ;
                    end
                end else begin
                    next_main_state = M_LEN_POLY;
                end
            end
            M_MSG_KS_REQ: next_main_state = M_MSG_KS_WAIT;
            M_MSG_KS_WAIT: if (chacha_ready_w) next_main_state = M_MSG_REQ;
            M_MSG_REQ: next_main_state = M_MSG_WAIT;
            M_MSG_WAIT: if (rd_valid) next_main_state = M_MSG_DISP;
            M_MSG_DISP: if (msg_fire_w) next_main_state = M_MSG_WR_WAIT;
            M_MSG_WR_WAIT: if (wr_valid) next_main_state = M_MSG_CHECK;
            M_LEN_POLY: if (poly_ready_w) next_main_state = M_TAG_WAIT;
            M_TAG_WAIT: if (poly_tag_valid_w) begin if (mode_dec_reg) next_main_state = M_TAG_VERIFY; else next_main_state = M_TAG_WRITE; end
            M_TAG_VERIFY: next_main_state = M_TAG_VER_WAIT;
            M_TAG_VER_WAIT: if (rd_valid) next_main_state = M_DONE;
            M_TAG_WRITE: next_main_state = M_TAG_WR_WAIT;
            M_TAG_WR_WAIT: if (wr_valid) next_main_state = M_DONE;
            M_DONE: next_main_state = M_IDLE;
            default: next_main_state = M_IDLE;
        endcase
    end

    // Read FSM & Write FSM (保持不變)
    always @(*) begin
        next_rd_state = rd_state;
        case (rd_state)
            R_IDLE: next_rd_state = (req_rd_w && rd_len_w > 0) ? R_REQ : R_IDLE;
            R_REQ: next_rd_state = R_CAP;
            R_CAP: next_rd_state = (rd_word_idx + 3'd1 == rd_total_words) ? R_DONE : R_REQ;
            R_DONE: next_rd_state = R_IDLE;
            default: next_rd_state = R_IDLE;
        endcase
    end

    always @(*) begin
        next_wr_state = wr_state;
        case (wr_state)
            W_IDLE: next_wr_state = (req_wr_w && wr_len_w > 0) ? W_WR_REQ : W_IDLE;
            W_WR_REQ: next_wr_state = (wr_word_idx + 3'd1 == wr_total_words) ? W_DONE : W_WR_REQ;
            W_DONE: next_wr_state = W_IDLE;
            default: next_wr_state = W_IDLE;
        endcase
    end

    // 狀態存儲暫存器
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            msg_len_reg <= 32'd0;
            ad_len_reg <= 32'd0;
            mode_dec_reg <= 1'b0;
            done <= 1'b0;
            mac_error <= 1'b0;
        end else begin
            done <= 1'b0; 
            if (main_state == M_IDLE && start) begin
                msg_len_reg <= msg_length;
                ad_len_reg <= ad_length;
                mode_dec_reg <= mode_decrypt;
                mac_error <= 1'b0;
            end else if (main_state == M_TAG_VER_WAIT && rd_valid) begin
                mac_error <= (rd_data != tag_buffer);
            end else if (main_state == M_DONE) begin
                done <= 1'b1;
            end
        end
    end

    // Process Tracker (同步更新 process_pos 與 bytes_left)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            process_pos <= 32'd0;
            bytes_left <= 32'd0;
            chunk_idx <= 2'd0;
            chacha_counter_reg <= 32'd0;
        end else begin
            if (main_state == M_IDLE && start) begin
                process_pos <= 32'd0;
                chunk_idx <= 2'd0;
                chacha_counter_reg <= 32'd0;
            end else if (main_state == M_INIT_WAIT && chacha_ready_w) begin
                process_pos <= 32'd0;
                bytes_left <= ad_len_reg;
            end else if (main_state == M_AAD_CHECK && bytes_left == 0) begin
                process_pos <= 32'd0;
                bytes_left <= msg_len_reg;
                chacha_counter_reg <= 32'd1;
                chunk_idx <= 2'd0;
            end else if (main_state == M_AAD_POLY && poly_ready_w) begin
                process_pos <= process_pos + {27'd0, current_len};
                bytes_left <= bytes_left - {27'd0, current_len};
            end else if (main_state == M_MSG_KS_WAIT && chacha_ready_w) begin
                chacha_counter_reg <= chacha_counter_reg + 32'd1;
            end else if (chacha_prefetch_ready_w) begin
                chacha_counter_reg <= chacha_counter_reg + 32'd1;
            end else if ((main_state == M_MSG_CHECK) &&
                         (bytes_left != 0) &&
                         (chunk_idx == 2'd0) &&
                         ks_next_valid) begin
                chunk_idx <= 2'd0;
            end else if (main_state == M_MSG_WR_WAIT && wr_valid) begin
                process_pos <= process_pos + {27'd0, current_len};
                bytes_left <= bytes_left - {27'd0, current_len};
                chunk_idx <= chunk_idx + 2'd1;
            end
        end
    end

    // Read Path
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_addr <= 32'd0;
            rd_len <= 5'd0;
            rd_word_idx <= 3'd0;
            rd_data <= 128'd0;
            raw_rd_buf <= 160'd0;
            rd_valid <= 1'b0;
        end else begin
            rd_valid <= 1'b0;
            if (rd_state == R_IDLE) begin
                if (req_rd_w && rd_len_w > 0) begin
                    rd_addr <= rd_addr_w;
                    rd_len <= rd_len_w;
                    rd_word_idx <= 3'd0;
                    rd_data <= 128'd0;
                    raw_rd_buf <= 160'd0;
                end
            end else if (rd_state == R_CAP) begin
                raw_rd_buf <= raw_rd_buf_next_w;
                if (rd_word_idx + 3'd1 == rd_total_words) begin
                    rd_data <= rd_aligned_w;
                    rd_valid <= 1'b1;
                end else begin
                    rd_word_idx <= rd_word_idx + 3'd1;
                end
            end
        end
    end

    // Write Path
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_addr <= 32'd0;
            wr_len <= 5'd0;
            wr_word_idx <= 3'd0;
            wr_buf_reg <= 128'd0;
            wr_valid <= 1'b0;
        end else begin
            wr_valid <= 1'b0;
            if (wr_state == W_IDLE) begin
                if (req_wr_w && wr_len_w > 0) begin
                    wr_addr <= wr_addr_w;
                    wr_len <= wr_len_w;
                    wr_word_idx <= 3'd0;
                    wr_buf_reg <= wr_data_w;
                end
            end else if (wr_state == W_WR_REQ) begin
                if (wr_word_idx + 3'd1 == wr_total_words) wr_valid <= 1'b1;
                else wr_word_idx <= wr_word_idx + 3'd1;
            end
        end
    end

    // ChaCha Key/Tag Tracking
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            poly_key_reg <= 256'd0;
            ks_buffer <= 512'd0;
            ks_next_buffer <= 512'd0;
            ks_next_valid <= 1'b0;
            ks_prefetch_busy <= 1'b0;
            tag_buffer <= 128'd0;
        end else begin
            if (main_state == M_IDLE && start) begin
                ks_next_buffer <= 512'd0;
                ks_next_valid <= 1'b0;
                ks_prefetch_busy <= 1'b0;
            end

            if (prefetch_start_w) begin
                ks_prefetch_busy <= 1'b1;
            end

            if (main_state == M_INIT_WAIT && chacha_ready_w) begin
                poly_key_reg <= chacha_keystream_w[255:0];
            end else if (main_state == M_MSG_KS_WAIT && chacha_ready_w) begin
                ks_buffer <= chacha_keystream_w;
                ks_prefetch_busy <= 1'b0;
                ks_next_valid <= 1'b0;
            end else if (chacha_prefetch_ready_w) begin
                ks_next_buffer <= chacha_keystream_w;
                ks_next_valid <= 1'b1;
                ks_prefetch_busy <= 1'b0;
            end else if ((main_state == M_MSG_CHECK) &&
                         (bytes_left != 0) &&
                         (chunk_idx == 2'd0) &&
                         ks_next_valid) begin
                ks_buffer <= ks_next_buffer;
                ks_next_valid <= 1'b0;
            end else if (main_state == M_TAG_WAIT && poly_tag_valid_w) begin
                tag_buffer <= poly_tag_w;
            end
        end
    end

endmodule