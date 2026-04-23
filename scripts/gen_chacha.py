import struct
import random

# ==========================================
# 參數配置區 (嚴格遵循 RFC 8439 規範)
# ==========================================
# Constant: "expand 32-byte k" (對應 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574)
CONSTANT = b"expand 32-byte k" 

# Key: 32 bytes (256 bits)
KEY_HEX = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
KEY = bytes.fromhex(KEY_HEX)

# Nonce: 12 bytes (96 bits) - 已更新為指定的 RFC 8439 測試值
NONCE_HEX = "000000090000004a00000000"
NONCE = bytes.fromhex(NONCE_HEX)

# Initial Counter: 
# Counter 0 保留給 Poly1305 生成 MAC Key (r, s)
# Counter 1 開始用於生成明文/密文加密用的密鑰流 (Keystream)
INITIAL_COUNTER = 1

# ==========================================
# ChaCha20 核心演算法
# ==========================================
def rotl(x, n):
    return ((x << n) & 0xffffffff) | (x >> (32 - n))

def quarter_round(x, a, b, c, d):
    x[a] = (x[a] + x[b]) & 0xffffffff; x[d] = rotl(x[d] ^ x[a], 16)
    x[c] = (x[c] + x[d]) & 0xffffffff; x[b] = rotl(x[b] ^ x[c], 12)
    x[a] = (x[a] + x[b]) & 0xffffffff; x[d] = rotl(x[d] ^ x[a],  8)
    x[c] = (x[c] + x[d]) & 0xffffffff; x[b] = rotl(x[b] ^ x[c],  7)

def chacha20_block(key, counter, nonce, constant):
    state = [0] * 16
    # < 代表 Little-Endian，I 代表 32-bit Unsigned Integer
    state[0:4]   = struct.unpack('<4I', constant)
    state[4:12]  = struct.unpack('<8I', key)
    state[12]    = counter
    state[13:16] = struct.unpack('<3I', nonce)

    working_state = list(state)
    for _ in range(10): # 20 rounds (10 column rounds + 10 diagonal rounds)
        # Column rounds
        quarter_round(working_state, 0, 4,  8, 12)
        quarter_round(working_state, 1, 5,  9, 13)
        quarter_round(working_state, 2, 6, 10, 14)
        quarter_round(working_state, 3, 7, 11, 15)
        # Diagonal rounds
        quarter_round(working_state, 0, 5, 10, 15)
        quarter_round(working_state, 1, 6, 11, 12)
        quarter_round(working_state, 2, 7,  8, 13)
        quarter_round(working_state, 3, 4,  9, 14)

    # 將運算結果與初始狀態相加 (避免可逆)
    for i in range(16):
        state[i] = (state[i] + working_state[i]) & 0xffffffff

    return struct.pack('<16I', *state)

# ==========================================
# 資料生成與寫檔 (32-bit Packing)
# ==========================================
def generate_test_data():
    img_width = 256
    img_height = 256
    total_bytes = img_width * img_height
    words_count = total_bytes // 4
    
    print("========== ChaCha20 Test Vector Generator ==========")
    print(f"Key   : {KEY_HEX}")
    print(f"Nonce : {NONCE_HEX}")
    print(f"Start Counter : {INITIAL_COUNTER}")
    print("====================================================")
    
    # 產生 0-255 的隨機像素
    pixels = [random.randint(0, 255) for _ in range(total_bytes)]
    
    # 將 pixels 打包為 32-bit words (Little-Endian)
    words_in = []
    for i in range(words_count):
        idx = i * 4
        # Packing: [Pixel 3][Pixel 2][Pixel 1][Pixel 0]
        word = (pixels[idx+3] << 24) | (pixels[idx+2] << 16) | (pixels[idx+1] << 8) | pixels[idx]
        words_in.append(word)

    # 寫入測試檔
    with open("chacha_test.txt", "w") as f_test:
        for w in words_in:
            f_test.write(f"{w:08x}\n")
            
    # 進行加密並寫入 Golden Answer
    with open("chacha_answer.txt", "w") as f_ans:
        counter = INITIAL_COUNTER
        for i in range(0, total_bytes, 64):
            # 產生 64 bytes (512 bits) 的密鑰流
            keystream = chacha20_block(KEY, counter, NONCE, CONSTANT)
            counter += 1
            
            # 處理 XOR
            block_len = min(64, total_bytes - i)
            for j in range(0, block_len, 4):
                # 從 keystream 提取 32-bit (Little-Endian)
                ks_word = struct.unpack_from('<I', keystream, j)[0]
                # 從明文提取 32-bit
                pt_word = words_in[(i+j)//4]
                # 密文 = 明文 XOR 密鑰流
                ct_word = pt_word ^ ks_word
                f_ans.write(f"{ct_word:08x}\n")

    print(f"[成功] 已生成 32-bit 格式測資與標準答案 (共 {words_count} 行)")

if __name__ == "__main__":
    generate_test_data()