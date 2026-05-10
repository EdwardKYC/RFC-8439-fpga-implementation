import os
import struct
from pathlib import Path

out_dir = Path("testcase")
out_dir.mkdir(parents=True, exist_ok=True)

msg_len = 640 * 480 * 3
ad_len = 12
tag_len = 16

key = bytes(range(0x80, 0xA0))
nonce = bytes([
    0x07, 0x00, 0x00, 0x00,
    0x40, 0x41, 0x42, 0x43,
    0x44, 0x45, 0x46, 0x47
])

aad = os.urandom(ad_len)
pt = os.urandom(msg_len)

def rotl32(x, n):
    return ((x << n) & 0xffffffff) | (x >> (32 - n))

def quarter_round(s, a, b, c, d):
    s[a] = (s[a] + s[b]) & 0xffffffff
    s[d] ^= s[a]
    s[d] = rotl32(s[d], 16)

    s[c] = (s[c] + s[d]) & 0xffffffff
    s[b] ^= s[c]
    s[b] = rotl32(s[b], 12)

    s[a] = (s[a] + s[b]) & 0xffffffff
    s[d] ^= s[a]
    s[d] = rotl32(s[d], 8)

    s[c] = (s[c] + s[d]) & 0xffffffff
    s[b] ^= s[c]
    s[b] = rotl32(s[b], 7)

def chacha20_block(key, counter, nonce):
    constants = b"expand 32-byte k"

    state = list(struct.unpack("<4I", constants))
    state += list(struct.unpack("<8I", key))
    state += [counter & 0xffffffff]
    state += list(struct.unpack("<3I", nonce))

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

    out = [(working[i] + state[i]) & 0xffffffff for i in range(16)]
    return struct.pack("<16I", *out)

def chacha20_encrypt(key, nonce, plaintext):
    out = bytearray()
    counter = 1

    for i in range(0, len(plaintext), 64):
        block = plaintext[i:i+64]
        ks = chacha20_block(key, counter, nonce)
        counter = (counter + 1) & 0xffffffff

        out.extend(bytes([b ^ k for b, k in zip(block, ks)]))

    return bytes(out)

def clamp_r(r):
    r = bytearray(r)
    r[3] &= 15
    r[7] &= 15
    r[11] &= 15
    r[15] &= 15
    r[4] &= 252
    r[8] &= 252
    r[12] &= 252
    return bytes(r)

def poly1305_mac(msg, key32):
    r = int.from_bytes(clamp_r(key32[:16]), "little")
    s = int.from_bytes(key32[16:], "little")
    p = (1 << 130) - 5

    acc = 0

    for i in range(0, len(msg), 16):
        block = msg[i:i+16]
        n = int.from_bytes(block + b"\x01", "little")
        acc = (acc + n) % p
        acc = (acc * r) % p

    tag = (acc + s) % (1 << 128)
    return tag.to_bytes(16, "little")

def pad16(x):
    rem = len(x) % 16
    if rem == 0:
        return b""
    return b"\x00" * (16 - rem)

def aead_chacha20_poly1305_encrypt(key, nonce, aad, pt):
    otk = chacha20_block(key, 0, nonce)[:32]

    ct = chacha20_encrypt(key, nonce, pt)

    mac_data = (
        aad +
        pad16(aad) +
        ct +
        pad16(ct) +
        struct.pack("<Q", len(aad)) +
        struct.pack("<Q", len(ct))
    )

    tag = poly1305_mac(mac_data, otk)

    return ct, tag

def write_hex_words(filename, data):
    with open(out_dir / filename, "w") as f:
        for i in range(0, len(data), 4):
            chunk = data[i:i+4]
            if len(chunk) < 4:
                chunk = chunk.ljust(4, b"\x00")
            word = int.from_bytes(chunk, byteorder="little")
            f.write(f"{word:08x}\n")

ct, tag = aead_chacha20_poly1305_encrypt(key, nonce, aad, pt)

with open(out_dir / "video_case_info.txt", "w") as f:
    f.write(f"{ad_len:08x}\n")
    f.write(f"{msg_len:08x}\n")

write_hex_words("video_src_encrypt.txt", aad + pt)
write_hex_words("video_golden_ct.txt", ct)
write_hex_words("video_golden_tag.txt", tag)

write_hex_words("video_src_decrypt.txt", aad + ct + tag)
write_hex_words("video_golden_pt.txt", pt)

print("Valid RFC8439 video testcase generated.")
print("AD length  =", ad_len)
print("MSG length =", msg_len)
print("CT length  =", len(ct))
print("TAG        =", tag.hex())