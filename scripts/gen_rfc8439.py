#!/usr/bin/env python3
# generate_rfc8439_multi_vectors.py
#
# Generate multi-case vector files for tb_rfc8439_multi.sv.
#
# Output files:
#   rfc8439_case_info.txt
#   rfc8439_ct_all.txt
#   rfc8439_tag_all.txt
#   rfc8439_pt_all.txt
#   rfc8439_src_encrypt_all.txt
#   rfc8439_src_decrypt_all.txt
#   rfc8439_summary.txt
#
# Verilog layout:
#   case_info[case_id*2 + 0] = ad_length
#   case_info[case_id*2 + 1] = msg_length
#
#   golden_ct_all[case_id*MAX_MSG_WORDS + word_idx]
#   golden_tag_all[case_id*4 + word_idx]
#   golden_pt_all[case_id*MAX_PT_WORDS + word_idx]
#
#   src_encrypt_all[case_id*MAX_SRC_WORDS + word_idx] = [AAD][PT]
#   src_decrypt_all[case_id*MAX_SRC_WORDS + word_idx] = [AAD][CT][TAG]
#
# Usage:
#   python3 generate_rfc8439_multi_vectors.py --out ..
#   python3 generate_rfc8439_multi_vectors.py --out .. --random 20
#   python3 generate_rfc8439_multi_vectors.py --out .. --case MYCASE:7:13

import argparse
import json
import random
from pathlib import Path


MAX_MSG_WORDS = 256
MAX_SRC_WORDS = 320
MAX_PT_WORDS = 256
TAG_WORDS = 4


def le32(b):
    return int.from_bytes(b, "little")


def rotl32(v, n):
    return ((v << n) & 0xffffffff) | (v >> (32 - n))


def quarterround(st, a, b, c, d):
    st[a] = (st[a] + st[b]) & 0xffffffff
    st[d] ^= st[a]
    st[d] = rotl32(st[d], 16)

    st[c] = (st[c] + st[d]) & 0xffffffff
    st[b] ^= st[c]
    st[b] = rotl32(st[b], 12)

    st[a] = (st[a] + st[b]) & 0xffffffff
    st[d] ^= st[a]
    st[d] = rotl32(st[d], 8)

    st[c] = (st[c] + st[d]) & 0xffffffff
    st[b] ^= st[c]
    st[b] = rotl32(st[b], 7)


def chacha20_block(key, counter, nonce):
    const = b"expand 32-byte k"

    state = [
        le32(const[0:4]),
        le32(const[4:8]),
        le32(const[8:12]),
        le32(const[12:16]),

        le32(key[0:4]),
        le32(key[4:8]),
        le32(key[8:12]),
        le32(key[12:16]),
        le32(key[16:20]),
        le32(key[20:24]),
        le32(key[24:28]),
        le32(key[28:32]),

        counter & 0xffffffff,

        le32(nonce[0:4]),
        le32(nonce[4:8]),
        le32(nonce[8:12]),
    ]

    working = state[:]

    for _ in range(10):
        quarterround(working, 0, 4, 8, 12)
        quarterround(working, 1, 5, 9, 13)
        quarterround(working, 2, 6, 10, 14)
        quarterround(working, 3, 7, 11, 15)

        quarterround(working, 0, 5, 10, 15)
        quarterround(working, 1, 6, 11, 12)
        quarterround(working, 2, 7, 8, 13)
        quarterround(working, 3, 4, 9, 14)

    out = []

    for i in range(16):
        out.append((working[i] + state[i]) & 0xffffffff)

    return b"".join(x.to_bytes(4, "little") for x in out)


def chacha20_xor(key, nonce, counter, data):
    out = bytearray()
    block_counter = counter

    for offset in range(0, len(data), 64):
        keystream = chacha20_block(key, block_counter, nonce)
        block = data[offset:offset + 64]
        out.extend(bytes(a ^ b for a, b in zip(block, keystream)))
        block_counter = (block_counter + 1) & 0xffffffff

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
    s = int.from_bytes(key32[16:32], "little")

    p = (1 << 130) - 5

    acc = 0

    for offset in range(0, len(msg), 16):
        block = msg[offset:offset + 16]
        n = int.from_bytes(block + b"\x01", "little")
        acc = ((acc + n) * r) % p

    tag = (acc + s) % (1 << 128)

    return tag.to_bytes(16, "little")


def pad16(data):
    rem = len(data) % 16

    if rem == 0:
        return b""

    return b"\x00" * (16 - rem)


def aead_encrypt(key, nonce, aad, plaintext):
    poly_key = chacha20_block(key, 0, nonce)[:32]

    ciphertext = chacha20_xor(key, nonce, 1, plaintext)

    mac_data = b""
    mac_data += aad
    mac_data += pad16(aad)
    mac_data += ciphertext
    mac_data += pad16(ciphertext)
    mac_data += len(aad).to_bytes(8, "little")
    mac_data += len(ciphertext).to_bytes(8, "little")

    tag = poly1305_mac(mac_data, poly_key)

    return ciphertext, tag


def bytes_to_words_le(data):
    words = []

    for offset in range(0, len(data), 4):
        chunk = data[offset:offset + 4]
        chunk = chunk + b"\x00" * (4 - len(chunk))
        words.append(int.from_bytes(chunk, "little"))

    return words


def pad_words(words, count):
    if len(words) > count:
        raise ValueError(f"too many words: {len(words)} > {count}")

    return words + [0] * (count - len(words))


def write_words(path, words):
    with open(path, "w", encoding="utf-8") as f:
        for word in words:
            f.write(f"{word:08x}\n")


def pattern_aad(length):
    base = bytes([
        0x50, 0x51, 0x52, 0x53,
        0xc0, 0xc1, 0xc2, 0xc3,
        0xc4, 0xc5, 0xc6, 0xc7,
    ])

    if length <= len(base):
        return base[:length]

    extra = bytes((0xa0 + i) & 0xff for i in range(length - len(base)))

    return base + extra


def pattern_plaintext(length):
    base = (
        b"Ladies and Gentlemen of the class of '99: If I could offer you only one tip "
        b"for the future, sunscreen would be it."
    )

    if length <= len(base):
        return base[:length]

    extra = bytes((0x30 + i) & 0xff for i in range(length - len(base)))

    return base + extra


def parse_case(text):
    parts = text.split(":")

    if len(parts) != 3:
        raise ValueError("case format must be NAME:AD_LEN:MSG_LEN")

    name = parts[0]
    ad_len = int(parts[1], 0)
    msg_len = int(parts[2], 0)

    if ad_len < 0 or msg_len < 0:
        raise ValueError("length must be non-negative")

    return name, ad_len, msg_len


def generate_one_case(name, ad_len, msg_len, key, nonce):
    aad = pattern_aad(ad_len)
    pt = pattern_plaintext(msg_len)

    ct, tag = aead_encrypt(key, nonce, aad, pt)

    case_info_words = [ad_len, msg_len]

    ct_words = pad_words(bytes_to_words_le(ct), MAX_MSG_WORDS)
    tag_words = pad_words(bytes_to_words_le(tag), TAG_WORDS)
    pt_words = pad_words(bytes_to_words_le(pt), MAX_PT_WORDS)

    src_encrypt_words = pad_words(bytes_to_words_le(aad + pt), MAX_SRC_WORDS)
    src_decrypt_words = pad_words(bytes_to_words_le(aad + ct + tag), MAX_SRC_WORDS)

    meta = {
        "name": name,
        "ad_length": ad_len,
        "msg_length": msg_len,
        "tag_words": [f"{w:08x}" for w in bytes_to_words_le(tag)],
        "ct_words_used": len(bytes_to_words_le(ct)),
        "pt_words_used": len(bytes_to_words_le(pt)),
        "src_encrypt_words_used": len(bytes_to_words_le(aad + pt)),
        "src_decrypt_words_used": len(bytes_to_words_le(aad + ct + tag)),
    }

    return case_info_words, ct_words, tag_words, pt_words, src_encrypt_words, src_decrypt_words, meta


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--out", default="./testcase")
    parser.add_argument("--case", action="append", default=[])
    parser.add_argument("--random", type=int, default=0)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--max-ad", type=int, default=80)
    parser.add_argument("--max-msg", type=int, default=256)

    parser.add_argument(
        "--key",
        default="808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f",
    )

    parser.add_argument(
        "--nonce",
        default="070000004041424344454647",
    )

    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    key = bytes.fromhex(args.key)
    nonce = bytes.fromhex(args.nonce)

    if len(key) != 32:
        raise ValueError("key must be 32 bytes")

    if len(nonce) != 12:
        raise ValueError("nonce must be 12 bytes")

    cases = []

    if args.case:
        for item in args.case:
            cases.append(parse_case(item))
    else:
        cases.extend([
            ("TC0_AD12_MSG114", 12, 114),
            ("TC1_AD0_MSG114", 0, 114),
            ("TC2_AD12_MSG64", 12, 64),
            ("TC3_AD12_MSG65", 12, 65),
            ("TC4_AD7_MSG13", 7, 13),
            ("TC5_AD12_MSG0", 12, 0),
            ("TC6_AD0_MSG0", 0, 0),
            ("TC7_AD15_MSG17", 15, 17),
        ])

    rng = random.Random(args.seed)

    for idx in range(args.random):
        ad_len = rng.randint(0, args.max_ad)
        msg_len = rng.randint(0, args.max_msg)

        cases.append((f"RAND{idx:03d}_AD{ad_len}_MSG{msg_len}", ad_len, msg_len))

    case_info_all = []
    ct_all = []
    tag_all = []
    pt_all = []
    src_encrypt_all = []
    src_decrypt_all = []
    metas = []

    for name, ad_len, msg_len in cases:
        if (msg_len + 3) // 4 > MAX_MSG_WORDS:
            raise ValueError(f"{name}: msg too long for MAX_MSG_WORDS")

        if (msg_len + 3) // 4 > MAX_PT_WORDS:
            raise ValueError(f"{name}: msg too long for MAX_PT_WORDS")

        if (ad_len + msg_len + 16 + 3) // 4 > MAX_SRC_WORDS:
            raise ValueError(f"{name}: source too long for MAX_SRC_WORDS")

        case_info, ct, tag, pt, src_enc, src_dec, meta = generate_one_case(
            name,
            ad_len,
            msg_len,
            key,
            nonce,
        )

        case_info_all.extend(case_info)
        ct_all.extend(ct)
        tag_all.extend(tag)
        pt_all.extend(pt)
        src_encrypt_all.extend(src_enc)
        src_decrypt_all.extend(src_dec)
        metas.append(meta)

    write_words(out_dir / "rfc8439_case_info.txt", case_info_all)
    write_words(out_dir / "rfc8439_ct_all.txt", ct_all)
    write_words(out_dir / "rfc8439_tag_all.txt", tag_all)
    write_words(out_dir / "rfc8439_pt_all.txt", pt_all)
    write_words(out_dir / "rfc8439_src_encrypt_all.txt", src_encrypt_all)
    write_words(out_dir / "rfc8439_src_decrypt_all.txt", src_decrypt_all)

    with open(out_dir / "rfc8439_summary.json", "w", encoding="utf-8") as f:
        json.dump(metas, f, indent=2)

    with open(out_dir / "rfc8439_summary.txt", "w", encoding="utf-8") as f:
        f.write(f"NUM_CASES = {len(metas)}\n")
        f.write(f"MAX_MSG_WORDS = {MAX_MSG_WORDS}\n")
        f.write(f"MAX_SRC_WORDS = {MAX_SRC_WORDS}\n")
        f.write(f"MAX_PT_WORDS = {MAX_PT_WORDS}\n")
        f.write("\n")

        for idx, meta in enumerate(metas):
            f.write(f"CASE {idx}: {meta['name']}\n")
            f.write(f"ad_length  = {meta['ad_length']}\n")
            f.write(f"msg_length = {meta['msg_length']}\n")
            f.write("tag words:\n")

            for word in meta["tag_words"]:
                f.write(f"{word}\n")

            f.write("\n")

    print(f"Generated {len(metas)} case(s)")
    print(f"Output directory: {out_dir}")
    print()
    print("Important:")
    print(f"Set NUM_CASES = {len(metas)} in tb_rfc8439_multi.sv if you changed the number of cases.")
    print()
    for idx, meta in enumerate(metas):
        print(f"CASE {idx}: {meta['name']}, AD={meta['ad_length']}, MSG={meta['msg_length']}, TAG={' '.join(meta['tag_words'])}")


if __name__ == "__main__":
    main()
