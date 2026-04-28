module RFC8439 (
    input  wire        clk,
    input  wire        rst,

    input  wire        start,        // 啟動訊號 (取代單純的 en)
    input  wire        mode_decrypt, // 0: 加密模式, 1: 解密模式
    output reg         done,         // 運算完成通知
    output reg         mac_error,    // 解密時的 MAC 驗證失敗警告

    input  wire [31:0] msg_length,   // 明文/密文的總 Byte 數
    input  wire [31:0] ad_length,    // 附加關聯資料(AD)的總 Byte 數

    input  wire [3:0]  config_addr,  // 決定現在寫入的是 Key[0~7] 還是 Nonce[0~2]
    input  wire [31:0] config_data,  // 32-bit 配置資料
    input  wire        config_we,    // 配置資料寫入致能 (Write Enable)

    output wire [31:0] Src_RAM_addr,
    output wire        Src_RAM_en,   
    output wire        Src_RAM_we,   // Write Enable
    output wire [31:0] Src_RAM_D,    // 寫入資料 (通常來源端只讀不寫，可保留)
    input  wire [31:0] Src_RAM_Q,    // 讀出資料

    output wire [31:0] Dst_RAM_addr,
    output wire        Dst_RAM_en,   
    output wire        Dst_RAM_we,   // Write Enable
    output wire [31:0] Dst_RAM_D,    // 寫入資料
    input  wire [31:0] Dst_RAM_Q     // 讀出資料 (通常目的端只寫不讀)
);
    localparam ST_IDLE          = 4'd0;
    localparam ST_GEN_MAC_KEY   = 4'd1;  // 產生 Poly1305 MAC Key (Counter = 0)
    localparam ST_PROCESS_AAD   = 4'd2;  // 處理 AAD (預留擴充)
    localparam ST_CHACHA_RUN    = 4'd3;  // 跑 ChaCha20 產生 64 Bytes 密鑰流
    localparam ST_RAM_XOR       = 4'd4;  // 從 RAM 讀明文，做 XOR，存密文 (暫以直接餵食替代)
    localparam ST_POLY_FEED     = 4'd5;  // 將 64 Bytes 密文分 4 次餵給 Poly1305
    localparam ST_FINALIZE_LEN  = 4'd6;  // 餵食 ad_length 與 msg_length
    localparam ST_WAIT_TAG      = 4'd7;  // 等待 Poly1305 輸出最終 Tag
    localparam ST_DONE          = 4'd8;  // 完成狀態
    reg [3:0] state, next_state;

    reg [255:0]  key_reg;
    reg [95:0]   nonce_reg;
    reg [31:0]   chacha_counter;
    reg [511:0]  ciphertext_buf;  // 暫存處理好的 64 Bytes 密文，準備餵給 Poly
    reg [1:0]    chunk_cnt;       // 記錄 Poly 餵食進度 (0~3)
    reg          poly_is_busy;    // Poly 交握狀態旗標
    reg [31:0]  processed_bytes;
    // --- ChaCha ---
    reg          chacha_start;
    wire         chacha_ready;
    wire [511:0] chacha_keystream;

    Chacha20 chacha_inst (
        .clk(clk),
        .rst(rst),
        .start(chacha_start),
        .ready(chacha_ready),
        .key(key_reg),
        .nonce(nonce_reg),
        .counter(chacha_counter),
        .keystream(chacha_keystream)
    );

    // --- Poly1305 ---
    reg          poly_valid_in;
    wire         poly_ready_out;
    reg  [255:0] poly_mac_key;
    reg  [127:0] poly_data_in;
    reg          poly_pad_bit;
    reg          poly_finalize;
    wire [127:0] poly_mac_tag;
    wire         poly_tag_valid;

    Poly1305 poly_inst (
        .clk(clk),
        .rst(rst),
        .valid_in(poly_valid_in),
        .ready_out(poly_ready_out),
        .mac_key(poly_mac_key),
        .data_in(poly_data_in),
        .pad_bit(poly_pad_bit),
        .finalize(poly_finalize),
        .mac_tag(poly_mac_tag),
        .tag_valid(poly_tag_valid)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_reg   <= 256'd0;
            nonce_reg <= 96'd0;
        end else if (config_we) begin
            case (config_addr)
                4'd0: key_reg[31:0]   <= config_data;
                4'd1: key_reg[63:32]  <= config_data;
                4'd2: key_reg[95:64]  <= config_data;
                4'd3: key_reg[127:96] <= config_data;
                4'd4: key_reg[159:128]<= config_data;
                4'd5: key_reg[191:160]<= config_data;
                4'd6: key_reg[223:192]<= config_data;
                4'd7: key_reg[255:224]<= config_data;
                4'd8: nonce_reg[31:0] <= config_data;
                4'd9: nonce_reg[63:32]<= config_data;
                4'd10:nonce_reg[95:64]<= config_data;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) state <= ST_IDLE;
        else state <= next_state;
    end

    always @(*) begin
        if (rst) next_state = ST_IDLE;
        else begin
            case (state)
                ST_IDLE:
                    next_state = (start) ? ST_GEN_MAC_KEY : ST_IDLE;
                ST_GEN_MAC_KEY:
                    next_state = (chacha_ready) ? ST_CHACHA_RUN : ST_GEN_MAC_KEY;
                ST_CHACHA_RUN:
                    next_state = (chacha_ready) ? ST_POLY_FEED : ST_CHACHA_RUN;
                // Poly 餵食交握：餵完 4 塊 (chunk_cnt == 3) 且 Poly 告知 ready 時結束
                ST_POLY_FEED:
                    if (chunk_cnt == 2'd3 && poly_ready_out) begin
                        // 判斷：加上這回合的 64 Bytes 後，是否已經達到或超過總長度？
                        if (processed_bytes + 32'd64 >= msg_length) begin
                            next_state = ST_FINALIZE_LEN; // 算完了，進入最後長度收尾
                        end else begin
                            next_state = ST_CHACHA_RUN;   // 還沒算完，回去叫 ChaCha 產下一塊
                        end
                    end else begin
                        next_state = ST_POLY_FEED;
                    end
                ST_FINALIZE_LEN:
                    // 這裡送出最後一塊長度資訊，等待 Poly 收下
                    next_state = (poly_ready_out) ? ST_WAIT_TAG : ST_FINALIZE_LEN;
                ST_WAIT_TAG:
                    next_state = (poly_tag_valid) ? ST_DONE : ST_WAIT_TAG;
                ST_DONE:
                    next_state = ST_IDLE;
                default: next_state = ST_IDLE;
            endcase
        end
    end

    // ==========================================
    // 6. Datapath 控制邏輯
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            chacha_start   <= 1'b0;
            chacha_counter <= 32'd0;

            poly_valid_in  <= 1'b0;
            poly_data_in   <= 128'd0;
            poly_pad_bit   <= 1'b0;
            poly_finalize  <= 1'b0;
            poly_mac_key   <= 256'd0;

            poly_is_busy   <= 1'b0;
            chunk_cnt      <= 2'd0;
            ciphertext_buf <= 512'd0;

            done           <= 1'b0;
            mac_error      <= 1'b0;

            // 預設 RAM 控制訊號為 0
            Src_RAM_en <= 1'b0; Src_RAM_we <= 1'b0; Src_RAM_addr <= 32'd0; Src_RAM_D <= 32'd0;
            Dst_RAM_en <= 1'b0; Dst_RAM_we <= 1'b0; Dst_RAM_addr <= 32'd0; Dst_RAM_D <= 32'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    done <= 1'b0;
                    mac_error <= 1'b0;
                    poly_finalize <= 1'b0;
                    processed_bytes <= 32'd0;
                    if (start) begin
                        chacha_counter <= 32'd0; // Counter 0 產生 Poly Key
                        chacha_start <= 1'b1;
                    end
                end

                ST_GEN_MAC_KEY: begin
                    chacha_start <= 1'b0;
                    if (chacha_ready) begin
                        poly_mac_key <= chacha_keystream[255:0];
                        chacha_counter <= 32'd1; // 準備產生真正的資料密鑰流
                        chacha_start <= 1'b1;
                    end
                end

                ST_CHACHA_RUN: begin
                    chacha_start <= 1'b0;
                    if (chacha_ready) begin
                        // TODO: 未來這裡要改成讀 RAM 做 XOR。
                        // 目前暫時將 keystream 當作 ciphertext 直接餵給 Poly 測試
                        ciphertext_buf <= chacha_keystream;
                        chunk_cnt <= 2'd0;
                        poly_is_busy <= 1'b0;
                    end
                end

                ST_POLY_FEED: begin
                    if (!poly_is_busy) begin
                        // Poly 閒置，開始餵食
                        poly_valid_in <= 1'b1;
                        poly_is_busy  <= 1'b1;
                        poly_pad_bit  <= 1'b1; // 一般資料塊，pad_bit 為 1
                        poly_finalize <= 1'b0;

                        // 4-to-1 MUX
                        case (chunk_cnt)
                            2'd0: poly_data_in <= ciphertext_buf[127:0];
                            2'd1: poly_data_in <= ciphertext_buf[255:128];
                            2'd2: poly_data_in <= ciphertext_buf[383:256];
                            2'd3: poly_data_in <= ciphertext_buf[511:384];
                        endcase
                    end else begin
                        poly_valid_in <= 1'b0; // 只拉高一拍
                        if (poly_ready_out) begin
                            poly_is_busy <= 1'b0; // Poly 算完這塊了
                            if (chunk_cnt != 2'd3) begin
                                chunk_cnt <= chunk_cnt + 2'd1;
                            end else begin
                                processed_bytes <= processed_bytes + 32'd64;
                                if (processed_bytes + 32'd64 < msg_length) begin
                                    chacha_counter <= chacha_counter + 32'd1;
                                    chacha_start   <= 1'b1;
                                end
                            end
                        end
                    end
                end

                ST_FINALIZE_LEN: begin
                    if (!poly_is_busy) begin
                        poly_valid_in <= 1'b1;
                        poly_is_busy  <= 1'b1;
                        poly_pad_bit  <= 1'b0; // 長度區塊不需要 pad_bit
                        poly_finalize <= 1'b1; // 告訴 Poly 這是最後一塊了

                        // 組合長度區塊: [63:0] ad_length * 8, [127:64] msg_length * 8
                        // 注意位元單位轉換 (Bytes -> Bits 所以要左移 3)
                        poly_data_in <= { {32'd0, msg_length} << 3, {32'd0, ad_length} << 3 };
                    end else begin
                        poly_valid_in <= 1'b0;
                        if (poly_ready_out) begin
                            poly_is_busy <= 1'b0;
                        end
                    end
                end

                ST_WAIT_TAG: begin
                    poly_finalize <= 1'b0;
                    if (poly_tag_valid) begin
                        // 此時 poly_mac_tag 已經準備好了
                        // 如果是解密模式，未來可以在這裡比較 Tag 並拉高 mac_error
                    end
                end

                ST_DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule