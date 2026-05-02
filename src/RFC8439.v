module RFC8439 #(
    parameter ADDR_MODE_WORD = 1
)(
    input  wire        clk,
    input  wire        rst,

    input  wire        start,        // 啟動訊號
    input  wire        mode_decrypt, // 0: 加密模式, 1: 解密模式
    output reg         done,         // 運算完成通知
    output reg         mac_error,    // 解密時的 MAC 驗證失敗警告

    input  wire [31:0] msg_length,   // 明文/密文的總 Byte 數
    input  wire [31:0] ad_length,    // 附加關聯資料(AD)的總 Byte 數

    input  wire [3:0]  config_addr,  // 決定現在寫入的是 Key[0~7] 還是 Nonce[0~2]
    input  wire [31:0] config_data,  // 32-bit 配置資料
    input  wire        config_we,    // 配置資料寫入致能

    output wire [31:0] Src_RAM_addr,
    output wire        Src_RAM_en,
    output wire        Src_RAM_we,
    output wire [31:0] Src_RAM_D,
    input  wire [31:0] Src_RAM_Q,

    output wire [31:0] Dst_RAM_addr,
    output wire        Dst_RAM_en,
    output wire        Dst_RAM_we,
    output wire [31:0] Dst_RAM_D,
    input  wire [31:0] Dst_RAM_Q
);
    localparam [5:0] S_IDLE             = 6'd0;
    localparam [5:0] S_CHACHA_KEY_START = 6'd1;
    localparam [5:0] S_CHACHA_KEY_WAIT  = 6'd2;
    localparam [5:0] S_AAD_PREP         = 6'd3;
    localparam [5:0] S_SRC_RD_REQ       = 6'd4;
    localparam [5:0] S_SRC_RD_CAP       = 6'd5;
    localparam [5:0] S_AAD_POLY         = 6'd6;
    localparam [5:0] S_AAD_POLY_WAIT    = 6'd7;
    localparam [5:0] S_DATA_PREP        = 6'd8;
    localparam [5:0] S_CHACHA_START     = 6'd9;
    localparam [5:0] S_CHACHA_WAIT      = 6'd10;
    localparam [5:0] S_DATA_RD_PREP     = 6'd11;
    localparam [5:0] S_DATA_XOR         = 6'd12;
    localparam [5:0] S_DATA_WR_PREP     = 6'd13;
    localparam [5:0] S_DST_RD_REQ       = 6'd14;
    localparam [5:0] S_DST_RD_CAP       = 6'd15;
    localparam [5:0] S_DST_WR           = 6'd16;
    localparam [5:0] S_DATA_POLY        = 6'd17;
    localparam [5:0] S_DATA_POLY_WAIT   = 6'd18;
    localparam [5:0] S_LEN_POLY         = 6'd19;
    localparam [5:0] S_LEN_WAIT         = 6'd20;
    localparam [5:0] S_TAG_WR_PREP      = 6'd21;
    localparam [5:0] S_TAG_RD_PREP      = 6'd22;
    localparam [5:0] S_TAG_COMPARE      = 6'd23;
    localparam [5:0] S_DONE             = 6'd24;

    localparam [1:0] RD_AAD = 2'd0;
    localparam [1:0] RD_MSG = 2'd1;
    localparam [1:0] RD_TAG = 2'd2;
    localparam [1:0] WR_MSG = 2'd0;
    localparam [1:0] WR_TAG = 2'd1;

    // 內部暫存器與線路
    reg [5:0]   state;
    reg [5:0]   next_state;

    reg [255:0] key_cfg;
    reg [95:0]  nonce_cfg;
    reg [255:0] key_work;
    reg [95:0]  nonce_work;

    reg [31:0]  msg_len_reg;
    reg [31:0]  ad_len_reg;
    reg         mode_dec_reg;
    reg [31:0]  aad_pos;
    reg [31:0]  data_pos;

    reg [31:0]  src_base;
    reg [4:0]   src_len;
    reg [4:0]   rd_idx;
    reg [1:0]   rd_kind;
    reg [1:0]   src_sel_r;

    reg [31:0]  dst_base;
    reg [4:0]   dst_len;
    reg [4:0]   wr_idx;
    reg [1:0]   wr_kind;
    reg [1:0]   dst_sel_r;
    reg [31:0]  dst_word_tmp;

    reg [127:0] block_buf;
    reg [127:0] poly_block;
    reg [127:0] out_block;
    reg [127:0] write_block;
    reg [255:0] poly_key_reg;
    reg [511:0] ks_reg;
    reg [31:0]  chacha_counter_reg;

    integer bi;

    // 模組介面線路
    wire chacha_start_w;
    wire chacha_ready_w;
    wire [511:0] chacha_keystream_w;
    wire poly_valid_w;
    wire poly_finalize_w;
    wire poly_ready_w;
    wire poly_tag_valid_w;
    wire [127:0] poly_data_w;
    wire [127:0] poly_tag_w;
    wire [127:0] length_block_w;
    wire [31:0]  src_byte_addr_w;
    wire [31:0]  dst_byte_addr_w;
    wire [31:0]  dst_write_word_w;
    wire [7:0]   dst_write_byte_w;

    // ==========================================
    // 函數與連續賦值 (Combinational Logic)
    // ==========================================
    function [31:0] ram_addr_from_byte(input [31:0] byte_addr);
        begin
            if (ADDR_MODE_WORD) ram_addr_from_byte = byte_addr[31:2];
            else                ram_addr_from_byte = {byte_addr[31:2], 2'b00};
        end
    endfunction

    function [7:0] get_byte32(input [31:0] word, input [1:0] sel);
        begin
            case (sel)
                2'd0: get_byte32 = word[7:0];
                2'd1: get_byte32 = word[15:8];
                2'd2: get_byte32 = word[23:16];
                2'd3: get_byte32 = word[31:24];
                default: get_byte32 = 8'd0;
            endcase
        end
    endfunction

    function [31:0] set_byte32(input [31:0] word, input [1:0] sel, input [7:0] value);
        begin
            set_byte32 = word;
            case (sel)
                2'd0: set_byte32[7:0]   = value;
                2'd1: set_byte32[15:8]  = value;
                2'd2: set_byte32[23:16] = value;
                2'd3: set_byte32[31:24] = value;
            endcase
        end
    endfunction

    function [7:0] get_byte128(input [127:0] word, input [4:0] idx);
        begin
            get_byte128 = word[idx*8 +: 8];
        end
    endfunction

    function [7:0] get_byte512(input [511:0] word, input [5:0] idx);
        begin
            get_byte512 = word[idx*8 +: 8];
        end
    endfunction

    function [4:0] min16(input [31:0] value);
        begin
            min16 = (value >= 32'd16) ? 5'd16 : value[4:0];
        end
    endfunction

    assign length_block_w = {32'd0, msg_len_reg, 32'd0, ad_len_reg};
    assign chacha_start_w = (state == S_CHACHA_KEY_START) || (state == S_CHACHA_START);

    assign poly_valid_w = ((state == S_AAD_POLY)  || (state == S_DATA_POLY) || (state == S_LEN_POLY))  && poly_ready_w;
    assign poly_finalize_w = (state == S_LEN_POLY);
    assign poly_data_w = (state == S_LEN_POLY) ? length_block_w : (state == S_AAD_POLY) ? block_buf : poly_block;

    assign src_byte_addr_w = src_base + {27'd0, rd_idx};
    assign dst_byte_addr_w = dst_base + {27'd0, wr_idx};
    assign dst_write_byte_w = get_byte128(write_block, wr_idx);
    assign dst_write_word_w = set_byte32(dst_word_tmp, dst_sel_r, dst_write_byte_w);

    assign Src_RAM_en   = (state == S_SRC_RD_REQ);
    assign Src_RAM_we   = 1'b0;
    assign Src_RAM_addr = (state == S_SRC_RD_REQ) ? ram_addr_from_byte(src_byte_addr_w) : 32'd0;
    assign Src_RAM_D    = 32'd0;

    assign Dst_RAM_en   = (state == S_DST_RD_REQ) || (state == S_DST_WR);
    assign Dst_RAM_we   = (state == S_DST_WR);
    assign Dst_RAM_addr = ((state == S_DST_RD_REQ) || (state == S_DST_WR))? ram_addr_from_byte(dst_byte_addr_w) : 32'd0;
    assign Dst_RAM_D    = (state == S_DST_WR) ? dst_write_word_w : 32'd0;

    Chacha20 u_chacha20 (
        .clk(clk),
        .rst(rst),
        .start(chacha_start_w),
        .ready(chacha_ready_w),
        .key(key_work),
        .nonce(nonce_work),
        .counter(chacha_counter_reg),
        .keystream(chacha_keystream_w)
    );

    Poly1305 u_poly1305 (
        .clk(clk),
        .rst(rst),
        .valid_in(poly_valid_w),
        .ready_out(poly_ready_w),
        .mac_key(poly_key_reg),
        .data_in(poly_data_w),
        .pad_bit(1'b1),
        .finalize(poly_finalize_w),
        .mac_tag(poly_tag_w),
        .tag_valid(poly_tag_valid_w)
    );

    // Config Register 寫入邏輯
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_cfg <= 256'd0;
            nonce_cfg <= 96'd0;
        end else if (config_we && (state == S_IDLE)) begin
            case (config_addr)
                4'd0:  key_cfg[255:224] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd1:  key_cfg[223:192] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd2:  key_cfg[191:160] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd3:  key_cfg[159:128] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd4:  key_cfg[127:96] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd5:  key_cfg[95:64] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd6:  key_cfg[63:32] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd7:  key_cfg[31:0] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd8:  nonce_cfg[95:64] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd9:  nonce_cfg[63:32] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                4'd10: nonce_cfg[31:0] <= {
                    config_data[7:0],
                    config_data[15:8],
                    config_data[23:16],
                    config_data[31:24]
                };
                default: ;
            endcase
        end
    end

    // [Block 1] FSM 狀態暫存器 (State Register)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // [Block 2] FSM 下一個狀態邏輯 (Next State Combinational Logic)
    always @(*) begin
        next_state = state; // Default behavior
        case (state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_CHACHA_KEY_START;
                end
            end
            S_CHACHA_KEY_START: begin
                next_state = S_CHACHA_KEY_WAIT;
            end
            S_CHACHA_KEY_WAIT: begin
                if (chacha_ready_w) begin
                    next_state = S_AAD_PREP;
                end
            end
            S_AAD_PREP: begin
                if (aad_pos < ad_len_reg) begin
                    next_state = S_SRC_RD_REQ;
                end else begin
                    next_state = S_DATA_PREP;
                end
            end
            S_SRC_RD_REQ: begin
                next_state = S_SRC_RD_CAP;
            end
            S_SRC_RD_CAP: begin
                if ((rd_idx + 5'd1) >= src_len) begin
                    case (rd_kind)
                        RD_AAD: next_state = S_AAD_POLY;
                        RD_MSG: next_state = S_DATA_XOR;
                        RD_TAG: next_state = S_TAG_COMPARE;
                        default: next_state = S_IDLE;
                    endcase
                end else begin
                    next_state = S_SRC_RD_REQ;
                end
            end
            S_AAD_POLY: begin
                if (poly_ready_w) begin
                    next_state = S_AAD_POLY_WAIT;
                end
            end
            S_AAD_POLY_WAIT: begin
                if (poly_ready_w) begin
                    next_state = S_AAD_PREP;
                end
            end
            S_DATA_PREP: begin
                if (data_pos < msg_len_reg) begin
                    if (data_pos[5:0] == 6'd0) begin
                        next_state = S_CHACHA_START;
                    end else begin
                        next_state = S_DATA_RD_PREP;
                    end
                end else begin
                    next_state = S_LEN_POLY;
                end
            end
            S_CHACHA_START: begin
                next_state = S_CHACHA_WAIT;
            end
            S_CHACHA_WAIT: begin
                if (chacha_ready_w) begin
                    next_state = S_DATA_RD_PREP;
                end
            end
            S_DATA_RD_PREP: begin
                next_state = S_SRC_RD_REQ;
            end
            S_DATA_XOR: begin
                next_state = S_DATA_WR_PREP;
            end
            S_DATA_WR_PREP: begin
                next_state = S_DST_RD_REQ;
            end
            S_DST_RD_REQ: begin
                next_state = S_DST_RD_CAP;
            end
            S_DST_RD_CAP: begin
                next_state = S_DST_WR;
            end
            S_DST_WR: begin
                if ((wr_idx + 5'd1) >= dst_len) begin
                    if (wr_kind == WR_MSG) begin
                        next_state = S_DATA_POLY;
                    end else begin
                        next_state = S_DONE;
                    end
                end else begin
                    next_state = S_DST_RD_REQ;
                end
            end
            S_DATA_POLY: begin
                if (poly_ready_w) begin
                    next_state = S_DATA_POLY_WAIT;
                end
            end
            S_DATA_POLY_WAIT: begin
                if (poly_ready_w) begin
                    next_state = S_DATA_PREP;
                end
            end
            S_LEN_POLY: begin
                if (poly_ready_w) begin
                    next_state = S_LEN_WAIT;
                end
            end
            S_LEN_WAIT: begin
                if (poly_tag_valid_w) begin
                    next_state = mode_dec_reg ? S_TAG_RD_PREP : S_TAG_WR_PREP;
                end
            end
            S_TAG_WR_PREP: begin
                next_state = S_DST_RD_REQ;
            end
            S_TAG_RD_PREP: begin
                next_state = S_SRC_RD_REQ;
            end
            S_TAG_COMPARE: begin
                next_state = S_DONE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // [Block 3] 全局配置與控制 (Global Config & Control Registers)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_work      <= 256'd0;
            nonce_work    <= 96'd0;
            msg_len_reg  <= 32'd0;
            ad_len_reg   <= 32'd0;
            mode_dec_reg <= 1'b0;
            done         <= 1'b0;
            mac_error    <= 1'b0;
        end else begin
            done <= 1'b0; // Default pulse
            if (state == S_IDLE && start) begin
                key_work <= key_cfg;
                nonce_work <= nonce_cfg;
                msg_len_reg <= msg_length;
                ad_len_reg <= ad_length;
                mode_dec_reg <= mode_decrypt;
                mac_error <= 1'b0;
            end else if (state == S_TAG_COMPARE) begin
                mac_error <= (block_buf != write_block);
            end else if (state == S_DONE) begin
                done <= 1'b1;
            end
        end
    end

    // [Block 4] 記憶體位址與計數器 (Global Pointers)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            aad_pos             <= 32'd0;
            data_pos            <= 32'd0;
            chacha_counter_reg  <= 32'd0;
        end else begin
            if (state == S_IDLE && start) begin
                aad_pos             <= 32'd0;
                data_pos            <= 32'd0;
                chacha_counter_reg  <= 32'd0;
            end else if (state == S_AAD_POLY && poly_ready_w) begin
                aad_pos <= aad_pos + {27'd0, src_len};
            end else if (state == S_DATA_PREP && (data_pos < msg_len_reg) && (data_pos[5:0] == 6'd0)) begin
                chacha_counter_reg <= 32'd1 + {6'd0, data_pos[31:6]};
            end else if (state == S_DATA_POLY && poly_ready_w) begin
                data_pos <= data_pos + {27'd0, src_len};
            end
        end
    end

    // [Block 5] 來源端 RAM 控制 (Source RAM Controller)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            src_base <= 32'd0;
            src_len  <= 5'd0;
            rd_idx   <= 5'd0;
            rd_kind   <= RD_AAD;
            src_sel_r <= 2'd0;
        end else begin
            if (state == S_AAD_PREP && aad_pos < ad_len_reg) begin
                src_base <= aad_pos;
                src_len  <= min16(ad_len_reg - aad_pos);
                rd_idx  <= 5'd0;
                rd_kind <= RD_AAD;
            end else if (state == S_DATA_RD_PREP) begin
                src_base <= ad_len_reg + data_pos;
                src_len  <= min16(msg_len_reg - data_pos);
                rd_idx  <= 5'd0;
                rd_kind <= RD_MSG;
            end else if (state == S_TAG_RD_PREP) begin
                src_base <= ad_len_reg + msg_len_reg;
                src_len  <= 5'd16;
                rd_idx  <= 5'd0;
                rd_kind <= RD_TAG;
            end else if (state == S_SRC_RD_REQ) begin
                src_sel_r <= src_byte_addr_w[1:0];
            end else if (state == S_SRC_RD_CAP) begin
                rd_idx <= ((rd_idx + 5'd1) >= src_len) ? 5'd0 : rd_idx + 5'd1;
            end
        end
    end

    // [Block 6] 目的端 RAM 控制 (Destination RAM Controller)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dst_base <= 32'd0;
            dst_len  <= 5'd0;
            wr_idx   <= 5'd0;
            wr_kind      <= WR_MSG;
            dst_sel_r    <= 2'd0;
            dst_word_tmp <= 32'd0;
        end else begin
            if (state == S_DATA_WR_PREP) begin
                dst_base <= data_pos;
                dst_len  <= src_len;
                wr_idx  <= 5'd0;
                wr_kind <= WR_MSG;
            end else if (state == S_TAG_WR_PREP) begin
                dst_base <= msg_len_reg;
                dst_len  <= 5'd16;
                wr_idx  <= 5'd0;
                wr_kind <= WR_TAG;
            end else if (state == S_DST_RD_REQ) begin
                dst_sel_r <= dst_byte_addr_w[1:0];
            end else if (state == S_DST_RD_CAP) begin
                dst_word_tmp <= Dst_RAM_Q;
            end else if (state == S_DST_WR) begin
                wr_idx <= ((wr_idx + 5'd1) >= dst_len) ? 5'd0 : wr_idx + 5'd1;
            end
        end
    end

    // [Block 7] 密碼學資料暫存與運算 (Crypto Data Buffers & Logic)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            block_buf  <= 128'd0;
            poly_block <= 128'd0;
            out_block  <= 128'd0;
            write_block  <= 128'd0;
            poly_key_reg <= 256'd0;
            ks_reg       <= 512'd0;
        end else begin
            if (state == S_CHACHA_KEY_WAIT && chacha_ready_w) begin
                poly_key_reg <= chacha_keystream_w[255:0];
            end else if ((state == S_AAD_PREP && aad_pos < ad_len_reg) || state == S_DATA_RD_PREP) begin
                block_buf  <= 128'd0;
            poly_block <= 128'd0;
            out_block  <= 128'd0;
            end else if (state == S_TAG_RD_PREP) begin
                block_buf <= 128'd0;
            end else if (state == S_SRC_RD_CAP) begin
                block_buf[rd_idx*8 +: 8] <= get_byte32(Src_RAM_Q, src_sel_r);
            end else if (state == S_AAD_POLY) begin
                poly_block <= block_buf;
            end else if (state == S_CHACHA_WAIT && chacha_ready_w) begin
                ks_reg <= chacha_keystream_w;
            end else if (state == S_DATA_XOR) begin
                for (bi = 0; bi < 16; bi = bi + 1) begin
                    if (bi < src_len) begin
                        out_block[bi*8 +: 8] <= get_byte128(block_buf, bi[4:0]) ^ get_byte512(ks_reg, data_pos[5:0] + bi[5:0]);
                        if (mode_dec_reg) begin
                            poly_block[bi*8 +: 8] <= get_byte128(block_buf, bi[4:0]);
                        end else begin
                            poly_block[bi*8 +: 8] <= get_byte128(block_buf, bi[4:0]) ^ get_byte512(ks_reg, data_pos[5:0] + bi[5:0]);
                        end
                    end else begin
                        out_block[bi*8 +: 8] <= 8'd0;
                        poly_block[bi*8 +: 8] <= 8'd0;
                    end
                end
            end else if (state == S_DATA_WR_PREP) begin
                write_block <= out_block;
            end else if (state == S_LEN_WAIT && poly_tag_valid_w) begin
                write_block <= poly_tag_w;
            end
        end
    end

endmodule