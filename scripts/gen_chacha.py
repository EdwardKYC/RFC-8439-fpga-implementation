import struct
import random

# ==========================================
# 參數配置區 (可自行修改)
# ==========================================
CONSTANT = b"expand 32-byte k" 
KEY = bytes.fromhex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
NONCE = bytes.fromhex("000000000000000000000000")
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
    state[0:4]   = struct.unpack('<4I', constant)
    state[4:12]  = struct.unpack('<8I', key)
    state[12]    = counter
    state[13:16] = struct.unpack('<3I', nonce)

    working_state = list(state)
    for _ in range(10): # 20 rounds
        quarter_round(working_state, 0, 4,  8, 12)
        quarter_round(working_state, 1, 5,  9, 13)
        quarter_round(working_state, 2, 6, 10, 14)
        quarter_round(working_state, 3, 7, 11, 15)
        quarter_round(working_state, 0, 5, 10, 15)
        quarter_round(working_state, 1, 6, 11, 12)
        quarter_round(working_state, 2, 7,  8, 13)
        quarter_round(working_state, 3, 4,  9, 14)

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
    
    # 產生 0-255 的隨機像素
    pixels = [random.randint(0, 255) for _ in range(total_bytes)]
    
    # 將 pixels 打包為 32-bit words (Little-Endian)
    words_in = []
    for i in range(words_count):
        idx = i * 4
        # Packing: [Byte3][Byte2][Byte1][Byte0]
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
            keystream = chacha20_block(KEY, counter, NONCE, CONSTANT)
            counter += 1
            
            # 處理 XOR
            block_len = min(64, total_bytes - i)
            for j in range(0, block_len, 4):
                # 從 keystream 提取 32-bit
                ks_word = struct.unpack_from('<I', keystream, j)[0]
                # 從明文提取 32-bit
                pt_word = words_in[(i+j)//4]
                ct_word = pt_word ^ ks_word
                f_ans.write(f"{ct_word:08x}\n")

    print(f"[成功] 已生成 32-bit 格式測資 (共 {words_count} 行)")

if __name__ == "__main__":
    generate_test_data()