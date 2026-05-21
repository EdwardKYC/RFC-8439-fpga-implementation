import struct
import os
import argparse

# ==========================================
# 參數配置區 (嚴格遵循 RFC 8439 規範)
# ==========================================
CONSTANT = b"expand 32-byte k" 
KEY_HEX = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
KEY = bytes.fromhex(KEY_HEX)
NONCE_HEX = "000000090000004a00000000"
NONCE = bytes.fromhex(NONCE_HEX)

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
# 核心 XOR 處理 (串流加密特性：加解密共用邏輯)
# ==========================================
def chacha20_process_bytes(data: bytes, start_counter=0) -> bytes:
    output = bytearray()
    num_blocks = (len(data) + 63) // 64
    
    for i in range(num_blocks):
        counter = start_counter + i
        keystream = chacha20_block(KEY, counter, NONCE, CONSTANT)
        block_data = data[i*64 : (i+1)*64]
        
        for j in range(len(block_data)):
            output.append(block_data[j] ^ keystream[j])
            
    return bytes(output)

# ==========================================
# 檔案讀寫介面 (Hex 文字檔格式，符合 Little-Endian 行為)
# ==========================================
def process_file(mode, input_file, output_file):
    """
    讀取 Hex 格式的測資，進行加/解密，並以相同 Hex 格式匯出。
    保留 Little-Endian 記憶體順序。
    """
    if not os.path.exists(input_file):
        print(f"[錯誤] 找不到輸入檔案: '{input_file}'")
        return

    mode_name = "加密" if mode == "encrypt" else "解密"
    print(f"\n[*] 開始執行 {mode_name} 模式...")
    print(f"[*] 讀取檔案: {input_file}")

    try:
        # 1. 讀入資料：將多行 hex 字串串接並轉為真實位元組
        with open(input_file, 'r') as f_in:
            hex_string = "".join(line.strip() for line in f_in)
        
        data_bytes = bytes.fromhex(hex_string)
        
        # 2. 進行 XOR 運算 (加解密邏輯完全相同)
        processed_bytes = chacha20_process_bytes(data_bytes, start_counter=0)
        
        # 3. 匯出資料：每 4 bytes 轉為 Hex 寫入一行
        with open(output_file, 'w') as f_out:
            for j in range(0, len(processed_bytes), 4):
                chunk = processed_bytes[j:j+4]
                f_out.write(f"{chunk.hex()}\n")
                
        print(f"[成功] {mode_name} 完成！")
        print(f"       共處理 {len(data_bytes)} bytes。")
        print(f"       已匯出至: {output_file}\n")
        
    except ValueError as e:
        print(f"[錯誤] 檔案內容格式錯誤！請確保 '{input_file}' 內容為純 Hex 格式。")

# ==========================================
# 執行介面
# ==========================================
def interactive_menu():
    print("=" * 45)
    print("      ChaCha20 加解密工具 (Hex Little-Endian)")
    print("=" * 45)
    print("1. 加密模式 (Encrypt)")
    print("2. 解密模式 (Decrypt)")
    
    choice = input("請選擇模式 (輸入 1 或 2): ").strip()
    if choice not in ['1', '2']:
        print("選擇無效，結束程式。")
        return

    mode = "encrypt" if choice == '1' else "decrypt"
    
    input_file = input("請輸入來源檔案名稱 (例如 input.txt): ").strip()
    default_output = "ciphertext.txt" if mode == "encrypt" else "plaintext.txt"
    output_file = input(f"請輸入輸出檔案名稱 [直接按 Enter 預設為 {default_output}]: ").strip()
    
    if not output_file:
        output_file = default_output

    process_file(mode, input_file, output_file)

if __name__ == "__main__":
    # 使用 argparse 支援 Command Line 參數操作
    parser = argparse.ArgumentParser(description="ChaCha20 Little-Endian Hex 檔案加解密工具")
    parser.add_argument("-m", "--mode", choices=["encrypt", "decrypt"], help="指定模式: encrypt 或 decrypt")
    parser.add_argument("-i", "--input", help="輸入檔案路徑")
    parser.add_argument("-o", "--output", help="輸出檔案路徑")
    
    args = parser.parse_args()

    # 如果使用者有在終端機輸入完整參數，就直接執行；否則進入互動式選單
    if args.mode and args.input and args.output:
        process_file(args.mode, args.input, args.output)
    else:
        interactive_menu()