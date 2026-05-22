import struct
import statistics
import time
from pathlib import Path


# ============================================================
# 使用者設定區
# 直接改這裡，不需要下 command line 參數
# ============================================================

TESTCASE_DIR = Path(".")

SRC_RAM_ENC_FILE = "Src_RAM_enc.txt"
DST_RAM_ENC_FILE = "Dst_RAM_enc.txt"
SRC_RAM_DEC_FILE = "Src_RAM_dec.txt"
DST_RAM_DEC_FILE = "Dst_RAM_dec.txt"

AAD_LEN = 12
MSG_LEN = 114

BENCH_ROUNDS = 100

RUN_ENCRYPT = True
RUN_DECRYPT = True

TAG_LEN = 16
KEY_LEN = 32
NONCE_LEN = 12
HW_FIXED_PAD_LEN = 4

CONSTANT = b"expand 32-byte k"


# ============================================================
# ChaCha20 Core
# ============================================================

def rotl32(x, n):
    return ((x << n) & 0xffffffff) | (x >> (32 - n))


def quarter_round(s, a, b, c, d):
    s[a] = (s[a] + s[b]) & 0xffffffff
    s[d] = rotl32(s[d] ^ s[a], 16)

    s[c] = (s[c] + s[d]) & 0xffffffff
    s[b] = rotl32(s[b] ^ s[c], 12)

    s[a] = (s[a] + s[b]) & 0xffffffff
    s[d] = rotl32(s[d] ^ s[a], 8)

    s[c] = (s[c] + s[d]) & 0xffffffff
    s[b] = rotl32(s[b] ^ s[c], 7)


def chacha20_block(key, counter, nonce):
    if len(key) != 32:
        raise ValueError(f"Key length error: expected 32 bytes, got {len(key)}")

    if len(nonce) != 12:
        raise ValueError(f"Nonce length error: expected 12 bytes, got {len(nonce)}")

    state = [0] * 16

    state[0:4] = struct.unpack("<4I", CONSTANT)
    state[4:12] = struct.unpack("<8I", key)
    state[12] = counter & 0xffffffff
    state[13:16] = struct.unpack("<3I", nonce)

    working = state[:]

    for _ in range(10):
        quarter_round(working, 0, 4, 8, 12)
        quarter_round(working, 1, 5, 9, 13)
        quarter_round(working, 2, 6, 10, 14)
        quarter_round(working, 3, 7, 11, 15)

        quarter_round(working, 0, 5, 10, 15)
        quarter_round(working, 1, 6, 11, 12)
        quarter_round(working, 2, 7, 8, 13)
        quarter_round(working, 3, 4, 9, 14)

    out = [(state[i] + working[i]) & 0xffffffff for i in range(16)]
    return struct.pack("<16I", *out)


def chacha20_process(key, nonce, data, start_counter=1):
    output = bytearray()

    num_blocks = (len(data) + 63) // 64

    for block_idx in range(num_blocks):
        counter = start_counter + block_idx
        keystream = chacha20_block(key, counter, nonce)

        block = data[block_idx * 64:(block_idx + 1) * 64]

        for b, k in zip(block, keystream):
            output.append(b ^ k)

    return bytes(output)


# ============================================================
# Poly1305 Core
# ============================================================

def poly1305_mac(msg, key32):
    if len(key32) != 32:
        raise ValueError(f"Poly1305 key length error: expected 32 bytes, got {len(key32)}")

    r = int.from_bytes(key32[:16], "little")
    r &= 0x0ffffffc0ffffffc0ffffffc0fffffff

    s = int.from_bytes(key32[16:], "little")

    p = (1 << 130) - 5
    acc = 0

    for i in range(0, len(msg), 16):
        block = msg[i:i + 16]
        n = int.from_bytes(block + b"\x01", "little")

        acc = (acc + n) % p
        acc = (acc * r) % p

    tag = (acc + s) & ((1 << 128) - 1)
    return tag.to_bytes(16, "little")


def pad16(data):
    pad_len = (16 - (len(data) % 16)) % 16
    return b"\x00" * pad_len


def build_mac_data(aad, ciphertext):
    return (
        aad +
        pad16(aad) +
        ciphertext +
        pad16(ciphertext) +
        struct.pack("<Q", len(aad)) +
        struct.pack("<Q", len(ciphertext))
    )


# ============================================================
# RFC8439 AEAD
# ============================================================

def aead_encrypt(key, nonce, aad, plaintext):
    poly_key = chacha20_block(key, 0, nonce)[:32]

    ciphertext = chacha20_process(
        key=key,
        nonce=nonce,
        data=plaintext,
        start_counter=1
    )

    mac_data = build_mac_data(aad, ciphertext)
    tag = poly1305_mac(mac_data, poly_key)

    return ciphertext, tag


def constant_time_equal(a, b):
    if len(a) != len(b):
        return False

    diff = 0

    for x, y in zip(a, b):
        diff |= x ^ y

    return diff == 0


def aead_decrypt(key, nonce, aad, ciphertext, tag):
    poly_key = chacha20_block(key, 0, nonce)[:32]

    mac_data = build_mac_data(aad, ciphertext)
    calc_tag = poly1305_mac(mac_data, poly_key)

    if not constant_time_equal(calc_tag, tag):
        raise ValueError(
            "TAG verification failed\n"
            f"  calculated tag = {calc_tag.hex()}\n"
            f"  golden tag     = {tag.hex()}"
        )

    plaintext = chacha20_process(
        key=key,
        nonce=nonce,
        data=ciphertext,
        start_counter=1
    )

    return plaintext


# ============================================================
# RAM HEX File IO
# 你的 generator 是 chunk[::-1].hex()
# 所以這裡讀回來要再 [::-1]
# ============================================================

def read_ram_hex_file(path):
    path = Path(path)

    if not path.exists():
        raise FileNotFoundError(f"Cannot find file: {path}")

    data = bytearray()

    with open(path, "r") as f:
        for line_no, line in enumerate(f, start=1):
            line = line.strip()

            if not line:
                continue

            raw = bytes.fromhex(line)

            if len(raw) != 4:
                raise ValueError(
                    f"{path}, line {line_no}: each line must be 32-bit hex word"
                )

            data.extend(raw[::-1])

    return bytes(data)


def write_ram_hex_file(path, data):
    path = Path(path)

    with open(path, "w") as f:
        for i in range(0, len(data), 4):
            chunk = data[i:i + 4]

            if len(chunk) < 4:
                chunk += b"\x00" * (4 - len(chunk))

            f.write(chunk[::-1].hex() + "\n")


# ============================================================
# RAM Layout Parser
# ============================================================

def parse_encrypt_src_ram(src_data, aad_len, msg_len):
    aad_pad_len = (16 - (aad_len % 16)) % 16

    key_start = 0
    key_end = key_start + KEY_LEN

    nonce_start = key_end
    nonce_end = nonce_start + NONCE_LEN

    aad_start = nonce_end
    aad_end = aad_start + aad_len

    aad_pad_start = aad_end
    aad_pad_end = aad_pad_start + aad_pad_len

    hw_pad_start = aad_pad_end
    hw_pad_end = hw_pad_start + HW_FIXED_PAD_LEN

    pt_start = hw_pad_end
    pt_end = pt_start + msg_len

    required_len = pt_end

    if len(src_data) < required_len:
        raise ValueError(
            f"Src_RAM_enc too short: need {required_len} bytes, got {len(src_data)}"
        )

    key = src_data[key_start:key_end]
    nonce = src_data[nonce_start:nonce_end]
    aad = src_data[aad_start:aad_end]
    aad_pad = src_data[aad_pad_start:aad_pad_end]
    hw_pad = src_data[hw_pad_start:hw_pad_end]
    plaintext = src_data[pt_start:pt_end]

    if aad_pad != b"\x00" * aad_pad_len:
        raise ValueError(f"AAD pad is not zero: {aad_pad.hex()}")

    if hw_pad != b"\x00" * HW_FIXED_PAD_LEN:
        raise ValueError(f"HW 4-byte pad is not zero: {hw_pad.hex()}")

    return key, nonce, aad, plaintext


def parse_decrypt_src_ram(src_data, aad_len, msg_len):
    aad_pad_len = (16 - (aad_len % 16)) % 16

    key_start = 0
    key_end = key_start + KEY_LEN

    nonce_start = key_end
    nonce_end = nonce_start + NONCE_LEN

    aad_start = nonce_end
    aad_end = aad_start + aad_len

    aad_pad_start = aad_end
    aad_pad_end = aad_pad_start + aad_pad_len

    hw_pad_start = aad_pad_end
    hw_pad_end = hw_pad_start + HW_FIXED_PAD_LEN

    ct_start = hw_pad_end
    ct_end = ct_start + msg_len

    tag_start = ct_end
    tag_end = tag_start + TAG_LEN

    required_len = tag_end

    if len(src_data) < required_len:
        raise ValueError(
            f"Src_RAM_dec too short: need {required_len} bytes, got {len(src_data)}"
        )

    key = src_data[key_start:key_end]
    nonce = src_data[nonce_start:nonce_end]
    aad = src_data[aad_start:aad_end]
    aad_pad = src_data[aad_pad_start:aad_pad_end]
    hw_pad = src_data[hw_pad_start:hw_pad_end]
    ciphertext = src_data[ct_start:ct_end]
    tag = src_data[tag_start:tag_end]

    if aad_pad != b"\x00" * aad_pad_len:
        raise ValueError(f"AAD pad is not zero: {aad_pad.hex()}")

    if hw_pad != b"\x00" * HW_FIXED_PAD_LEN:
        raise ValueError(f"HW 4-byte pad is not zero: {hw_pad.hex()}")

    return key, nonce, aad, ciphertext, tag


# ============================================================
# Performance Monitor
# ============================================================

def calc_mib_per_sec(byte_count, seconds):
    if seconds <= 0:
        return float("inf")

    return byte_count / (1024 * 1024) / seconds


def benchmark(name, byte_count, rounds, func):
    times_ns = []
    last_result = None

    for _ in range(rounds):
        t0 = time.perf_counter_ns()
        last_result = func()
        t1 = time.perf_counter_ns()

        times_ns.append(t1 - t0)

    avg_ns = statistics.mean(times_ns)
    min_ns = min(times_ns)
    max_ns = max(times_ns)

    avg_s = avg_ns / 1_000_000_000
    min_s = min_ns / 1_000_000_000
    max_s = max_ns / 1_000_000_000

    print()
    print(f"[{name} performance]")
    print(f"rounds      : {rounds}")
    print(f"bytes       : {byte_count}")
    print(f"avg time    : {avg_ns / 1_000_000:.6f} ms")
    print(f"min time    : {min_ns / 1_000_000:.6f} ms")
    print(f"max time    : {max_ns / 1_000_000:.6f} ms")
    print(f"avg speed   : {calc_mib_per_sec(byte_count, avg_s):.3f} MiB/s")
    print(f"best speed  : {calc_mib_per_sec(byte_count, min_s):.3f} MiB/s")
    print(f"worst speed : {calc_mib_per_sec(byte_count, max_s):.3f} MiB/s")

    return last_result


# ============================================================
# Test Runner
# ============================================================

def run_encrypt_test():
    src_path = TESTCASE_DIR / SRC_RAM_ENC_FILE
    dst_path = TESTCASE_DIR / DST_RAM_ENC_FILE

    src_data = read_ram_hex_file(src_path)
    dst_data = read_ram_hex_file(dst_path)

    key, nonce, aad, plaintext = parse_encrypt_src_ram(
        src_data=src_data,
        aad_len=AAD_LEN,
        msg_len=MSG_LEN
    )

    golden_ciphertext = dst_data[:MSG_LEN]
    golden_tag = dst_data[MSG_LEN:MSG_LEN + TAG_LEN]

    if len(golden_ciphertext) != MSG_LEN:
        raise ValueError("Dst_RAM_enc ciphertext length error")

    if len(golden_tag) != TAG_LEN:
        raise ValueError("Dst_RAM_enc tag length error")

    def work():
        return aead_encrypt(key, nonce, aad, plaintext)

    ciphertext, tag = benchmark(
        name="encrypt",
        byte_count=len(aad) + len(plaintext),
        rounds=BENCH_ROUNDS,
        func=work
    )

    ct_match = ciphertext == golden_ciphertext
    tag_match = tag == golden_tag

    print()
    print("[encrypt verify]")
    print(f"src file    : {src_path}")
    print(f"dst file    : {dst_path}")
    print(f"key         : {key.hex()}")
    print(f"nonce       : {nonce.hex()}")
    print(f"AAD length  : {len(aad)}")
    print(f"PT length   : {len(plaintext)}")
    print(f"CT match    : {ct_match}")
    print(f"TAG match   : {tag_match}")
    print(f"calc TAG    : {tag.hex()}")
    print(f"gold TAG    : {golden_tag.hex()}")

    if not ct_match:
        print()
        print("[encrypt mismatch detail]")
        print(f"calc CT     : {ciphertext.hex()}")
        print(f"gold CT     : {golden_ciphertext.hex()}")
        raise RuntimeError("Encrypt ciphertext mismatch")

    if not tag_match:
        raise RuntimeError("Encrypt tag mismatch")


def run_decrypt_test():
    src_path = TESTCASE_DIR / SRC_RAM_DEC_FILE
    dst_path = TESTCASE_DIR / DST_RAM_DEC_FILE

    src_data = read_ram_hex_file(src_path)
    dst_data = read_ram_hex_file(dst_path)

    key, nonce, aad, ciphertext, tag = parse_decrypt_src_ram(
        src_data=src_data,
        aad_len=AAD_LEN,
        msg_len=MSG_LEN
    )

    golden_plaintext = dst_data[:MSG_LEN]

    if len(golden_plaintext) != MSG_LEN:
        raise ValueError("Dst_RAM_dec plaintext length error")

    def work():
        return aead_decrypt(key, nonce, aad, ciphertext, tag)

    plaintext = benchmark(
        name="decrypt",
        byte_count=len(aad) + len(ciphertext),
        rounds=BENCH_ROUNDS,
        func=work
    )

    pt_match = plaintext == golden_plaintext

    print()
    print("[decrypt verify]")
    print(f"src file    : {src_path}")
    print(f"dst file    : {dst_path}")
    print(f"key         : {key.hex()}")
    print(f"nonce       : {nonce.hex()}")
    print(f"AAD length  : {len(aad)}")
    print(f"CT length   : {len(ciphertext)}")
    print(f"PT match    : {pt_match}")
    print(f"TAG         : {tag.hex()}")

    if not pt_match:
        print()
        print("[decrypt mismatch detail]")
        print(f"calc PT     : {plaintext.hex()}")
        print(f"gold PT     : {golden_plaintext.hex()}")
        raise RuntimeError("Decrypt plaintext mismatch")


def print_config():
    aad_pad_len = (16 - (AAD_LEN % 16)) % 16

    enc_src_effective_len = KEY_LEN + NONCE_LEN + AAD_LEN + aad_pad_len + HW_FIXED_PAD_LEN + MSG_LEN
    enc_dst_effective_len = MSG_LEN + TAG_LEN
    dec_src_effective_len = KEY_LEN + NONCE_LEN + AAD_LEN + aad_pad_len + HW_FIXED_PAD_LEN + MSG_LEN + TAG_LEN
    dec_dst_effective_len = MSG_LEN

    print("=" * 72)
    print("RFC8439 ChaCha20-Poly1305 RAM Testcase Processor")
    print("=" * 72)
    print(f"TESTCASE_DIR       : {TESTCASE_DIR.resolve()}")
    print(f"AAD_LEN            : {AAD_LEN} bytes")
    print(f"MSG_LEN            : {MSG_LEN} bytes")
    print(f"BENCH_ROUNDS       : {BENCH_ROUNDS}")
    print(f"RUN_ENCRYPT        : {RUN_ENCRYPT}")
    print(f"RUN_DECRYPT        : {RUN_DECRYPT}")
    print()
    print("[expected effective RAM bytes]")
    print(f"Src_RAM_enc        : {enc_src_effective_len} bytes")
    print(f"Dst_RAM_enc        : {enc_dst_effective_len} bytes")
    print(f"Src_RAM_dec        : {dec_src_effective_len} bytes")
    print(f"Dst_RAM_dec        : {dec_dst_effective_len} bytes")
    print()
    print("[RAM files]")
    print(f"Src_RAM_enc file   : {SRC_RAM_ENC_FILE}")
    print(f"Dst_RAM_enc file   : {DST_RAM_ENC_FILE}")
    print(f"Src_RAM_dec file   : {SRC_RAM_DEC_FILE}")
    print(f"Dst_RAM_dec file   : {DST_RAM_DEC_FILE}")
    print("=" * 72)


def main():
    print_config()

    if RUN_ENCRYPT:
        run_encrypt_test()

    if RUN_DECRYPT:
        run_decrypt_test()

    print()
    print("=" * 72)
    print("All enabled tests passed.")
    print("=" * 72)


if __name__ == "__main__":
    main()