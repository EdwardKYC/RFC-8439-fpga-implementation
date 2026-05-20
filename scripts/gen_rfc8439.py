#!/usr/bin/env python3
"""
Generate multi-case RFC8439 ChaCha20-Poly1305 vectors for post-simulation.

Default output is 4 cases, each with a 4000-byte random message.
The file names match tb_rfc8439_multi_4000.sv:

  rfc8439_case_info.txt
  rfc8439_ct_all.txt
  rfc8439_tag_all.txt
  rfc8439_pt_all.txt
  rfc8439_src_encrypt_all.txt
  rfc8439_src_decrypt_all.txt
  rfc8439_summary.txt
  rfc8439_summary.json

Memory layout per case:
  case_info[case_id*2 + 0] = ad_length
  case_info[case_id*2 + 1] = msg_length

  ct_all       base = case_id * MAX_MSG_WORDS
  pt_all       base = case_id * MAX_PT_WORDS
  tag_all      base = case_id * TAG_WORDS
  src_enc_all  base = case_id * MAX_SRC_WORDS = [AAD][Plaintext]
  src_dec_all  base = case_id * MAX_SRC_WORDS = [AAD][Ciphertext][Tag]
"""

import argparse
import json
import random
from pathlib import Path

TAG_WORDS = 4
MAX_MSG_WORDS = 1024   # enough for 4000 bytes => 1000 words
MAX_PT_WORDS = 1024
MAX_SRC_WORDS = 2048   # enough for AAD + 4000-byte msg + 16-byte tag

DEFAULT_KEY_HEX = "808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f"
DEFAULT_NONCE_HEX = "070000004041424344454647"


def le32(data: bytes) -> int:
    return int.from_bytes(data, "little")


def rotl32(v: int, n: int) -> int:
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


def chacha20_block(key: bytes, counter: int, nonce: bytes) -> bytes:
    const = b"expand 32-byte k"
    state = [
        le32(const[0:4]), le32(const[4:8]), le32(const[8:12]), le32(const[12:16]),
        le32(key[0:4]), le32(key[4:8]), le32(key[8:12]), le32(key[12:16]),
        le32(key[16:20]), le32(key[20:24]), le32(key[24:28]), le32(key[28:32]),
        counter & 0xffffffff,
        le32(nonce[0:4]), le32(nonce[4:8]), le32(nonce[8:12]),
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

    out_words = [(working[i] + state[i]) & 0xffffffff for i in range(16)]
    return b"".join(x.to_bytes(4, "little") for x in out_words)


def chacha20_xor(key: bytes, nonce: bytes, counter: int, data: bytes) -> bytes:
    out = bytearray()
    block_counter = counter
    for offset in range(0, len(data), 64):
        ks = chacha20_block(key, block_counter, nonce)
        block = data[offset:offset + 64]
        out.extend(a ^ b for a, b in zip(block, ks))
        block_counter = (block_counter + 1) & 0xffffffff
    return bytes(out)


def clamp_r(r: bytes) -> bytes:
    r = bytearray(r)
    r[3] &= 15
    r[7] &= 15
    r[11] &= 15
    r[15] &= 15
    r[4] &= 252
    r[8] &= 252
    r[12] &= 252
    return bytes(r)


def poly1305_mac(msg: bytes, key32: bytes) -> bytes:
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


def pad16(data: bytes) -> bytes:
    rem = len(data) % 16
    return b"" if rem == 0 else b"\x00" * (16 - rem)


def aead_encrypt(key: bytes, nonce: bytes, aad: bytes, plaintext: bytes):
    poly_key = chacha20_block(key, 0, nonce)[:32]
    ciphertext = chacha20_xor(key, nonce, 1, plaintext)

    mac_data = b"".join([
        aad,
        pad16(aad),
        ciphertext,
        pad16(ciphertext),
        len(aad).to_bytes(8, "little"),
        len(ciphertext).to_bytes(8, "little"),
    ])
    tag = poly1305_mac(mac_data, poly_key)
    return ciphertext, tag


def bytes_to_words_le(data: bytes):
    words = []
    for offset in range(0, len(data), 4):
        chunk = data[offset:offset + 4]
        chunk += b"\x00" * (4 - len(chunk))
        words.append(int.from_bytes(chunk, "little"))
    return words


def pad_words(words, count, name):
    if len(words) > count:
        raise ValueError(f"{name}: too many words: {len(words)} > {count}")
    return words + [0] * (count - len(words))


def write_words(path: Path, words):
    with path.open("w", encoding="utf-8") as f:
        for word in words:
            f.write(f"{word:08x}\n")


def random_bytes(rng: random.Random, length: int) -> bytes:
    return bytes(rng.randrange(0, 256) for _ in range(length))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="./testcase")
    parser.add_argument("--num-cases", type=int, default=4)
    parser.add_argument("--msg-len", type=int, default=4000)
    parser.add_argument("--ad-len", type=int, default=None,
                        help="Fixed AAD length. Omit to randomize AAD length per case.")
    parser.add_argument("--max-ad", type=int, default=80)
    parser.add_argument("--seed", type=int, default=8439)
    parser.add_argument("--key", default=DEFAULT_KEY_HEX)
    parser.add_argument("--nonce", default=DEFAULT_NONCE_HEX)
    args = parser.parse_args()

    if args.num_cases <= 0:
        raise ValueError("--num-cases must be positive")
    if args.msg_len < 0:
        raise ValueError("--msg-len must be non-negative")
    if args.max_ad < 0:
        raise ValueError("--max-ad must be non-negative")

    key = bytes.fromhex(args.key)
    nonce = bytes.fromhex(args.nonce)
    if len(key) != 32:
        raise ValueError("key must be 32 bytes")
    if len(nonce) != 12:
        raise ValueError("nonce must be 12 bytes")

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    rng = random.Random(args.seed)

    case_info_all = []
    ct_all = []
    tag_all = []
    pt_all = []
    src_encrypt_all = []
    src_decrypt_all = []
    metas = []

    for case_id in range(args.num_cases):
        ad_len = args.ad_len if args.ad_len is not None else rng.randint(0, args.max_ad)
        msg_len = args.msg_len

        aad = random_bytes(rng, ad_len)
        pt = random_bytes(rng, msg_len)
        ct, tag = aead_encrypt(key, nonce, aad, pt)

        case_info_all.extend([ad_len, msg_len])
        ct_all.extend(pad_words(bytes_to_words_le(ct), MAX_MSG_WORDS, "ct"))
        tag_all.extend(pad_words(bytes_to_words_le(tag), TAG_WORDS, "tag"))
        pt_all.extend(pad_words(bytes_to_words_le(pt), MAX_PT_WORDS, "pt"))
        src_encrypt_all.extend(pad_words(bytes_to_words_le(aad + pt), MAX_SRC_WORDS, "src_encrypt"))
        src_decrypt_all.extend(pad_words(bytes_to_words_le(aad + ct + tag), MAX_SRC_WORDS, "src_decrypt"))

        metas.append({
            "case_id": case_id,
            "name": f"RAND{case_id:03d}_AD{ad_len}_MSG{msg_len}",
            "ad_length": ad_len,
            "msg_length": msg_len,
            "tag_words": [f"{w:08x}" for w in bytes_to_words_le(tag)],
        })

    write_words(out_dir / "rfc8439_case_info.txt", case_info_all)
    write_words(out_dir / "rfc8439_ct_all.txt", ct_all)
    write_words(out_dir / "rfc8439_tag_all.txt", tag_all)
    write_words(out_dir / "rfc8439_pt_all.txt", pt_all)
    write_words(out_dir / "rfc8439_src_encrypt_all.txt", src_encrypt_all)
    write_words(out_dir / "rfc8439_src_decrypt_all.txt", src_decrypt_all)

    with (out_dir / "rfc8439_summary.json").open("w", encoding="utf-8") as f:
        json.dump({
            "num_cases": args.num_cases,
            "max_msg_words": MAX_MSG_WORDS,
            "max_pt_words": MAX_PT_WORDS,
            "max_src_words": MAX_SRC_WORDS,
            "tag_words": TAG_WORDS,
            "seed": args.seed,
            "cases": metas,
        }, f, indent=2)

    with (out_dir / "rfc8439_summary.txt").open("w", encoding="utf-8") as f:
        f.write(f"NUM_CASES = {args.num_cases}\n")
        f.write(f"MAX_MSG_WORDS = {MAX_MSG_WORDS}\n")
        f.write(f"MAX_PT_WORDS = {MAX_PT_WORDS}\n")
        f.write(f"MAX_SRC_WORDS = {MAX_SRC_WORDS}\n")
        f.write(f"TAG_WORDS = {TAG_WORDS}\n")
        f.write(f"SEED = {args.seed}\n\n")
        for meta in metas:
            f.write(f"CASE {meta['case_id']}: {meta['name']}\n")
            f.write(f"ad_length  = {meta['ad_length']}\n")
            f.write(f"msg_length = {meta['msg_length']}\n")
            f.write("tag_words  = " + " ".join(meta["tag_words"]) + "\n\n")

    print(f"Generated {args.num_cases} case(s)")
    print(f"Message length per case: {args.msg_len} bytes")
    print(f"Output directory: {out_dir}")
    print("Set the same NUM_CASES / MAX_* localparams in tb_rfc8439_multi_4000.sv.")
    for meta in metas:
        print(f"CASE {meta['case_id']}: AD={meta['ad_length']}, MSG={meta['msg_length']}, TAG={' '.join(meta['tag_words'])}")


if __name__ == "__main__":
    main()
