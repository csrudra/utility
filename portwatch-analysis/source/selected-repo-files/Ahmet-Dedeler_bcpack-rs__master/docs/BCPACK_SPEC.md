# BCPack BC1: format specification

This describes the BCPack stream format for BC1 textures (codec id `0x04`) as used in retail Xbox Series texture pools, at the level needed to write a decoder. Each section states how sure we are and what the evidence is. The reference implementation is `src/` (Rust) with a readable mirror in `python/bcpack.py`.

Status words used below:

- **exact**: taken from Microsoft's published reference RTL, or reproduced bit for bit on retail data with a check that a wrong rule fails;
- **verified**: confirmed on retail data by a statistical check with controls (mip consistency), not bit-exact by construction;
- **fitted**: constants estimated from retail data; mostly right, some entries uncertain or missing.

Earlier versions of this file described fitted exponential frequency tables (`lambda(q)`), a hand-derived lane read schedule and a guessed block assembly. All three were wrong and are gone. The exact tables come from the Verilog (section 3), and the read schedule falls out of the clocked lane model plus the feeder rule (section 4).

## 1. Container

A texture pool is an `RDS5` store. A chunk is a range of the store's virtual (unpacked) address space; one texture's mip chain can span several chunks, and one chunk can hold parts of several textures.

| Field | Meaning |
|---|---|
| `0x00` | `RDS5` |
| `0x04` u32 | n, number of chunk table entries (the last one is an end marker) |
| `0x08` u32, `0x0C` bits 0-7 | virtual size |
| `0x10` u32 | ETPF texture index offset / 256 |
| `0x18` | n entries of (u32 a, u32 b) |

Entry i describes chunk i, which runs to entry i + 1 in both address spaces:

- file offset `(a & 0x3FFFFFF) << 8`
- codec `(a >> 24) & 0x3C`: `0x00` stored, `0x20` zlib, `0x04` BC1 BCPack (`0x0C` BC3, `0x10` BC4, `0x14` BC5, `0x18` BC6H, `0x1C` BC7)
- virtual offset `((a >> 30) | (b & 0xFFFFF) << 2) << 12`
- `b >> 20`: zero bytes of padding at the end of the stored chunk

A BC1 BCPack chunk holds `virtual_length / 8` BC1 blocks. The ETPF index (`ETPF`, count at +8, then 16-byte descriptors and 8-byte hashes) gives width, height, mip count, DXGI format, array size, tile mode and virtual start of each texture.

Sources: SixNG format notes (`formats/05-ttpf.md`), paryzius' ttpf-viewer, Leonida `docs/textures.md`. Status: **exact** (the decoder's consumed byte count equals `stored length - pad` on every converged chunk of the scan in the README).

## 2. Stream structure

A BC1 chunk is one byte stream shared by **12 lanes**. Each lane is an independent rANS decoder that emits exactly one symbol per block:

| Lane | Symbol width | Verilog `alphabet_bits` | Content |
|---|---|---|---|
| 0 | 8 | 7 | endpoint delta, added to the index reference (section 5.1) |
| 1 | 8 | 7 | index reference `x` (blocks back, 0 = none); 0 in every retail chunk measured so far, but the format allows it (see below) |
| 2-7 | 5, 6, 5, 5, 6, 5 | 4, 5, 4, 4, 5, 4 | residuals of R0 G0 B0 R1 G1 B1 (section 5.2) |
| 8-11 | 8 | 7 | index codebook symbols for the 2x2 quadrants TL, TR, BL, BR (section 5.4) |

Every lane's symbol count (`out_target` in the Verilog) is the chunk's block count. There are no sub-streams: chunks of 1,536, 3,072 and 65,536 blocks are single streams whose lanes simply use more fragments. (Splitting a 65,536-block chunk into two 32,768-block streams, as reported for BC7, fails on 36/36 BC1 chunks.)

Status: **exact**. Every lane of 15,000 chunks sampled across all 57 stores (1,024 to 131,072 blocks) emits exactly `blocks` symbols, consumes exactly its byte budget and ends in a legal state; changing a lane width, the lane count or the symbol count breaks this.

## 3. One lane: the MDU rANS decoder

Each lane is the `decoder` module of Microsoft's `mdu_minirans.v` (github.com/microsoft/silicon-rans, MIT license), which is also printed as FIGS. 14-15 of patent US11234023B2. The decoder here is a clock-for-clock port.

**Fragments.** A lane's bytes are a sequence of fragments, each with an in-band header:

```
hdr0: bits 7:6 = z     alphabet narrowing: eab = alphabet_bits - z (clamped; eab > 8 is an error)
      bit 5    = hdr3  1: 16-bit length follows, 0: 8-bit length
      bit 4    = flush reset the rANS state to 0 when this fragment ends
      bits 3:0 = q     static model 0..15
hdr1: hdr3 = 0: payload length = hdr1 + 1
      hdr3 = 1: payload length = (hdr2 << 8 | hdr1) + 257   (hdr2 is a third byte)
```

The payload length counts every byte the lane reads in that fragment, including the initial state bytes.

**State and renormalisation.** 32-bit state x, `L = 2^24`, 16-bit probabilities. A fragment starts from x = 0 (after a flush) and reads bytes `x = (x << 8 | byte) mod 2^32` while `x < L` and payload remains, so the first four bytes form the big-endian initial state. A symbol is produced when `x > L` and symbols remain. Decode step for model (eab, q):

```
cf  = x & 0xFFFF
s   = inverse(cf)                         # comparator chain + reciprocal multiply
f, c = forward(s)
x   = f * (x >> 16) + cf - c   (mod 2^32)
```

**Models.** For alphabet index `eab` (alphabet of eab + 1 bits) and model q, symbols are grouped in segments: segment 0 is symbol 0, segment k >= 1 is symbols [2^(k-1), 2^k). Each segment has a base (cumulative frequency) and a per-symbol frequency; slot 0 is reserved, so a symbol whose cumulative frequency would be 0 gets `(f - 1, 1)`. The inverse uses the Verilog's reciprocal path `steps = ((cf - base + rn) * rf >> 15) >> rs`. All five tables (`base`, `freq`, `rf`, `rs`, `rn`, 9 x 16 x 10 each) are generated from the Verilog source by `tools/gen_tables.py` into `src/tables.rs` and `python/bcpack_tables.py`, with a SHA-256 checked by both test suites. A unit test checks that the reciprocal inverse equals exact division for every cf of every model.

**End of a fragment.** When the payload is exhausted: if x = L, the next fragment header follows; otherwise the lane drains (keeps emitting without reading) until x <= L. **End of the lane**: after its last symbol a lane's state must be `L`, `L >> 8` or `L >> 16` (the encoder may drop up to two trailing zero bytes). Anything else is an error.

Status: **exact** (Microsoft RTL). The retail check: under these tables every lane of every sampled chunk converges; under the earlier fitted `lambda(q)` tables 0/120.

## 4. Lanes sharing one stream: feeder and lockstep

The published Verilog has one lane. How 12 lanes share one stream was established on retail data:

1. **Clocking.** Each clock has two phases. Phase 0: a lane that holds a decoded symbol hands it to its output slot and applies the state update; lanes that want a byte request one. Phase 1: header state machine, renormalisation and symbol decode. (`src/rans.rs` has the exact per-phase rules, ported from the Verilog's `always` blocks, including stall conditions.)
2. **Feeder.** In phase 0, the lanes requesting a byte are served in lane order 0, 1, ..., 11 from the single stream, **at most 8 bytes per clock** (`MDU_RANS_FEED_WINDOW = 8`). A lane that requests and is not served stalls for that clock.
3. **Lockstep output.** Each lane has one output slot and may only hand over a symbol while its slot is empty. The 12 slots are released together once every lane that is still active holds a symbol. So symbol vectors leave one block at a time.

Nothing else is needed: the column-interleaved 48-byte header, the "round 6/7" behaviour and the demand-driven refills that earlier work described all follow from these rules.

Status: **exact**. 15,000/15,000 sampled chunks converge on all 12 lanes; 0/120 converge when any one rule changes (window 7, 9 or 16; serving lanes in reverse order; serving index lanes first; letting lanes run free instead of lockstep; block count +-1).

## 5. BC1 semantics

Blocks are produced in stream order, i = 0 .. blocks - 1.

### 5.1 Lane 0: back reference

```
d = (v >> 1)          if v is even        # 0, 1, 2, ... 127
    255 - (v >> 1)    if v is odd         # 255, 254, ... 128
```

i.e. `d = unzigzag(v) mod 256`. d = 0 means "no reference" (predict zero). Otherwise the prediction P is the six endpoint fields of block `i - d`.

That is the case lane 1 = 0. In general (the same rule as the BC3, BC4 and BC5 lanes, [`format::references`]): lane 1 is the **index reference** `x`, and the endpoint reference is `d = (x + unzigzag(lane 0)) mod 256`. Each pixel's index residual (section 5.4) is added along the endpoint line (codes 0, 2, 3, 1 = positions 0, 1, 2, 3), modulo 4, to the same pixel of block `i - x`. An index reference before block 0 has no known table yet: it reads zero and the block counts as unfitted. Lane 1 was 0 in every retail chunk measured, so this changes no retail output; it matters for streams that use it, such as other encoders' output. Reported in issue #10 with a two-block case, which is now `tests/roundtrip.rs::bc1_lane1_index_reference`.

### 5.2 Lanes 2-7: endpoint residuals

```
r = -(s + 1) / 2   if s is odd,  s / 2 if s is even        # zigzag 0, -1, +1, -2, +2, ...
field[k] = (P[k] + r) mod 2^width[k]                       # widths 5 6 5 5 6 5
c0 = R0 << 11 | G0 << 5 | B0      c1 = R1 << 11 | G1 << 5 | B1
```

Fields never mix (endpoint 1 is predicted from the reference's endpoint 1). There is no swap flag: c0 <= c1 (3-colour mode) occurs and is written as decoded.

Status: **verified**. On textures without references before block 0, the decoded endpoints lie on the plain mip 1 colours at control level (median segment distance 0.4 vs 0.8 for true BC1 endpoints; 8/8 textures); every other predictor and residual map tested scores at chance.

### 5.3 References before block 0: the preset window

When d > i the reference points before the chunk. It reads slot `(i - d) mod 256` of a **fixed 256-entry table of endpoint fields**, the same for every chunk. The table is not in the stream. The decoder loads it from `data/bc1_window.json`, where each slot is `[R0, G0, B0, R1, G1, B1]` or `null` (not fitted yet; decoded as zeros, and the decoder reports how many blocks depend on such slots).

Status: **complete (fitted, then corrected against a reference)**. The values were first fitted against mip consistency, which gave 254 slots. Compared with the format's constant BC1 dictionary as a reference decoder carries it (255 entries standing for blocks -1 to -255, so slot 0 does not exist), 180 fitted slots were equal, 74 were off by an L1 distance of 1 to 8, and slot 4 had never been referenced. Those 75 now hold the reference value; on the 600-texture mip check the median moved from 35.39 to 35.52 dB and the textures below 25 dB from 3 to 0. The notes below describe the original fit. Slot 242's single value fits 100/100 textures that use it, and fits on two halves of the data agree. With the full table, 600/600 random pair textures decode at a 35.4 dB median against the plain mip 1. The entries look like a trained codebook of common endpoint pairs and follow no formula of the slot index.

### 5.4 Lanes 8-11: index quadrants

Lane 8 covers pixels (0..1, 0..1) of the block, lane 9 (2..3, 0..1), lane 10 (0..1, 2..3), lane 11 (2..3, 2..3). Each symbol indexes a **fixed 256-entry codebook** of 2x2 patterns of BC1 2-bit codes, given in the order TL, TR, BL, BR of the 2x2 group. The table is a bijection onto all 4^4 patterns, ordered roughly by frequency. The index word puts pixel (x, y) at bits `2 * (4y + x)`:

```
index = 0
for quadrant q in (TL, TR, BL, BR) with origin (ox, oy) in ((0,0), (2,0), (0,2), (2,2)):
    codes = CODEBOOK[lane[8 + q][i]]                 # [tl, tr, bl, br]
    for k, (dx, dy) in enumerate(((0,0), (1,0), (0,1), (1,1))):
        index |= codes[k] << 2 * (4 * (oy + dy) + ox + dx)
```

Symbols 0-3 are the uniform quadrants with code `sym ^ 2` (0 = all code 2, 1 = all code 3, 2 = all c0, 3 = all c1). Index lanes are not predicted from the referenced block.

The codebook is `data/bc1_quad_table.json`. Status: **fitted**; symbols 0-3 measured exactly. Fits on disjoint halves of the stores agree on 248/256 entries (99.76% of quadrant occurrences); the 8 that differ are 4 rare mirror pairs (229/235, 230/231, 247/248, 254/255). Held-out decodes score 36.1-36.6 dB median against the plain mip 1, against a 37.9 dB ceiling for plain BC1.

### 5.5 Block order

Stream order is the texture's stored order, i.e. the AMD Gfx10 tiled order (64 KiB `SW_64KB_D` tiles for tile mode 0, 4 KiB `SW_4KB_S` otherwise; in-tile bit order for 8-byte elements `x0 y0 x1 x2 y1 y2 x3 y3 x4 y4 x5 y5 x6` and `x0 y0 y1 x1 x2 y2 x3 y3 x4`). The decoded chunk can replace the BCPack chunk's virtual bytes directly; detiling is the same as for zlib chunks (`src/ttpf.rs`, a port of ttpf-viewer).

Status: **verified** (Gfx10 order beats row-major in 3,243/3,244 textures on a quadrant-consistency statistic).

## 6. What is not known

- The 4 uncertain codebook pairs (5.4). The index codebook has not been compared with a reference yet.
- 3-colour blocks (c0 <= c1) fit mip 1 worse than 4-colour blocks; no separate table was found.
- Other codecs. BC7 uses 16 lanes (widths `4,4,8,8,8,8,8,7,7,5,6,8,8,8,8,5`) under the same entropy layer; its block semantics are open. BC3/4/5/6H are not started.

## 7. Encoding

The hardware encoder is not public. `src/encode.rs` builds valid streams for tests: each lane is split into flushed fragments, each encoded as a reverse rANS stream from state L, and the per-lane streams are interleaved by running the decoder with per-lane byte queues and recording which lane takes each byte. That works because the feeder only looks at lane states.
