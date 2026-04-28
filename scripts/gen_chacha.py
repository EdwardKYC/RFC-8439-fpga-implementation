import struct

# ==========================================
# 參數配置區 (嚴格遵循 RFC 8439 規範)
# ==========================================
CONSTANT = b"expand 32-byte k" 
KEY_HEX = "0000000000000000000000000000000000000000000000000000000000000000"
KEY = bytes.fromhex(KEY_HEX)
NONCE_HEX = "000000000000000000000002"
NONCE = bytes.fromhex(NONCE_HEX)

# ==========================================
# 目標設定
# 1 block = 512 bits (64 bytes) = 16 個 32-bit words
# 若要總共 65536 bits，需要 65536 / 512 = 128 輪
# ==========================================
NUM_BLOCKS = 128 # 依據 65536 bits 需求設定

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
    for _ in range(10): 
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

    # 將運算結果與初始狀態相加
    for i in range(16):
        state[i] = (state[i] + working_state[i]) & 0xffffffff

    return struct.pack('<16I', *state)

# ==========================================
# 資料生成與寫檔 (純 Keystream 輸出)
# ==========================================
def generate_keystream_only():
    print("========== ChaCha20 Keystream Generator ==========")
    print(f"Key   : {KEY_HEX}")
    print(f"Nonce : {NONCE_HEX}")
    print(f"Start Counter : 0")
    print(f"Total Blocks  : {NUM_BLOCKS}")
    print("==================================================")
    
    total_words = 0
    with open("chacha_keystream.txt", "w") as f_ks:
        # 嚴格從 Counter = 0 開始執行到 NUM_BLOCKS - 1
        for counter in range(NUM_BLOCKS):
            keystream = chacha20_block(KEY, counter, NONCE, CONSTANT)
            
            # 將 64 bytes 的 keystream 拆解為 16 個 32-bit word 寫入 (Little-Endian)
            for j in range(0, 64, 4):
                ks_word = struct.unpack_from('<I', keystream, j)[0]
                f_ks.write(f"{ks_word:08x}\n")
                total_words += 1

    total_bits = total_words * 32
    print(f"[成功] 已生成純 Keystream 並寫入 chacha_keystream.txt")
    print(f"       共產生 {NUM_BLOCKS} 個 Blocks，計 {total_words} 行 (Words)，總共 {total_bits} bits。")

if __name__ == "__main__":
    generate_keystream_only()