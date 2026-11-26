# Test results

2026-11-24, Windows 11, RTX 4070 Ti, DXC on PATH.

| Suite | Adapter | Result |
|---|---|---|
| `cargo test --workspace` | WARP | 27 passed, 0 failed |
| `cargo test -p hgt-gfxdiag wave64` (compute + mesh) | RTX 4070 Ti (`HYBRIDGT_ADAPTER=hw`) | pass: host 32 lanes, native ballot ≠ console, two-half emulation = console in both stages |
| `hgt-gfxdiag` binary | RTX 4070 Ti | all PASS; view-heap cap 1,000,000 |
