# bcpack-rs

Decoder for **BCPack**, the rANS entropy codec that the Xbox Series X|S Media Decompression Unit (MDU) uses for block-compressed (`BC1`-`BC7`) textures. Rust crate and CLI, a stdlib-only Python reference decoder, and a written spec ([`docs/BCPACK_SPEC.md`](docs/BCPACK_SPEC.md)).

<p align="center">
  <a href="https://discord.gg/CjcDBg3nf"><img src="https://img.shields.io/badge/Join%20the%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Join the Discord" height="36" /></a>
  <br />
  <sub>Questions, previews, bug reports and format research. Come say hi.</sub>
</p>

Licensed under `MIT OR Apache-2.0`. The repository contains no game data; all tests use synthetic streams.

## Status

**BC1, BC3, BC4, BC5 and BC7 decode in the Rust library and CLI.** The synthetic stream encoder and whole-texture DDS export support all five formats. PNG export, store scanning and the Python reference handle BC1. **BC6H** has its entropy layer solved (16 lanes in `src/format.rs`), with block rebuild not implemented yet.

| Part | Status |
|---|---|
| Entropy layer (rANS) | **Exact.** Microsoft's MDU tables from the public [`silicon-rans`](https://github.com/microsoft/silicon-rans) Verilog (MIT), a clock-for-clock port of its lane decoder, bytes fed in lane order (8 per clock) with all lanes (12 or 16) in lockstep. Every lane must consume exactly its byte budget and end in a legal state, so a wrong rule fails loudly |
| BC1 (`bcpack::bc1`, CLI, Python) | **Decodes.** Endpoints verified (back-reference distance + zigzag residuals), complete 255-entry preset window (`data/bc1_window.json`), fitted 256-entry quadrant index codebook (`data/bc1_quad_table.json`; two independent fits agree on 248/256 entries, 99.76% of quadrants, 8 rare mirror pairs uncertain). Stream order = standard Gfx10 tiled order |
| BC3, BC4, BC5 (`bcpack::bcn`) | **Decodes.** Exact block rebuild rules and complete constant tables (`data/bc3.json`, `bc4.json`, `bc5.json`: 64-entry alpha pair ranks, BC3 256-entry colour quadrant ranks, 255-entry dictionaries). Byte-identical to a reference decoder on all 35 BC3 (660,992 blocks), 77 BC4 (201,728 blocks) and 333 BC5 (4,890,368 blocks) chunks across 57 stores, and independently validated on 100 BC5 + 1 BC3 chunks in issue #5. |
| BC7 (`bcpack::bc7`) | **Decodes.** 16 lanes (widths `4,4,8,8,8,8,8,7,7,5,6,8,8,8,8,5`), two symbols per lane per 16-byte block, exact block rebuild, all 285 control codes and the 255-entry single-subset dictionary (`data/bc7.json`). Byte-identical to a reference decoder on all 5,167 BC7 chunks (80,055,040 blocks) across 57 stores, and independently validated on 28 chunks in issue #5. |
| BC6H (`bcpack::format::Mode::Bc6h`) | **Entropy layer only.** 16 lanes (widths `4,4,8,8,8,5,5,5,6,6,6,8,8,8,8,5`); every chunk in the corpus converges at the rANS layer. Block rebuild not implemented yet |

### Verified numbers (this decoder)

All measured on retail Xbox Series texture pools with the commands in [Reproducing](#reproducing) (plus `docs/findings/bc345-bc7.md`). No game data is in this repository.

| Check | Result |
|---|---|
| BC3 / BC4 / BC5 / BC7 chunk decode vs reference decoder (all 57 stores, `data/bc{3,4,5,7}.json`) | **0 differing blocks** across **5,612 chunks / 85.8 M blocks**: BC3 35 chunks (660,992 blocks), BC4 77 (201,728), BC5 333 (4,890,368), BC7 5,167 (80,055,040). Independent check on issue #5 (129 chunks: 1 BC3, 100 BC5, 28 BC7; 651,264 blocks): 129/129 decode cleanly, 0 unknown BC7 controls, mip MAE matching plain baselines |
| BC1 exact convergence (`bcpack scan --every 20`, every 20th BC1 chunk of all 57 pools) | **5,162/5,162** chunks (97.9 M blocks): all 12 lanes end in a legal state with exactly `blocks` symbols, and the bytes consumed equal the stored length minus the pad in 5,162/5,162. 5,161 touch no unfitted preset-window slot |
| BC1 Rust vs the Python research pipeline (probe simulator + endpoint rule + codebook), byte for byte | **520/520** chunks identical, sampled round-robin across 52 stores (1,024-16,384 blocks), plus **12/12** chunks of 32,768-65,536 blocks |
| BC1 mip consistency, 600 random pair textures (BCPack mip 0 decoded, downsampled 2x, compared with the plain mip 1) | 600/600 decode, none touching an unfitted window slot. Median **35.5 dB**, p10 30.7, p90 42.0 (flat mean-colour baseline 22.6); 0 below 25 dB, 16 not at least 3 dB above flat. With the purely fitted window the same set scored median 35.4, p10 30.2, 3 below 25 dB. With only the first 16 window slots the same set scored median 27.6, p10 7.3 |
| BC1 held-out check of the fitted tables (fit on half the texture pools, decode the other half) | Preset window fitted on even pools, scored on odd: 1,514 textures, median **34.7 dB**, p10 29.7. Reverse: 1,481 textures, median **34.0 dB**, p10 28.7. In-sample on all: 34.4 dB. The two half-fits agree within ±1 on 228/249 slots (99.9% of blocks by use). Index codebook fitted on half the pools: 36.6 / 36.1 dB held out, 248/256 entries identical between halves. 200 random textures larger than 512 px: 200/200 decode, median 37.4 dB. Plain BC1 ceiling on the same test: 37.9 dB |
| BC1 speed | **34-40 MB/s of BC1 output per core** (4.3-5 M blocks/s, 25 MB/s compressed input), CPU time, `bcpack bench` on 4,096- and 65,536-block chunks. Chunks decode independently, so `scan` scales across cores (8 threads on a heavily shared machine: about 110 MB/s). Below the 50 MB/s per-core target |

The plain-BC1 ceiling of the mip-consistency check is about 37.9 dB median. The 5 chunks the research simulator reported as non-converging decode here (see `docs/findings/decoder.md`).

### Research branches

The work happened in parallel branches. Each has a findings doc in `docs/findings/`. `master` consolidates the BC1 decoder and the `bc5-bc7` block rebuild work (`docs/findings/bc345-bc7.md`).

| Branch | What it holds |
|---|---|
| `patent` | Reference decoder with tables generated from Microsoft's `mdu_minirans.v`, patent (`US11234023B2`) notes |
| `prior-work` | Public BCPack facts collected from other projects, with contradictions noted |
| `probe` | Cycle-level multi-lane MDU simulator, BC1 convergence scan over 15,000 chunks |
| `harness` | Shared test bench: corpus index, convergence oracle, mip-consistency scorer |
| `sem-indices` | The 256-entry quadrant index codebook and its held-out checks |
| `sem-endpoints` | Endpoint rule, preset-window fitter, full BC1 decode + scoring |
| `other-formats` | BC7 entropy layer |
| `bc5-bc7` | BC3, BC4, BC5 and BC7 block rebuild and constant tables (merged into `master`) |
| `decoder` | Consolidated Rust BC1 decoder, Python reference, spec (merged into `master`) |

None of the branches contain game files or decoded textures. Scripts read textures from your own copy at run time.

## Usage

CLI:

```bash
cargo build --release
bcpack decode-bc1 chunk.bin 4096 out.bc1        # chunk bytes (zero pad allowed) + block count
bcpack decode-bc5 chunk.bin 4096 out.bc5        # decode-bc3, decode-bc4 and decode-bc7 work likewise
bcpack symbols --format bc5 chunk.bin 4096      # one line per lane (default format: bc1)
bcpack ttpf-export pool.ttpf 318 out.png        # mip 0 of a BC1 texture, decoded + detiled (.png or .dds)
bcpack scan --jobs 8 --every 10 pools/*.ttpf    # convergence and speed over stores
bcpack ttpf-export pool.ttpf 318 out.dds        # mip 0 in BC1, BC3, BC4, BC5 or BC7
bcpack bench --format bc7 chunk.bin 4096        # single-core speed (default format: bc1)
```

`--window file.json` and `--quads file.json` replace the built-in BC1 tables, so a newer fit can be tried without rebuilding. `tools/import_tables.py` converts fit outputs into the `data/` format.

Library (BC1, BC3, BC4, BC5 and BC7):

```rust
// BC1 (8 bytes per block)
let window = bcpack::bc1::Window::default_table();
let quads = bcpack::bc1::QuadTable::default_table();
let bc1_out = bcpack::bc1::decode(&chunk, blocks, &window, &quads)?; // blocks * 8 bytes

// BC3 / BC4 / BC5 (`unpacked_len` is the chunk's virtual byte length)
let bc5_tables = bcpack::bcn::Tables::default_for(bcpack::format::Mode::Bc5).unwrap();
let bc5_out = bcpack::bcn::decode(&chunk, unpacked_len, bc5_tables)?;

// BC7 (`unpacked_len` is the chunk's virtual byte length)
let bc7_tables = bcpack::bc7::Tables::default_table();
let bc7_out = bcpack::bc7::decode(&chunk, unpacked_len, bc7_tables)?;
```

To embed only the decoder, turn off the default features. The library then depends on `serde_json` alone:

```toml
bcpack-rs = { git = "https://github.com/Ahmet-Dedeler/bcpack-rs", default-features = false }
```

Features: `ttpf` adds the RDS5 store reader, Gfx10 detiling, whole-texture decode and PNG output (`flate2`, `png`; PNG for BC1). `cli` (default) adds the `bcpack` tool on top (`rayon`).

Python reference (BC1, slow, readable): `python3 -I python/bcpack.py decode-bc1 chunk.bin 4096 out.bc1`.

## Layout

- `src/rans.rs`: the clocked MDU rANS decoder (12 or 16 lanes; a reference version generic over the byte source, and a fast slice version; tests check they agree)
- `src/format.rs`: mode metadata (BC1/BC3/BC4/BC5/BC6H/BC7), lane widths, back-reference and dictionary addressing
- `src/bc1.rs`: lane symbols to BC1 blocks (back references, preset window, quadrant codebook)
- `src/bcn.rs`: lane symbols to BC3, BC4 and BC5 blocks (pair ranks, BC3 quadrant ranks, 255-entry dictionaries)
- `src/bc7.rs`: lane symbols to BC7 blocks (control codes, 255-entry dictionary, BC7 block pack/unpack)
- `src/ttpf.rs`: RDS5 stores, ETPF texture index, Gfx10 mip layout and detiling, BC1 to RGBA, DDS/PNG
- `src/encode.rs`: synthetic stream encoder for tests (reverse rANS per fragment, interleaved by replaying the feeder)
- `src/tables.rs`, `python/bcpack_tables.py`: generated from `mdu_minirans.v` by `tools/gen_tables.py`
- `data/`: built-in constant tables (`bc1_window.json`, `bc1_quad_table.json`, `bc3.json`, `bc4.json`, `bc5.json`, `bc7.json`)
- `python/bcpack.py`: BC1 reference decoder, pure Python

## Tests

```bash
cargo test --release
python3 -I python/bcpack.py selftest
```

The Rust tests check the Verilog table checksum, that the reciprocal inverse equals exact division for every model and cf, synthetic round trips through the encoder (random symbols, all 16 models, alphabet narrowing, 2- and 3-byte headers, multi-fragment lanes, padding, truncation), that the fast and reference decoders agree clock for clock, the block assembly on a hand-built case, and golden SHA-256 hashes of decoded synthetic output. The Python self-test decodes the same synthetic vectors (`tests/vectors/`) and must match. Synthetic tests show the decoder is self-consistent; agreement with hardware comes from the retail checks above.

## Reproducing

The retail checks need your own copy of the texture pools; point the harness at it with `BCPACK_GAME_ROOT`. The bench scripts live on the `harness` branch (`tools/bench`).

- convergence: `bcpack scan --jobs 8 --every 20 $BCPACK_GAME_ROOT/data/ttdb/**/*.ttpf $BCPACK_GAME_ROOT/pack/*/data/ttdb/**/*.ttpf`
- mip consistency: decode each pair texture's mip-0 chunk with `bcpack decode-bc1` and score with `tools/bench/mipscore.py score TEXTURE_ID out.bc1 --order stream`

## Credits

- Microsoft [`silicon-rans`](https://github.com/microsoft/silicon-rans) (MIT): the reference MDU rANS decoder and its exact model tables. See `THIRD_PARTY_NOTICES.md`. The same design is described in patent US11234023B2.
- SixNG format notes (holdmysocks, walkthestars, TrinitronClient and contributors): RDS5/ETPF container, chunk table, Gfx10 layouts, BCPack header observations.
- Xbox2Windows (R0Y00) and MarlomMedeiros' corpus-wide BCPack measurements (issue #15): fixed 8-byte rounds, demand-driven refills, the 2/3-byte length flag, lane-dependent constant models.
- Leonida (Kam471): per-codec chunk counts and size statistics across all pools.
- paryzius' ttpf-viewer: exact Gfx10 detiling and mip-tail placement, ported in `src/ttpf.rs`.

## Related projects

- [Percy6Stars](https://github.com/Ahmet-Dedeler/Percy6Stars): RPF9/TTPF archive explorer for macOS and Windows
- [awesome-gta6-reverse-engineering](https://github.com/Ahmet-Dedeler/awesome-gta6-reverse-engineering): every open-source GTA VI reverse engineering project in one list
- [rage9-re](https://github.com/Ahmet-Dedeler/rage9-re): `script.rpf` and `anim.rpf` decoder with glTF export
- [bink-player-mac](https://github.com/Ahmet-Dedeler/bink-player-mac): Bink 2 (`.bk2`) video player for macOS
- [weather-study](https://github.com/Ahmet-Dedeler/weather-study): WebGL2 weather and timecycle visualizer

Questions, previews and format research: [join the Discord](https://discord.gg/CjcDBg3nf).
