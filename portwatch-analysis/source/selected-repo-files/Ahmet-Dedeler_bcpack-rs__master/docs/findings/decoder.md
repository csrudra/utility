# Findings: decoder (consolidated BC1 decoder)

Agent `decoder`, 2026-11-22. This branch replaces the earlier, wrong decoder with one built from the solved
research pieces (branches `probe`, `sem-endpoints`, `sem-indices`, `harness`, `patent`). All numbers below are
on retail Xbox Series texture pools; nothing derived from them is committed.

## What was built

- `src/rans.rs`: clock-for-clock port of the probe agent's cycle-level simulator (itself a port of the
  `decoder` module of Microsoft's `mdu_minirans.v`), feeder 8 bytes per clock in lane order, lockstep symbol
  vectors, legal end-state check, error unless every lane converges. Two versions: a reference one generic over
  the byte source (used by the encoder to learn the interleave), and a branch-light slice version used for
  decoding. Tests check they agree clock for clock.
- `src/bc1.rs`: back-reference endpoints (sem-endpoints rule), preset window from `data/bc1_window.json`,
  quadrant codebook from `data/bc1_quad_table.json` (sem-indices), BC1 index bit layout as in sem-indices'
  `psnr.py` (`index_word`).
- `src/ttpf.rs`: store/ETPF reader, Gfx10 mip chain and detiling (port of the harness `ttpf.py`, itself from
  ttpf-viewer), BC1 to RGBA, DDS/PNG.
- `src/encode.rs`: synthetic encoder (per-fragment reverse rANS + feeder replay). `python/bcpack.py`: pure-Python
  mirror. Tables generated from the Verilog with a checked SHA-256.

## Checks

| Check | Result | Command |
|---|---|---|
| Rust vs research pipeline (probe `mdusim.simulate` + `endpoints.decode_window(resid="zigA", zero_mode="zero", history=window)` + quad table), byte for byte | 520/520 identical (52 stores, 1,024-16,384 blocks, seed 7) and 12/12 identical on 32,768-65,536-block chunks | `tools/retail/crosscheck.py 520 7 16384` |
| Python mirror vs probe simulator | identical symbols on 4/4 sampled chunks | (spot check) |
| Convergence scan, every 20th BC1 chunk of all 57 pools | 5,162/5,162 converge; consumed == stored length - pad in 5,162/5,162; 2,396 touch no unfitted window slot | `bcpack scan --jobs 8 --every 20 <57 stores>` |
| Mip consistency, 600 random pair textures (side <= 1024, seed 1) | 0 decode errors. No unfitted slot (301): median 35.10, p10 25.31, p90 42.31 dB, 28 below 25 dB, 66 not above flat + 3 dB. Touching an unfitted slot (299): median 9.06, p10 6.24. All: median 27.63, p10 7.31; flat baseline median 22.64 | `tools/retail/mip_e2e.py 600 1 1024` |
| Speed | 34-40 MB/s BC1 output per core (CPU time; 4.3-5.0 M blocks/s; 1.22-1.28 clocks per block) | `bcpack bench chunk.bin N` |

The machine was heavily shared during all runs (load average 60-190 on 18 cores), so wall-clock numbers are
not meaningful; `bench` reports thread CPU time.

## Update: full preset window (254/256 slots)

Imported from the endpoint-window fit (`tools/import_tables.py --window window_table.json`).

| Check | Result |
|---|---|
| Rust vs research pipeline (same window values on both sides) | 520/520 identical (52 stores, seed 8) |
| Scan, every 20th BC1 chunk of all 57 pools | 5,162/5,162 converge; 5,161 touch no unfitted slot |
| Mip consistency, same 600 textures | 600/600 touch no unfitted slot; median 35.39, p10 30.17, p90 41.81 dB; 3 below 25 dB; 18 not above flat + 3 dB (flat median 22.64) |

## The 5 chunks the research simulator called non-converging

`terrain_0_7:15340` (8,192 blocks), `terrain_0_7:3804` (4,096), `maps_4_7:43730` (4,096), `maps_7_7:35278` (2,048),
`terrain_5_7:16421` (2,048). **The Rust decoder decodes all 5**: every lane legal, all symbols, consumed bytes =
stored length. Their mip-0 textures score 37.2, 32.1, 34.4, 35.3 and 28.7 dB (flat 17.0-24.1), so the output is right.

What they share: no trailing pad (`b >> 20 = 0`, last byte non-zero), so the stream ends exactly at the stored
length. The probe simulator's early-exit test `starved` (input exhausted and every lane either done or waiting for
a byte) fires one clock too early there: all 12 lanes are done, but one lane still holds its last symbol in its
output buffer because its slot is full until the final vector is released. Example `maps_7_7:35278`: probe returns
`why=starved`, lane 11 has 2,047/2,048 symbols with a legal final state. So it is a bug in the simulator's stop
condition, not a format exception. The Rust port only stops on "all lanes done and drained", "no progress for 64
clocks" or the cycle limit.

## Speed notes

The decoder is a clocked simulation: about 1.25 clocks per block, each clock touching all 12 lanes twice.
Tried: a 256-entry coarse inverse table, a full 64K inverse LUT per model (slower: cache misses on the
critical path), a branch-free inverse (count of segment thresholds; checked equal to the Verilog comparator
chain for all 9 x 16 x 65,536 inputs). The current version is ~35-40 MB/s per core, below the 50 MB/s aim.
A faster design would decode lanes independently (each lane's bytes are self-contained once the interleave
order is known) and only simulate the feeder's request order, which needs a cheaper model of when each lane
requests bytes.

## What is left

1. Preset window: done (2026-11-24, issue #4). 74 fitted slots and slot 4 were replaced with the format's constant dictionary values; slot 0 does not exist. `tools/retail/mip_e2e.py 600 1`: median 35.39 -> 35.52 dB, p10 30.17 -> 30.72, below 25 dB 3 -> 0, not above flat + 3 dB 18 -> 16; per texture 44 better, 27 worse (largest loss 0.30 dB, largest gain 12.31 dB), 529 unchanged. `tools/import_tables.py --window` would overwrite these with fitted values, so don't rerun it for the window.
2. The 4 uncertain codebook mirror pairs; 3-colour blocks fit worse than 4-colour ones.
3. Speed (above). Other BCn formats.
