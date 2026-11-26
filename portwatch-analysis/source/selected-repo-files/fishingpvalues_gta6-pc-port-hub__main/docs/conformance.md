# C-4 · Shared conformance corpus

**Question this answers:** how do we know two projects' console shims behave the same, without sharing game data?

Today each runtime project runs its own private test suite on its own hardware. `d3d12_xs` is reimplemented in at least six repos, `kernelx` in five, `xg_xs` tiling in five, BCPack in three, XMA2 in three, and RDNA2 lifting in six across two output targets (SPIR-V and DXIL). The same properties are measured repeatedly — and reported in incompatible units.

## Proposal

A corpus of **fixtures with expected outputs**, stored as small synthetic files plus hashes: no game data, no binaries from the title, reproducible on any machine.

```
corpus/
  d3d12-xs/        feature matrix: buffer views, root signatures, pipelines, draws,
                   placed resources, 1D textures, swapchain, MSAA in tiled layout,
                   hull/domain/amplification shaders, draw-time root-arg -> SGPR binding
  kernelx/         unified-memory aliasing vectors
  xg-xs/           tiling/swizzle vectors (bit-exact)
  wave64/          wave64-on-wave32 dword comparisons across adapters
  bcpack/          bitstreams for BC1/3/4/5/6H/7 with expected decoded hashes
  xma2/            decode vectors
  storage/         XVD / GDeflate cases (unencrypted only)
  <case>/manifest.json    { "input": "...", "expected": { "sha256": "..." }, "tolerance": 0 }
```

Rules:

- **Deterministic.** A fixture that needs a GPU says which vendor/driver it was produced on; CPU-only fixtures must be bit-exact everywhere.
- **Tiny.** Fixtures under a few hundred KB are what let projects vendor the corpus as a submodule.
- **Attributed.** Every expected output records `{project, commit, hardware, driver}` so a disagreement can be traced.
- **Free.** CC0 so GPL-2.0-only, GPL-3.0 and unlicensed projects can all consume it (see [C-5](license-matrix.md)).

## What the corpus already half-exists as

| Fixture | Lives in | Status |
| :--- | :--- | :--- |
| 60+ GPU hardware reports | `R0Y00/Xbox2Windows` #1, `OpenScarlett` #2 | private issue threads |
| 30+ GPU/driver matrix for wave64 | `ItsNotRexed/Leonida` #166 | private harness |
| 448/448 dword wave64 comparison | `californiaAlmonds/OpenScarlett` | private harness |
| 408 BVH queries × 60 adapters | `R0Y00/Xbox2Windows` | private harness |
| 749 programs at risk from wave size | `ivall/xcl` | private harness |
| 909/912 retail texture detile match | `ivall/xcl` | private harness |
| 51/51 and 66/66 CTest suites | `OpenScarlett` | private repos |

The goal is not to move anyone's tests — it is to give them one shared fixture for the parts they all test, and one public results table instead of four private ones.

## Results table (to be filled)

| Case | Xbox2Windows | xcl | OpenScarlett | xbox-emulator | Leonida | xvalkyrie |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| wave64 dwords | — | — | — | — | — | — |
| tiling bit-exact | — | 909/912 | — | — | — | — |
| d3d12_xs feature matrix | — | — | — | — | — | — |

## Tasks

- [ ] Pick the 3 highest-value cases (wave64, tiling, `d3d12_xs` feature matrix) and write their `manifest.json` schema.
- [ ] Publish one fixture per case with an expected hash.
- [ ] Ask each project to run the fixture and open a `C-4: result` issue.
- [ ] Publish the filled table here, with hardware attribution.
