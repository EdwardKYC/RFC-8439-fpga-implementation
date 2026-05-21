import struct
import os
import argparse

# ==========================================
# 預設參數配置區
# ==========================================
CONSTANT = b"expand 32-byte k" 
DEFAULT_KEY_HEX = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
DEFAULT_NONCE_HEX = "000000090000004a00000000"

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

def chacha20_process_bytes(key: bytes, nonce: bytes, data: bytes, start_counter=0) -> bytes:
    output = bytearray()
    num_blocks = (len(data) + 63) // 64
    
    for i in range(num_blocks):
        counter = start_counter + i
        keystream = chacha20_block(key, counter, nonce, CONSTANT)
        block_data = data[i*64 : (i+1)*64]
        
        for j in range(len(block_data)):
            output.append(block_data[j] ^ keystream[j])
            
    return bytes(output)

# ==========================================
# 功能 1：加解密檔案
# ==========================================
def process_file(key_hex, nonce_hex, mode, input_file, output_file, initial_counter=0):
    if not os.path.exists(input_file):
        print(f"[錯誤] 找不到輸入檔案: '{input_file}'")
        return

    mode_name = "加密" if mode == "encrypt" else "解密"
    print(f"\n[*] 模式: {mode_name} | 初始 Counter: {initial_counter}")
    
    try:
        key = bytes.fromhex(key_hex)
        nonce = bytes.fromhex(nonce_hex)
        
        data_bytes = bytearray()
        with open(input_file, 'r') as f_in:
            for line in f_in:
                line = line.strip()
                if not line: continue
                chunk = bytes.fromhex(line)
                data_bytes.extend(chunk[::-1])

        if len(data_bytes) == 0:
            print("[錯誤] 輸入檔案是空的！")
            return

        processed_bytes = chacha20_process_bytes(key, nonce, bytes(data_bytes), start_counter=initial_counter)

        with open(output_file, 'w') as f_out:
            for j in range(0, len(processed_bytes), 4):
                chunk = processed_bytes[j:j+4]
                if len(chunk) < 4:
                    chunk += b'\x00' * (4 - len(chunk))
                f_out.write(chunk[::-1].hex() + "\n")
                
        print(f"[成功] {mode_name}處理完成，共 {len(data_bytes)} bytes，輸出至: {output_file}\n")
        
    except Exception as e:
        print(f"[錯誤] 執行發生問題: {e}")

# ==========================================
# 功能 2：純粹生成 Keystream (Golden Pattern)
# ==========================================
def generate_keystream(key_hex, nonce_hex, length_bytes, output_file, initial_counter=0):
    print(f"\n[*] 模式: 獨立生成 Keystream (Golden Pattern)")
    print(f"[*] 預期長度: {length_bytes} bytes | 初始 Counter: {initial_counter}")
    
    try:
        key = bytes.fromhex(key_hex)
        nonce = bytes.fromhex(nonce_hex)
        
        if len(key) != 32: raise ValueError("Key 必須是 32 Bytes (64 個 16 進位字元)")
        if len(nonce) != 12: raise ValueError("Nonce 必須是 12 Bytes (24 個 16 進位字元)")

        ks_bytes = bytearray()
        num_blocks = (length_bytes + 63) // 64
        
        # 逐塊生成 Keystream
        for i in range(num_blocks):
            counter = initial_counter + i
            block = chacha20_block(key, counter, nonce, CONSTANT)
            ks_bytes.extend(block)
            
        # 裁切到使用者指定得確切長度
        ks_bytes = ks_bytes[:length_bytes]

        # 輸出為 Verilog 可讀取格式 (每行 32-bit, Little-Endian)
        with open(output_file, 'w') as f_out:
            for j in range(0, len(ks_bytes), 4):
                chunk = ks_bytes[j:j+4]
                if len(chunk) < 4:
                    chunk += b'\x00' * (4 - len(chunk)) # 不足 4 Bytes 補零
                f_out.write(chunk[::-1].hex() + "\n")
                
        print(f"[成功] Keystream 生成完成！已輸出至: {output_file}\n")

    except Exception as e:
        print(f"[錯誤] 生成 Keystream 時發生問題: {e}")


# ==========================================
# 執行介面
# ==========================================
def interactive_menu():
    print("=" * 50)
    print("   ChaCha20 硬體驗證專用加解密工具")
    print("=" * 50)
    print("1. 加密模式 (Encrypt Data)")
    print("2. 解密模式 (Decrypt Data)")
    print("3. 生成密碼流 (Generate Keystream Golden)")
    print("-" * 50)
    
    choice = input("請選擇模式 (輸入 1, 2, 或 3): ").strip()
    if choice not in ['1', '2', '3']:
        return

    # 共同設定
    key_input = input(f"請輸入 Key (Hex) [預設: {DEFAULT_KEY_HEX[:8]}...]: ").strip()
    key_hex = key_input if key_input else DEFAULT_KEY_HEX
    
    nonce_input = input(f"請輸入 Nonce (Hex) [預設: {DEFAULT_NONCE_HEX}]: ").strip()
    nonce_hex = nonce_input if nonce_input else DEFAULT_NONCE_HEX
    
    counter_input = input("初始 Counter [預設 0]: ").strip()
    initial_counter = int(counter_input) if counter_input else 0

    # 依照模式分歧
    if choice in ['1', '2']:
        mode = "encrypt" if choice == '1' else "decrypt"
        input_file = input("來源檔名 (例 input.txt): ").strip()
        default_output = "ciphertext.txt" if mode == "encrypt" else "plaintext.txt"
        output_file = input(f"輸出檔名 [預設 {default_output}]: ").strip() or default_output
        process_file(key_hex, nonce_hex, mode, input_file, output_file, initial_counter)
        
    elif choice == '3':
        len_input = input("請輸入預期生成的 Keystream 長度 (Bytes) [預設 64]: ").strip()
        length_bytes = int(len_input) if len_input else 64
        default_output = "chacha_keystream.txt"
        output_file = input(f"輸出檔名 [預設 {default_output}]: ").strip() or default_output
        generate_keystream(key_hex, nonce_hex, length_bytes, output_file, initial_counter)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ChaCha20 硬體驗證腳本")
    parser.add_argument("-m", "--mode", choices=["encrypt", "decrypt", "keystream"], help="執行模式")
    parser.add_argument("-k", "--key", default=DEFAULT_KEY_HEX, help="32-byte Key (Hex 字串)")
    parser.add_argument("-n", "--nonce", default=DEFAULT_NONCE_HEX, help="12-byte Nonce (Hex 字串)")
    parser.add_argument("-c", "--counter", type=int, default=0, help="初始 Counter")
    
    # 資料處理專用
    parser.add_argument("-i", "--input", help="輸入檔案 (Encrypt/Decrypt 模式必填)")
    # Keystream 專用
    parser.add_argument("-l", "--length", type=int, default=64, help="生成 Keystream 的長度 (Bytes)")
    
    parser.add_argument("-o", "--output", help="輸出檔案名稱")
    
    args = parser.parse_args()

    # 如果有帶參數就走 CLI 模式，否則走互動介面
    if args.mode:
        output_file = args.output
        if args.mode in ["encrypt", "decrypt"]:
            if not args.input:
                print("[錯誤] 加解密模式必須提供輸入檔案 (-i)")
            else:
                if not output_file: output_file = "ciphertext.txt" if args.mode == "encrypt" else "plaintext.txt"
                process_file(args.key, args.nonce, args.mode, args.input, output_file, args.counter)
        elif args.mode == "keystream":
            if not output_file: output_file = "chacha_keystream.txt"
            generate_keystream(args.key, args.nonce, args.length, output_file, args.counter)
    else:
        interactive_menu()