# An unclamped indirect draw count hung an NVIDIA device

Status: **observed once, cause not confirmed.** The mitigation is confirmed on WARP and on the RTX 4070 Ti.

## Why it matters

GTA6-PC-Native's README describes the wall in the world like this. Draws whose GPU programs are not ready get
skipped, so their outputs are never written. Later GPU work reads that garbage ("e.g. indirect draw counts"),
runs past the 2-second GPU timeout, and the device resets. VIctory's README warns that "entering the world on a
real GPU can currently hang it". Both runtimes have a way to omit draws: `VICTORY_SKIP_PIPELINES`, and XCL
skipping untranslated pipelines.

This finding isolates the consumer side of that chain on a known, tiny workload, with no game data.

## Observation (experimental, single run)

- Hardware: NVIDIA GeForce RTX 4070 Ti, driver 32.0.16.2124, Windows 11 Pro 10.0.26300.
- Workload: `hgt-gfxdiag`, an `ExecuteIndirect` of full-screen draws with a `D3D12_INDIRECT_ARGUMENT_TYPE_DRAW`
  signature. `MaxCommandCount` = 5, the argument buffer holds 5 commands, and the count buffer holds `0xFFFFFFFF`.
- Result: the device was removed with `DXGI_ERROR_DEVICE_HUNG` (0x887A0006). In the same session, the same
  workload with counts 3 and 0 passed.
- On WARP (Microsoft Basic Render Driver), the same workload draws exactly 5, as D3D12 requires: the GPU runs
  `min(count, MaxCommandCount)` commands. With `HYBRIDGT_D3D12_DEBUG=1` the debug layer reports no errors for
  this command stream, only performance warnings.

Not established:
- whether it reproduces. It was deliberately not rerun, so as not to cause another driver reset;
- whether the driver ignores the clamp or something else in the same submission caused the hang;
- other NVIDIA drivers, AMD, Intel.

## Mitigation (confirmed)

`CountGuard::Clamp`: a one-thread compute pass writes `min(count, MaxCommandCount)` to a shadow count buffer,
behind a UAV barrier. `ExecuteIndirect` then reads the shadow.

| Case | WARP | RTX 4070 Ti |
|---|---|---|
| count 3 of 8, guard | 3 draws | 3 draws |
| count 0xFFFFFFFF, max 5, guard | 5 draws | 5 draws, no hang |
| produced count 2, guard | 2 draws | 2 draws |
| producer skipped, stale 0xFFFFFFFF, max 8, guard | 8 draws | 8 draws, no hang |
| producer skipped, outputs zeroed (no guard) | 0 draws | 0 draws |

The extra cost is one dispatch and two barriers per guarded `ExecuteIndirect`. The guarded submissions took
0.24–0.25 ms on the RTX 4070 Ti, the same as unguarded ones.

Note that "producer skipped, guarded" still runs 8 draws. Clamping keeps the GPU within the argument buffer, but
it does not make the frame correct. Zeroing a skipped producer's outputs gives 0 draws, which is the right
answer for a frame that has no data. A runtime needs both: zero what a skipped producer would have written,
and clamp what the title's own code hands to `ExecuteIndirect`.

## Reproduce

```powershell
cargo build -p hgt-gfxdiag
$env:HYBRIDGT_D3D12_DEBUG = "1"; .\target\debug\hgt-gfxdiag.exe                         # WARP
$env:HYBRIDGT_ADAPTER = "hw"; .\target\debug\hgt-gfxdiag.exe                             # hardware, unguarded garbage counts skipped
```

`HYBRIDGT_ALLOW_HANG_REPRO=1` also runs the unguarded cases on hardware. **This may reset the display driver.**

## Next

Check how XCL and VIctory handle indirect counts. Each runtime is either known to clamp them, known not to, or
not yet inspected; the matrix records which.
