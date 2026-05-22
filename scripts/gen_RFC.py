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
# Poly1305 核心演算法 (用於生成 Tag)
# ==========================================
def poly1305_mac(msg: bytes, key: bytes) -> bytes:
    r = int.from_bytes(key[0:16], 'little')
    r = r & 0x0ffffffc0ffffffc0ffffffc0fffffff
    s = int.from_bytes(key[16:32], 'little')
    
    a = 0
    p = (1 << 130) - 5
    
    for i in range(0, len(msg), 16):
        block = msg[i:i+16]
        block += b'\x01'
        n = int.from_bytes(block, 'little')
        a += n
        a = (a * r) % p
        
    a = (a + s) & ((1 << 128) - 1)
    return a.to_bytes(16, 'little')

# ==========================================
# 輔助寫入工具 (32-bit Little Endian 記憶體格式)
# ==========================================
def write_verilog_hex(filename, byte_data):
    with open(filename, 'w') as f_out:
        for j in range(0, len(byte_data), 4):
            chunk = byte_data[j:j+4]
            if len(chunk) < 4:
                chunk += b'\x00' * (4 - len(chunk))
            f_out.write(chunk[::-1].hex() + "\n")

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
        write_verilog_hex(output_file, processed_bytes)
                
        print(f"[成功] {mode_name}處理完成，共 {len(data_bytes)} bytes，輸出至: {output_file}\n")
        
    except Exception as e:
        print(f"[錯誤] 執行發生問題: {e}")

# ==========================================
# 功能 2：純粹生成 Keystream
# ==========================================
def generate_keystream(key_hex, nonce_hex, length_bytes, output_file, initial_counter=0):
    print(f"\n[*] 模式: 獨立生成 Keystream (Golden Pattern)")
    print(f"[*] 預期長度: {length_bytes} bytes | 初始 Counter: {initial_counter}")
    
    try:
        key = bytes.fromhex(key_hex)
        nonce = bytes.fromhex(nonce_hex)
        
        if len(key) != 32: raise ValueError("Key 必須是 32 Bytes")
        if len(nonce) != 12: raise ValueError("Nonce 必須是 12 Bytes")

        ks_bytes = bytearray()
        num_blocks = (length_bytes + 63) // 64
        
        for i in range(num_blocks):
            counter = initial_counter + i
            block = chacha20_block(key, counter, nonce, CONSTANT)
            ks_bytes.extend(block)
            
        ks_bytes = ks_bytes[:length_bytes]
        write_verilog_hex(output_file, ks_bytes)
                
        print(f"[成功] Keystream 生成完成！已輸出至: {output_file}\n")

    except Exception as e:
        print(f"[錯誤] 生成 Keystream 時發生問題: {e}")

# ==========================================
# 功能 4：生成 RFC8439 完整 AEAD 測試 RAM 檔
# ==========================================
def generate_aead_testcases(key_hex, nonce_hex, aad_hex, pt_hex, prefix=""):
    print(f"\n[*] 模式: 生成 RFC8439 AEAD 完整記憶體測資 (Encrypt & Decrypt)")
    
    try:
        key = bytes.fromhex(key_hex)
        nonce = bytes.fromhex(nonce_hex)
        aad = bytes.fromhex(aad_hex) if aad_hex else b''
        plaintext = bytes.fromhex(pt_hex)
        
        if len(key) != 32: raise ValueError("Key 必須是 32 Bytes")
        if len(nonce) != 12: raise ValueError("Nonce 必須是 12 Bytes")

        # 1. 生成 Poly1305 Key (Counter = 0)
        otk = chacha20_block(key, 0, nonce, CONSTANT)
        poly_key = otk[:32]

        # 2. 生成 Ciphertext (RFC8439 加密從 Counter = 1 開始)
        ciphertext = chacha20_process_bytes(key, nonce, plaintext, start_counter=1)

        # 3. 準備 MAC Payload 並計算 Tag
        aad_pad_len = (16 - (len(aad) % 16)) % 16
        aad_pad = b'\x00' * aad_pad_len
        
        ct_pad_len = (16 - (len(ciphertext) % 16)) % 16
        ct_pad = b'\x00' * ct_pad_len
        
        # MAC Payload = AAD + pad(AAD) + CT + pad(CT) + len(AAD)_64 + len(CT)_64
        mac_msg = aad + aad_pad + ciphertext + ct_pad + struct.pack('<Q', len(aad)) + struct.pack('<Q', len(ciphertext))
        tag = poly1305_mac(mac_msg, poly_key)

        # ==========================================
        # 依照你的規範組裝 RAM 內容 (加上硬體對齊的 4-byte Padding)
        # ==========================================
        hw_fixed_pad = b'\x00\x00\x00\x00' # 硬體要求的 4 Byte Padding Zero

        # 加密模式 (Encrypt)
        # SrcRAM_enc = [key][nonce][AAD][aad_pad][padding 4B][plaintext]
        # DstRAM_enc = [ciphertext][tag]
        enc_src = key + nonce + aad + aad_pad + hw_fixed_pad + plaintext
        enc_dst = ciphertext + tag

        # 解密模式 (Decrypt)
        # SrcRAM_dec = [key][nonce][AAD][aad_pad][padding 4B][ciphertext][tag]
        # DstRAM_dec = [plaintext]
        dec_src = key + nonce + aad + aad_pad + hw_fixed_pad + ciphertext + tag
        dec_dst = plaintext

        # 寫入檔案
        write_verilog_hex(f"{prefix}Src_RAM_enc.txt", enc_src)
        write_verilog_hex(f"{prefix}Dst_RAM_enc.txt", enc_dst)
        write_verilog_hex(f"{prefix}Src_RAM_dec.txt", dec_src)
        write_verilog_hex(f"{prefix}Dst_RAM_dec.txt", dec_dst)

        print("[成功] 完美生成 4 份 AEAD 記憶體測資檔案！(已補上 4Byte Padding Zero)")
        print(f" └─ 加密測試檔: {prefix}Src_RAM_enc.txt, {prefix}Dst_RAM_enc.txt")
        print(f" └─ 解密測試檔: {prefix}Src_RAM_dec.txt, {prefix}Dst_RAM_dec.txt")
        print(f"[*] 提示: 此次明文長度為 {len(plaintext)} Bytes，生成的 Tag 為: {tag.hex()}")

    except Exception as e:
        print(f"[錯誤] AEAD 生成失敗: {e}")

# ==========================================
# 執行介面
# ==========================================
def interactive_menu():
    print("=" * 60)
    print("  RFC8439 (ChaCha20-Poly1305) 硬體驗證專用加解密工具")
    print("=" * 60)
    print("1. 單純加密模式 (Encrypt Data)")
    print("2. 單純解密模式 (Decrypt Data)")
    print("3. 生成密碼流 (Generate Keystream Golden)")
    print("4. 生成完整 AEAD 記憶體測資檔 (Src/Dst RAM Layout) <含 4B Padding>")
    print("-" * 60)
    
    choice = input("請選擇模式 (1, 2, 3, 4): ").strip()
    if choice not in ['1', '2', '3', '4']:
        return

    # 共同設定
    key_input = input(f"請輸入 Key (Hex) [預設: {DEFAULT_KEY_HEX[:8]}...]: ").strip()
    key_hex = key_input if key_input else DEFAULT_KEY_HEX
    
    nonce_input = input(f"請輸入 Nonce (Hex) [預設: {DEFAULT_NONCE_HEX}]: ").strip()
    nonce_hex = nonce_input if nonce_input else DEFAULT_NONCE_HEX
    
    if choice in ['1', '2', '3']:
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

    elif choice == '4':
        aad_hex = input("請輸入 AAD (Hex字串) [預設: 無]: ").strip()
        
        pt_input = input("請輸入 明文 (Hex字串) 或 讀取檔名 (.txt): ").strip()
        pt_hex = ""
        if os.path.exists(pt_input):
            with open(pt_input, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line:
                        chunk = bytes.fromhex(line)
                        pt_hex += chunk[::-1].hex()
        else:
            pt_hex = pt_input if pt_input else "00112233445566778899aabbccddeeff"
            
        prefix = input("請輸入檔案前綴 (例 test1_ ，可留空): ").strip()
        generate_aead_testcases(key_hex, nonce_hex, aad_hex, pt_hex, prefix)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="RFC8439 硬體驗證腳本")
    parser.add_argument("-m", "--mode", choices=["encrypt", "decrypt", "keystream", "aead"], help="執行模式")
    parser.add_argument("-k", "--key", default=DEFAULT_KEY_HEX, help="32-byte Key (Hex)")
    parser.add_argument("-n", "--nonce", default=DEFAULT_NONCE_HEX, help="12-byte Nonce (Hex)")
    parser.add_argument("-c", "--counter", type=int, default=0, help="初始 Counter")
    
    parser.add_argument("-i", "--input", help="輸入檔案 (或 AEAD 模式的明文 Hex)")
    parser.add_argument("-a", "--aad", default="", help="AAD Hex (AEAD 模式用)")
    parser.add_argument("-l", "--length", type=int, default=64, help="長度")
    parser.add_argument("-o", "--output", help="輸出檔案/前綴")
    
    args = parser.parse_args()

    if args.mode:
        if args.mode == "aead":
            generate_aead_testcases(args.key, args.nonce, args.aad, args.input, args.output or "")
        elif args.mode in ["encrypt", "decrypt"]:
            out = args.output or ("ciphertext.txt" if args.mode == "encrypt" else "plaintext.txt")
            process_file(args.key, args.nonce, args.mode, args.input, out, args.counter)
        elif args.mode == "keystream":
            out = args.output or "chacha_keystream.txt"
            generate_keystream(args.key, args.nonce, args.length, out, args.counter)
    else:
        interactive_menu()