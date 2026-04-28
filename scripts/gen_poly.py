import struct
import random

# ==========================================
# 參數配置區 (可自行修改)
# ==========================================
TEST_CASE_COUNT = 100
MAX_BYTES = 65536

def clamp_r(r_bytes):
    """對 r 進行 Clamp (清空特定 bits，這是規範要求的安全性設計)"""
    r = bytearray(r_bytes)
    r[3] &= 15; r[7] &= 15; r[11] &= 15; r[15] &= 15
    r[4] &= 252; r[8] &= 252; r[12] &= 252
    return bytes(r)

def poly1305_mac(key, msg):
    # 1. 切割 256-bit Key 為 r 和 s (各 16 bytes)
    r_bytes = clamp_r(key[0:16])
    s_bytes = key[16:32]
    
    # 將 bytes 轉成大整數 (Little-Endian，硬體常規作法)
    r = int.from_bytes(r_bytes, 'little')
    s = int.from_bytes(s_bytes, 'little')
    
    # 2. 初始化 Accumulator (a) 和 Prime (p = 2^130 - 5)
    a = 0
    p = (1 << 130) - 5
    
    # 3. 處理每個 16-byte (128-bit) 的資料區塊
    for i in range(0, len(msg), 16):
        block = msg[i:i+16]
        
        # 將資料轉整數 (Little-Endian)
        block_int = int.from_bytes(block, 'little')
        
        # 加上 Pad Bit (0x01)，加在當前 block 長度的最高位元之上
        block_int |= (1 << (len(block) * 8))
        
        # 核心運算：累加後乘上 r，再對 p 取模
        a = (a + block_int)
        a = (a * r) % p
        
    # 4. 最後加上 s，並只取低 128-bit
    a = (a + s) & ((1 << 128) - 1)
    
    # 轉回 16 bytes 的 bytes 型態 (Little-Endian)
    return a.to_bytes(16, 'little')

# ==========================================
# 資料生成與寫檔 (128-bit Packing)
# ==========================================
def generate_test_data():
    with open("poly_test.txt", "w") as f_test, open("poly_answer.txt", "w") as f_ans:
        test_cases = []
        
        # 產生 100 筆隨機測資
        for _ in range(TEST_CASE_COUNT):
            rand_key = bytes([random.randint(0, 255) for _ in range(32)])
            
            msg_blocks = random.randint(1, MAX_BYTES // 16)
            msg_len = msg_blocks * 16 
            
            rand_msg = bytes([random.randint(0, 255) for _ in range(msg_len)])
            test_cases.append((rand_key, rand_msg))

        total_blocks = 0
        
        # 開始寫入檔案
        for key, msg in test_cases:
            tag = poly1305_mac(key, msg)
            msg_len = len(msg)
            
            # --- 寫入 poly_test.txt ---
            # 為了讓 Verilog $readmemh 讀入後 Byte[7:0] 剛好是對應的第 0 個 Byte，
            # 我們統一轉成 int 後，以 128-bit (32 hex) 的格式輸出。
            
            # 1. 寫入 Key_r (128-bit)
            key_r_int = int.from_bytes(key[0:16], 'little')
            f_test.write(f"{key_r_int:032x}\n")
            
            # 2. 寫入 Key_s (128-bit)
            key_s_int = int.from_bytes(key[16:32], 'little')
            f_test.write(f"{key_s_int:032x}\n")
            
            # 3. 寫入這筆 Message 的總長度 (128-bit)
            # 這樣 Testbench 裡的 FSM 就知道接下來要讀幾個 Block
            f_test.write(f"{msg_len:032x}\n")
            
            # 4. 寫入 Message Blocks (128-bit per line)
            for i in range(0, msg_len, 16):
                block = msg[i:i+16]
                block_int = int.from_bytes(block, 'little')
                f_test.write(f"{block_int:032x}\n")
                total_blocks += 1
                
            # --- 寫入 poly_answer.txt ---
            # 寫入正確的 Tag (128-bit)
            tag_int = int.from_bytes(tag, 'little')
            f_ans.write(f"{tag_int:032x}\n")

    print(f"[成功] 已生成 128-bit 格式測資 (共 {TEST_CASE_COUNT} 個 Test Cases)")
    print(f"       總計產生 {total_blocks} 個 Message Blocks")

if __name__ == "__main__":
    generate_test_data()