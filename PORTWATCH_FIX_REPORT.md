# PortWatch / public GTA VI PC-port fix audit

**Generated:** 2026-11-26 UTC  
**Starting point:** [https://portwatch-vi.xyz/#toolkit](https://portwatch-vi.xyz/#toolkit) and the public site source [`4lwayz/portwatch-vi`](https://github.com/4lwayz/portwatch-vi).  
**User priority:** NVIDIA first, AMD checked too.  
**Main deliverables:** this report, [`PORTWATCH_FIX_MATRIX.csv`](PORTWATCH_FIX_MATRIX.csv), and the durable research bundle in [`portwatch-analysis/`](portwatch-analysis/README.md).

> **Scope correction (2026-11-27):** this report contains historical statements about the workspace that were inaccurate for the current checkout. The repository has a Windows harness and research artifacts, but still has no game renderer/runtime source. See [`harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md`](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md) for a current code review and live upstream check.
>
> **Evidence warning:** FPS, RAM, VRAM, and stability results below are predominantly author-reported and come from non-matched forks, machines, scenes, and dates. They were not independently reproduced in this review. Treat the inventory as a historical research index, not a performance forecast, hardware recommendation, current ranking, or copy-paste configuration. Any imperative recommendation preserved in later sections is not validated for a particular machine and must be checked against the exact source and tested before use.

---

## 0. Bottom line

1. **Largest public NVIDIA FPS report found in this survey:** [`lucas-TagDev/VKarameloVI`](https://github.com/lucas-TagDev/VKarameloVI) `main` reports about **20–22 fps** in the prologue on one RTX 5070 12 GB system, with no device losses in the reported runs. Its source combines Series S + 0.5 render scale + the title's own upscaler, no stale BVH walks, GPU-side memory compares, a larger NVIDIA-safe descriptor pool, 1080p/interface composition, prewarmed shaders, and a curated switch set. This is one fork's report, not a generic patch or prediction for other hardware.
2. **Low-VRAM-related source examples:** [`Beaver6513/ztrx-lowvram`](https://github.com/Beaver6513/ztrx-lowvram) reports work for a GTX 1650 4 GB / Windows 10; [`Dolberthi/neptune-dolberth-nvidia-8gb`](https://github.com/Dolberthi/neptune-dolberth-nvidia-8gb), [`Linox-IDK/LNX-victory`](https://github.com/Linox-IDK/LNX-victory), [`JozefDeTremmerie/CCS03`](https://github.com/JozefDeTremmerie/CCS03/tree/ccs03), and [`GiovannaSGuerrera/Victory-RTX2080`](https://github.com/GiovannaSGuerrera/Victory-RTX2080) include 8 GB-oriented work. Their approaches include display/texture budgets, bounded pools, eviction, and render-target allocation; this is not a validated configuration for a different GPU.
3. **Examples of isolated NVIDIA performance reports:** [`Pavl3000/victory-speed`](https://github.com/Pavl3000/victory-speed) (5.1 → 8–10 fps reported on RTX 3080 Ti), [`Ryanabcraft/scarlett-victory-bench`](https://github.com/Ryanabcraft/scarlett-victory-bench/blob/main/PERFORMANCE.md) (async relay fetch + worker sizing on RTX 3050), [`fxceless/victory-fork`](https://github.com/fxceless/victory-fork) (per-switch results reported on RTX 4070), and [`LowBacon/HybridGt`](https://github.com/LowBacon/HybridGt/blob/main/docs/PERFORMANCE_OPTIMIZATION.md) (GPU buffer/fill/merge work reported on RTX 4070 Ti).
4. **Source-reported crash-handling work:** upload-before-show (`VICTORY_SHOW_AFTER=1`), shader-written ocean/height texture readback (`VICTORY_TEXTURE_BACK=1`), deferring descriptor unmake until GPU idle (`flush_idle_heaps()`), NVIDIA view/constant-buffer limits, depth/PSO validation, integer-target blend bypass, wave64-on-wave32 correctness, DRED/name breadcrumbs, and blacklist expiry. These are fork-specific changes, not universal fixes. Some long `fxceless/victory-fork` sessions still report unresolved **0x887A0005 device removal**.
5. **AMD source examples:** [`avatarmanz/VIctory-7900XTX`](https://github.com/avatarmanz/VIctory-7900XTX) `main` reports frame-time work on RX 7900 XTX alongside 40–46 GB RAM use; [`Belobug/VIctory-Belobug-AMD`](https://github.com/Belobug/VIctory-Belobug-AMD/tree/main) reports RX 9070 XT results with high memory use; [`DexNom/VIctory`](https://github.com/DexNom/VIctory) documents dirty-range/VRAM/streaming work; [`xcl-dev/xcl`](https://github.com/xcl-dev/xcl/tree/amd-dev) documents persistent pools, async uploads and lock-free lookups. Vendor-specific changes must not be assumed portable.
6. **Workspace scope:** this checkout contains a PowerShell launcher (`harness/`) plus the research bundle, not the VIctory renderer itself. The original root README was stale (it described an Android utility project) and has since been corrected. PortWatch fixes that change shader translation, D3D12, or Xbox HLE internals require changes in an actual VIctory-family source tree; they are not implemented by this harness. General engineering patterns are summarized in §8.
7. **Private builds are claims, not fixes.** CGBJ, darkworldhm, NotNozy, Doomsday and suri have no public code in the tracker. Their FPS/RAM numbers are evidence that something is possible, not something to copy.
8. **Licensing is a hard gate.** Most VIctory forks declare GPL-3.0-or-later. XCL declares **GPL-2.0-only** in its README/badge. The knowledge repo identifies two AvatarManz loader files as verbatim XCL GPL-2.0-only code inside a GPL-3.0 tree. Do not combine code across those families without legal review or clean-room reimplementation.

---

## 1. Scope and method

### What “every fix” means here

I treated “every fix from every repo” as an exhaustive **public evidence index**, not a claim that every commit message is correct or every README claim is reproducible. The complete indexed inventories are machine-readable files; the human report curates the fixes with actionable code/switch/measurement evidence.

Source chain:

- PortWatch site and `#toolkit`: leaderboard, 22 toolkit tools, methodology, private builds, news/DMCA notes.
- Site source: `4lwayz/portwatch-vi`, especially `data/tracker.json`, `README.md`, `scripts/scout.mjs`, `scripts/build-site.mjs`.
- GitHub REST/GraphQL via `gh`: repository metadata, READMEs, commit histories, branches and branch comparisons.
- Shallow clones of 30 high-signal repos/branches for READMEs, docs, benchmark logs, patches and launcher scripts.

### Coverage

| Item | Count / result |
|---|---|
| Explicit repository fields in `data/tracker.json` | 37 efforts, 22 tools, 25 candidates, 565 ignored |
| Live GitHub repos resolved from URL/repo-field candidates | **546** |
| README texts fetched | **539** |
| Commit histories fetched | **546**; 208 were truncated at 100 commits, so later pages since 2026-11-15 were fetched |
| Indexed commit objects after expansion | **106,106** |
| Relevant FPS/crash/RAM/VRAM commit headlines | **6,343** across **280** repos |
| De-duplicated relevant commit messages | **2,910** |
| Branch records | **563** branches over 88 repos |
| Branch comparisons | **61**; 1,182 branch commits inspected, **624** relevant branch-only commits |
| Selected README keyword lines | **2,136** lines over 22 high-signal READMEs |
| `gta6-port-knowledge` defect catalog | **305** defects; **134** matched FPS/crash/RAM/VRAM themes |
| Curated actionable matrix | **69** rows, including negative controls |

The dynamic “overall percentage” on PortWatch differed between two fetches (`-74.9%` vs `-55.4%`), so I do not quote it. The site also warns that fake “PC installer”/`.exe` repos can be malware, and its DMCA section records Take-Two disabling Leonida and many forks. Ignored/copy/spam/DMCA repos were kept in the coverage index but not treated as independent fixes.

### Durable artifacts

- [`PORTWATCH_FIX_MATRIX.csv`](PORTWATCH_FIX_MATRIX.csv): 69 curated fix families with repo, branch, license, switches/paths, evidence, risk and portability.
- [`portwatch-analysis/catalogs/portwatch_fix_catalog.csv`](portwatch-analysis/catalogs/portwatch_fix_catalog.csv): all **6,343** relevant public commit headlines, with commit URLs.
- [`portwatch-analysis/catalogs/portwatch_unique_fixes.tsv`](portwatch-analysis/catalogs/portwatch_unique_fixes.tsv): **2,910** de-duplicated fix messages.
- [`portwatch-analysis/catalogs/branch_fix_catalog.tsv`](portwatch-analysis/catalogs/branch_fix_catalog.tsv): **624** relevant branch-only commits.
- [`portwatch-analysis/metadata/repo_coverage.tsv`](portwatch-analysis/metadata/repo_coverage.tsv): all **546** live repos with group, GPU hint, branch, license, parent, description and relevant-commit counts.
- [`portwatch-analysis/metadata/curated_repos.tsv`](portwatch-analysis/metadata/curated_repos.tsv): key repos with branch/license metadata.
- [`portwatch-analysis/source/`](portwatch-analysis/source/): PortWatch source snapshot, all fetched README texts, selected docs/patches/launchers, and the knowledge-repo docs/catalog.
- [`portwatch-analysis/scripts/`](portwatch-analysis/scripts/): fetch/index/derive scripts used for this audit.

---

## 2. NVIDIA-first source survey — not a deployment plan

The comparisons and example bundles below preserve what public repositories reported at the audit date. They were not built or benchmarked by this review, are not validated for this checkout or a 6 GB / 16 GB laptop, and should not be applied as a combined configuration. Check each exact source commit and test changes individually in the renderer project.

### 2.1 Public source-tree comparisons

If this is for a Windows/GDK compatibility layer, do **not** blindly merge every fork. The comparative knowledge plan recommends:

- [`Marvisak/VIctory`](https://github.com/Marvisak/VIctory) `main` as the canonical GPL-3.0 base.
- [`DexNom/VIctory`](https://github.com/DexNom/VIctory) `main` as a linear “supply line” for selective cherry-picks.
- [`fxceless/victory-fork`](https://github.com/fxceless/victory-fork) `main` as the source of the automatic shader-cache fingerprint mechanism and measured NVIDIA switches.
- **Not** AvatarManz as a base, because two `console_insn*.rs` loader files are identified as verbatim XCL GPL-2.0-only code.
- XCL (`main`, `nvidia-dev`, `amd-dev`) as a separate GPL-2.0-only design/reference stack, not a direct code donor into GPL-3.0 forks.

The earlier report ranked `lucas-TagDev/VKarameloVI` `main` as an integrated NVIDIA example and named `Pavl3000/victory-speed`, `Ryanabcraft/scarlett-victory-bench`, `CCS03`, `Dolberthi`, `Linox`, and `Beaver` as source comparisons. This is not a recommendation to use any of them; reported results are not matched to one another or to the user's hardware.

### 2.2 Example NVIDIA launcher settings reported by one source

The following settings were observed in the VKarameloVI launcher at the survey date. They are not a validated bundle for this checkout or another fork; consult the exact commit and do not infer that every switch is supported elsewhere.

```powershell
# lucas-TagDev/VKarameloVI scripts/play-nvidia.ps1, abbreviated
--console series-s
VICTORY_RENDER_SCALE=0.5
VICTORY_OWN_UPSCALER=1
VICTORY_COMPOSE=1
VICTORY_BVH_MISS=1
VICTORY_DYNAMIC_SLOTS=524288
VICTORY_CARD_BUFFERS_MIN_MB=1
VICTORY_CARD_BUFFERS_MB=1536
VICTORY_PIPELINE_WAIT_MS=10000
VICTORY_TEXTURE_BACK=1
VICTORY_SHOW_AFTER=1
VICTORY_THIN=1
VICTORY_ASYNC_SUBMIT=1
VICTORY_QUEUE2=1
VICTORY_JOIN_PARTS=8
VICTORY_D3D12_DRED=light
victory shaders <archives>      # first run / after shader-emitter change
victory warm --used             # before benchmarking a new driver/build
```

The source's reported rationale/results (not independently reproduced here):

1. **Lower pixels and VRAM first.** Truthful `VICTORY_DISPLAY_MODE=1920x1080` or `--console series-s` stops the title from building 4K-class targets for a 1080p window. `VICTORY_RENDER_SCALE=0.5` quarters world pixels; `VICTORY_OWN_UPSCALER=1` avoids untranslated FSR/FSR4 compute paths; `VICTORY_COMPOSE=1` keeps the 4K UI plane visible.
2. **Remove the stale-BVH hang/loss.** `VICTORY_BVH_MISS=1` makes every stale box/triangle test miss and saves about 10 ms/frame, at the cost of bounced indirect light. It must be part of the shader cache key.
3. **Stop descriptor-table drops.** NVIDIA caps shader-visible views near 1,000,000. `VICTORY_DYNAMIC_SLOTS=524288` plus null/out-of-range view handling cuts refused tables from thousands/frame to near zero.
4. **Move compares to the GPU after GPU work is no longer saturated.** `VICTORY_CARD_BUFFERS_MIN_MB=1` and a bounded `_MB` moved ~190 MB/frame of CPU compares to the card in VKarameloVI; copy-back fell 27 → 10 ms and FPS doubled from 11 to 21.8 in that sequence.
5. **Prewarm and wait.** `victory shaders`, `victory warm --used`, `VICTORY_PIPELINE_WAIT_MS=10000` and driver-blob caches remove dropped draws and first-use hitches. A cold cache can otherwise produce 10–12 s frames while ~5 GB of shader cache is rewritten.
6. **Keep cheap diagnostics on.** `VICTORY_D3D12_DRED=light`/`faults` and named resources give breadcrumbs without the ~50 ms/frame cost of full DRED.

### 2.3 8 GB / low-RAM source reports (not a profile for other machines)

The table records configurations/results reported for their listed hardware; it is not a profile recommendation for other machines:

| Situation | Public tree | Core switches | Evidence / tradeoff |
|---|---|---|---|
| GTX 1650 4 GB, Windows 10 | `Beaver6513/ztrx-lowvram` `main` | `VICTORY_D3D12_DIR`; `VICTORY_TEXTURE_BUDGET_MB` ≈ 1/6 VRAM; `VICTORY_CARD_BUFFERS=0`; `VICTORY_RELAY=2`; `-Fast` | 1388 → 642 → 548 ms/frame; card use 6.0 → 4.1 GB against 3.3 GB budget. Still over budget and textures may appear late. |
| NVIDIA 8 GB + 16 GB RAM | `Dolberthi/neptune-dolberth-nvidia-8gb` `main` | `VICTORY_TEXTURE_MAX_DIM=1024`, `VICTORY_RAM_TRIM_MB`, `VICTORY_VRAM_EVICT`, `VICTORY_SLOT_EVICT`, `VICTORY_LIST_POOL_MB`, `VICTORY_TURBO_THREADS`, `VICTORY_THIN=1` | README claims ~1.5–2 GB VRAM saved and prevention of `0x887A0006`; quality/late textures and self-reported evidence. |
| RTX 5060 Ti 8 GB + 32 GB RAM | `Linox-IDK/LNX-victory` `main` | `VICTORY_TEXTURE_SKIP_MIPS=1`, `VICTORY_TEXTURE_NO_WAIT=1`, `VICTORY_CARD_FETCH_INFLIGHT=0`, `VICTORY_WARM_CACHE=1`, offline precompile | ~4 GB VRAM saved; 1.3 → 3.3–4.6 fps; 7–8 fps Series S+FSR in README. Needs tiled-resources tier 2 and a larger pagefile. |
| RTX 4060 Laptop 8 GB | `JozefDeTremmerie/CCS03` `ccs03` | `VICTORY_DISPLAY_MODE=1920x1080`, `VICTORY_TEXTURE_DROP_MIPS=1`, `VICTORY_TEXTURE_ROOM_PERCENT=86`, `VICTORY_CARD_BUFFERS_MB=768`, `VICTORY_CARD_ROOM_FOR_TARGETS_MB=1024`, `VICTORY_TEXTURE_STAGE_MS=25`, `_MB=48`, `VICTORY_TEXTURE_CATCHUP=0`, `VICTORY_WIDE_REFRESH=1` | 3–7.8 fps, 2.5–31 min no crash; wide refresh cut copies 60–210 → 38–95 ms. Lower detail/late textures possible. |
| RTX 2080 8 GB checkpoint | `GiovannaSGuerrera/Victory-RTX2080` `main` | 1280x720, mip drop, small-pipeline-first, copy queue, safe async submit | Recoverable playable checkpoint but 0.3–2.5 fps, crashes and black surfaces; mostly useful as an 8 GB reference. |

Patterns reported in selected forks (context-specific, not universal rules):

- Several sources separate **render-target room** from texture and card-buffer budgets; their black/late-surface reports are build-specific and do not establish a cause in another renderer.
- Some streaming paths preserve a **valid resident mip until replacement** so a live resource is not evicted before its replacement upload runs.
- Several forks use **bounded pools** for snapshots, command lists, staging and upload buffers, with trimming under measured commit pressure.
- Some patches coalesce dirty ranges/writebacks and avoid whole-page or whole-buffer compares when a smaller mask suffices.
- Source work also distinguishes unnecessary GPU→CPU readback from resources the title's CPU genuinely samples (such as ocean height/displacement maps).
- An error 1455 / commit-exhaustion message is evidence to investigate current system commit and the selected build's documented requirements; this survey does not imply a fixed pagefile size.

### 2.4 NVIDIA source-reported changes and results

| Goal | Fix | Public source | Measured evidence | Main risk |
|---|---|---|---|---|
| FPS | Series S + 0.5 render scale + own upscaler + BVH miss + GPU compares | `lucas-TagDev/VKarameloVI` `main` | 6 → 7.2 → 11 → 21.8 fps sequence on RTX 5070; 20–22 fps prologue | Softer image; dark indirect light; title hooks |
| FPS | One clamp per indirect window; one `ExecuteIndirect` per run; record count 64 | `Pavl3000/victory-speed` | RTX 3080 Ti 5.1 → 8–10 fps; GPU 99 → 29 ms; clamps 501 → 46 | `INDIRECT_MERGE` still unmeasured after ordering fix |
| FPS | Skip unchanged heap-texture slots; bound texture pass; count reuploads | `Pavl3000/victory-speed` | texture pass 246–420 → 32 ms; heap walk saved 54.5 ms/frame | Too-small budget causes late textures |
| FPS | Join writeback runs; opened-copy-first; merge cap | `Pavl3000/victory-speed` | 250,236 kernel writes → 167/frame; 90.4 ms write removed | Kernel-write method is host-specific; retest |
| FPS | Async relay fetch, wide worker pool, `BACK_PARTS` | `Ryanabcraft/scarlett-victory-bench` | RTX 3050 600–890 → 506–595 ms; fetch 150–197 → 1.4–5.2 ms | Fetch queue still 157–167 ms; cold cache invalidates FPS |
| FPS | Lookup cache, small card buffers, joined parts, own-view back, short hash | `fxceless/victory-fork` | ~14 ms/frame lookup cache; 68 → 49.8 ms card list; ~6% / ~9% gains; 7–12 fps rooms | Some long runs still lose device `0x887A0005` |
| FPS | GPU buffer copies, GPU fills, masked merge-under-writes | `LowBacon/HybridGt` | 3.5–3.6 → 3.7–4.2 fps; 77 ms settle removed | Patches against older base; correctness tests required |
| FPS | Coalesced card compare/L0 readback, scoped barriers, AOT precompile | `zsy-miao/victory-perf` | 2.5–4 → 4.5–14+ fps; relay stalls ~200 → ~0 ms | Self-reported; lighting stand-ins; many defaults on |
| FPS | 1080p truthful display, mip drop, texture budget, wide refresh | `CCS03` / `Ryanabcraft` / `wardevsa` | 1080p fixes 4K-in-1080p overdraw; texture waiting 9,194 → 8,996 and falling; copies 60–210 → 38–95 ms | `DISPLAY_MODE` was ignored in one fxceless run; version-specific |
| Crash | `VICTORY_TEXTURE_BACK=1` | `fxceless`, AvatarManz, CCS03, VKarameloVI | Boats stop sinking; ocean height/displacement textures reach title CPU | Adds readback traffic |
| Crash | `VICTORY_SHOW_AFTER=1` | AvatarManz / Belobug branch / VKarameloVI | Device loss every ~15–16 min likely fixed by not showing a texture before upload | “Likely”, not proven |
| Crash | Defer descriptor unmake until GPU idle | `Itsbatt/victory-unified` | Two ~49m42s `0x887A0006`/MMU-fault runs → ~58 min crash-free | One-machine evidence |
| Crash | 64 KiB CBV cap, integer-target blend bypass, wave64 correctness | `fxceless`, CCS03, DexNom, VItoriaBr | Avoids NVIDIA invalid device removal, PSO refusal, LDS traps and deadlocks | Vendor-specific; differential tests needed |
| Diagnostics | `DRED=light|faults`, frame log, GPU timing, named objects | `fxceless`, XCL, `Pavl3000` | Makes TDR/device removal diagnosable; full DRED ~50 ms/frame | Instrumentation can distort frame pacing |

---

## 3. AMD-inclusive findings

### 3.1 AvatarManz — RX 7900 XTX, source-reported frame-time work

[`avatarmanz/VIctory-7900XTX`](https://github.com/avatarmanz/VIctory-7900XTX) `main` and [`docs/findings.md`](https://github.com/avatarmanz/VIctory-7900XTX/blob/main/docs/findings.md) report i9-12900K / 64 GB / RX 7900 XTX / 1440p / Series X:

- 280 ms/frame → 124 → 103 → 75 → **46–65 ms indoors**; **46–53 ms boat**; **100–165 ms street chase**; **41 min no crash**.
- Uses **40–46 GB private memory**; 64 GB RAM recommended. This is not a low-RAM build.
- Top changes: `VICTORY_THIN` eight draw-call translation threads; async submit; joined parts/barriers; card steps; cheaper write guards; texture copy queue; `VICTORY_SHOW_AFTER=1`; `VICTORY_TEXTURE_BACK=1`; binary-search requested ranges; AVX2 in-place heap sync; 64 KiB pooled textures; offline `victory shaders` / `victory warm --used`; `-Safe` fallback.
- Correctness fixes: 65,535-group cap, AMD helper-lane quad reads, ray dispatch thread-vs-group counts, raw typed-view read bounds, view-index heap bounds, cube reflection/log and normalized-code fixes.
- Rejected on that card: 16 mapping threads (125 → 260 ms), Series S/smaller textures, second draw queue, `VICTORY_SHADER_OPT=127`, wave-size/FMA/raw-buffer experiments, native RDNA code on Windows driver, always-on panel.
- **License warning:** the comparative knowledge repo identifies `crates/victory-loader/src/console_insn.rs` and `console_insn_decode.rs` as verbatim XCL GPL-2.0-only code in a GPL-3.0 tree; do not use this repo as a clean base.

### 3.2 Belobug — RX 9070 XT, branch caveat

The tracker says branch `main`, but GitHub's default branch is `rx9070xt`. I checked both:

- [`Belobug/VIctory-Belobug-AMD` `main`](https://github.com/Belobug/VIctory-Belobug-AMD/tree/main) is the **real RX 9070 XT README**: Ryzen 7 9800X3D / 64 GB / 16 GB card, **5–8 fps**, lit/textured world, ~22 GB RAM, >16 GB VRAM, one driver timeout, phone UI broken, 33 GB commit after a 15-minute drive.
- `rx9070xt` branch README and `docs/findings.md` currently mirror the AvatarManz “RX 7900 XTX” text. Treat `main` as the RX 9070 XT source of truth; treat `rx9070xt` as a large diverged experiment with 421 commits and 136 relevant fix-like commits.
- `main` fixes: `VICTORY_HOIST_CLAMPS=7` (225 → ~80 ms GPU), wide snapshots/copy-back (43 → 33 ms), `VICTORY_ASYNC_SUBMIT=1` (200–238 → 150–186 ms), in-place `VICTORY_STRETCH` (copy-back 36 → 12 ms), descriptor-view `RwLock`, Thin LTO, shader cleanup, ambient stand-in, integer-target blending off, AMD helper-lane quad reads, doubled dynamic descriptor slots, texture max 1024 under VRAM pressure, and shader/PSO crash containment.
- Known problems: 266 untranslated programs, dropped draws, permanent `pipelines/crashed.txt` exclusion, 33 GB commit, `VICTORY_RAYS=1` device removal after ~90 s, and tests failing on author's machine.
- `rx9070xt` branch adds `VICTORY_SHOW_AFTER`, `VICTORY_TEXTURE_BACK`, `VICTORY_CARD_BUFFERS_MIN_KB`, `VICTORY_DECLARE_ONCE`, `VICTORY_BIND_CACHE`, `VICTORY_SAME_RECORDS`, `VICTORY_TAKE_PARTS`, `VICTORY_BVH_SIZES_WAIT=0`, 4 KiB page parts, AVX2 title-byte compares, pipeline slow-worker quarter, sorted/joined card-copy runs, and screen-pass pipeline workers.

### 3.3 DexNom — AMD VRAM / dirty-range work

[`DexNom/VIctory`](https://github.com/DexNom/VIctory) `main` is a linear descendant of upstream and a good selective-cherry-pick source. RX 7900 XTX: 3–4 fps, RT ~1 fps; 25,742/25,758 shaders translate and all 2,191 vertex shaders are DXIL-valid.

Important patterns:

- Cached textures inside reserved guest memory; pixel-quad sampling; ray buffer views/sparse textures; City texture streaming; 40 immediate-sampler shader variants; integer-target blending fix.
- GPU readback of changed pages plus adjacent ranges; read-only traversal no longer declares all guest memory writable; shared texture upload budget for new uploads and retries; warm depth-only pipelines.
- `VICTORY_FILL_WORKERS=4`, `VICTORY_PARALLEL_PRELUDES=1`, `--no-rt`, `VICTORY_AMBIENT_FALLBACK=1`, optional `--rt-static-bvh` are experiments.
- TODOs that are directly relevant to low RAM/VRAM: reduce buffer copy-back, duplicate resident resources, oversized staging, repeated mip uploads; keep a valid resident mip until replacement; measure dedicated/shared GPU memory and p95 frame time.

### 3.4 XCL AMD branch

[`xcl-dev/xcl` `amd-dev`](https://github.com/xcl-dev/xcl/tree/amd-dev) has 218 commits ahead/diverged and 111 relevant branch commits. High-value patterns:

- Persistent `DetilePool`; asynchronous texture uploads on title queues; `RwLock` for hot read-mostly PSO/UMA lookup tables; lock-free descriptor copies; PSO bind cache.
- 4 KiB-aligned VRAM packing for sub-64 KiB textures; hash only written pages; pool ≤8 MiB upload staging and reclaim idle staging.
- Batch VRAM tile-mapping fences; low-commit throttle; commit-reserve floor; GPU wait-watchdog wake fix; sparse/VRAM quarantine; giant compile isolation; wall-clock frame wait windows.
- `XCL_TEXTURE_LEVEL_PAGES=1`, `XCL_AMD_SERIAL_PSO=1`, `XCL_HEAP_FLAT`, `XCL_DSTORAGE_PARALLEL_DECOMPRESS=1`, `XCL_DSTORAGE_MEMORY_BUDGET_MIB`.
- **Do not copy code into GPL-3.0 VIctory forks** without legal review; use it as a design reference or clean-room reimplementation.

### 3.5 Other AMD / cross-vendor sources

- [`Marvisak/VIctory`](https://github.com/Marvisak/VIctory) `main`: canonical base, ~1 fps on RX 6700 XT, ~33 GB commit and ~10 GB VRAM; `victory translate --cache --pipelines`, FidelityFX upscaling, DRED/GBV/WARP diagnostics. `VICTORY_WINDOW_MAX` only scales the window, not the console render resolution.
- [`uiliannn/VItoriaBr`](https://github.com/uiliannn/VItoriaBr) `main`: NVIDIA Blackwell testing but includes an 8 GB AMD RDNA2 / PCIe x4 preset, exact LDS bounds, divergent `s_barrier` fence-only lowering, wave64-on-wave32 differential tests, `PASS_BUDGET` watchdog guard, shader-cache identity review, `RELAY=2`, `WIDE_MERGE/REFRESH`, `TEXTURE_NO_WAIT`. Default 4–6 fps; a 22 fps experimental GPT build is explicitly not integrated into `main`.
- [`xcl-dev/xcl` `main`](https://github.com/xcl-dev/xcl): 100% of 26,698 RDNA2 programs translate; 30 fps menus; shared UMA up to 16 GB without CPU/GPU copies; non-blocking PSO stand-ins; translated-shader disk cache; DXC 1.8/1.9 faster than 1.7; split compute libraries; huge-PSO one-wide lanes with 3 GB commit gate. `nvidia-dev` / PR #2057 reaches ~5 fps in 3D world on RTX 5090 and ~14 fps averaged over a 5-minute run, but the picture is incomplete and it does not keep running long.
- [`xcl-dev/xcl` `nvidia-dev`](https://github.com/xcl-dev/xcl/tree/nvidia-dev): 371 commits ahead, 140 relevant commits; lazy graphics/compute PSOs built ahead, `XCL_GFX_PSO_WAIT_MS`/`XCL_CS_PSO_WAIT_MS`, driver blobs named by adapter/driver, `XCL_DRED`, `XCL_LOOK_STATS=2`, resource/heap/PSO names, null views, shared heap of 2^21, sparse-tile cooling, sampled textures without top mips under VRAM pressure (some related commits were later reverted—verify HEAD).

---

## 4. Crash / watchdog / device-removal catalogue

The `gta6-port-knowledge` defect catalog is useful because it separates **root causes** from claims. The most actionable public crash fixes are:

| Failure | Fix | Source / switch |
|---|---|---|
| Save deletion when a residual `v01` folder sits beside valid `v1` | Only exact `v<N>` as commit writes is a version; fail closed if no readable version | `DexNom` `b8dbcba`, `VItoriaBr` `d1da85a`, `AvatarManz` `70868f8`; knowledge plan says 3 of 6 forks still lack it |
| Texture shown before upload causes page fault / device loss every ~15 min | Do not show slot until upload has run | `VICTORY_SHOW_AFTER=1` |
| Boats sink / ocean physics wrong | Copy shader-written height/displacement textures back to title memory | `VICTORY_TEXTURE_BACK=1` |
| NVIDIA `0x887A0006`/MMU fault after ~50 min | Defer descriptor unmake/view-remake while submissions are in flight; flush idle heaps | `Itsbatt` `flush_idle_heaps()` |
| NVIDIA view heap beyond 1,000,000 / invalid CBV | Cap host heap, null out-of-range views, cap constant-buffer views at 64 KiB | `VIctory`, `VItoriaBr`, `fxceless`, `VKarameloVI`, `CCS03` |
| Wave64 programs on 32-lane NVIDIA hang or remove device | Exact cross-half exchange or refuse/translate to split forms; keep unsafe wide mode opt-in | `VItoriaBr`, `CCS03`, `XCL wave64-on-wave32`, `VICTORY_WAVE_WIDE=0` default in `mravatins` |
| Integer render-target PSO refused | Bypass blending on integer targets | `DexNom` `ddb7332`, `Belobug`, `CCS03 PR 13` |
| Stale BVH / ray builder corrupts title pointers | End stale walks at root, quarantine builder stores, fix `DispatchX` thread-vs-group counts, place upload memory below 2^40 | `VKarameloVI` `VICTORY_BVH_MISS`; `wardevsa` `VICTORY_BVH_BUILDER/QUARANTINE/KEEP/UPLOAD_LOW` |
| Indirect draw garbage consumes whole list budget | Validate/rest policy, cap windows, clamp once per run | `VICTORY_INDIRECT_REST=0`, `VICTORY_INDIRECT_WINDOW`, `Pavl3000` |
| Driver timeout / watchdog aborts slow frames | Prewarm pipelines, bound waits, cap texture passes, optionally disable title watchdog | `VICTORY_PIPELINE_WAIT_MS`, `PASS_BUDGET`, `VICTORY_NO_WATCHDOG=1` |
| Permanent pipeline blacklist excludes legitimate work after a timeout | Expire/re-evaluate `crashed.txt`; do not inherit Belobug's permanent exclusion | knowledge plan, Belobug known problems |
| Unknown TDR / device removal | Always-on cheap breadcrumbs and named objects | `VICTORY_D3D12_DRED=light|faults`, `XCL_DRED`, `XCL_LOOK_STATS`, frame logs |

**Important unresolved issues:** `fxceless/victory-fork` diagnostics runs 281/282 still ended with `0x887A0005` after 37.5–40.8 minutes, with no page-fault address or driver event. `Belobug main` had a driver timeout once and ~33 GB commit after 15 minutes. `wardevsa` RT-builder modes can produce real ray-traced light but only 1.6–2.1 fps with nearly full RAM. Private builds claiming high stability have no code to inspect.

---

## 5. Toolkit / format / coordination findings

The 22 toolkit entries are mostly asset/archive/format tools, not runtime FPS patches. The useful ones for performance/RAM work are:

| Repo | License | What it gives | Why it matters | Limit |
|---|---|---|---|---|
| [`POMXARK/bcpack-gpu-hlsl`](https://github.com/POMXARK/bcpack-gpu-hlsl) | MIT OR Apache-2.0 | GPU BCPack rANS decoder, Gfx10 detile, async compute, zero-copy C-ABI, SFS/VRS/TAAU, descriptor paging | Synthetic RTX 5080: BC1 11.33 GB/s vs ~40 MB/s CPU; live 5 → 189 fps; VRS +31.6%; 1.25M → 262K descriptor slots; low preset 551.5 fps | Synthetic open assets, **not GTA VI title FPS**; integration via shared `ID3D12Device` |
| [`Ahmet-Dedeler/bcpack-rs`](https://github.com/Ahmet-Dedeler/bcpack-rs) | MIT OR Apache-2.0 | CPU BC1/3/4/5/7 decoder, BC6H entropy, Gfx10 detile, written spec | 0 differing blocks across 5,612 chunks / 85.8M blocks; good correctness oracle/offline converter | 34–40 MB/s/core; BC6H block rebuild WIP; not runtime FPS |
| [`sub-north/xbox-hle-lab`](https://github.com/sub-north/xbox-hle-lab) | MIT tools / CC-BY docs / GPL-2.0 patches | Driver blob cache, sub-2^40 placement, payload integrity, GPU/VM/watch probes | 5 ms PSO replay vs 681 ms cold; 30.7 presents/s instantaneous / 17.8 avg; BVH address wall cleared | No world render; title stall detector still aborts after ~40 s |
| [`lukinhasnojento/gta6-port-knowledge`](https://github.com/lukinhasnojento/gta6-port-knowledge) | see `NOTICE.md` | 305-defect catalog, 13-repo comparison, consolidation plan, license block | Best cross-repo root-cause/negative-control source; identifies save deletion, cache fingerprint, regressions | Documentation only; not runtime code |
| [`fishingpvalues/gta6-pc-port-hub`](https://github.com/fishingpvalues/gta6-pc-port-hub) | see repo | Workstreams C-1 package inventory, C-2 shader census, C-3 root-signature-less fallback, C-4 conformance, C-5 license matrix, C-6 wave64-on-wave32 | Coordination and licensing map | Stale as of 2026-11-22 (“nothing boots”); no runtime fix |
| [`decantlabs/decant`](https://github.com/decantlabs/decant) | MIT | Branches for parallel title-memory copy, fast detile staging, batched DirectStorage, zero-skip precompile, VEH write race | Clean MIT design ideas for batching/async work | README says private/WIP; real titles only boot to first screens; nothing claimed playable |
| [`LooperSalty/AnyXboxX`](https://github.com/LooperSalty/AnyXboxX/tree/feat/fps-rorodev) | see repo | `VICTORY_TEXTURE_BATCH`, `VICTORY_COPY_COMPARE`, `VICTORY_STAGING_BLOCKS`, wide copy workers, 32-byte equal-chunk skip | Useful dirty-range/staging patterns | Experimental diverged branch, not in main PortWatch race |

`NVIDIA/DLSS` was explicitly ignored by the tracker as off-topic; the toolkit's BCPack/texture tools help with streaming and late textures, but they are not magic FPS switches for the game layer.

---

## 6. Negative controls and regressions

A large part of “anything that can improve the project” is knowing what **not** to enable.

| Switch / pattern | Where it failed | Result |
|---|---|---|
| `VICTORY_CARD_FETCH_INFLIGHT=1` | `LowBacon/HybridGt` next10, `Linox-IDK`, `VItoriaBr` | GPU time ×3, 578–700 ms frames, or worse FPS. **But** `Pavl3000` measured 73–272 → 0 ms relay wait on RTX 3080 Ti; treat as hardware/scene-specific. |
| `VICTORY_FIRSTLANE_OWN=1` + BVH builder | `LowBacon/HybridGt` next2 | Title crashed ~2 min in; approximate first-lane read corrupted AABB/pointers. |
| `VICTORY_BVH_SIZES_WAIT=1` | Belobug / AvatarManz branch | ~20 ms/frame and “mended nothing”; turned off. |
| 16 page-mapping threads | AvatarManz | Bedroom 125 → 260 ms; no more pages mapped. |
| `VICTORY_CARD_BUFFERS_IN_RAM=1`, `VICTORY_FAST_COPY=1`, `VICTORY_INPLACE=2`, `VICTORY_CARD_BUFFERS=0`, `REHASH_RUNS=1`+`JOIN_COPIES=1` | `Ryanabcraft` | All worse or broke boot; `FAST_COPY` 127–205 ms vs 104–147, `INPLACE` 912–1386 ms, combined 660–1193 ms. |
| `VICTORY_ASYNC_PRESENT=1` | `Itsbatt` | Crash in `nvwgf2umx.dll`; kept off. |
| Series S + FSR4 | `Itsbatt` / `zsy-miao` | `0x887A0001` or black frames; use `VICTORY_OWN_UPSCALER=1`. |
| `VICTORY_WAVE_WIDE=1` on four particle light-atlas programs | `wardevsa` | Can hang card; use `VICTORY_WAVE_WIDE_SKIP`. |
| Full `VICTORY_D3D12_DRED=1` continuously | `fxceless` | ~50 ms/frame; use `light`/`faults`. |
| `VICTORY_TEXTURE_MAX_DIM=1024` / mip drops | low-VRAM forks | Saves VRAM but causes late/blurry textures; tradeoff, not free FPS. |
| `VICTORY_NO_WATCHDOG=1` / title watchdog off | NVIDIA perf forks | Stops a slow frame from ending the title, but hides a real stall; pair with telemetry. |
| `VICTORY_DISPLAY_MODE=1920x1080` | `fxceless` run 303 | Title ignored it and still presented 4K; works in Ryanabcraft/CCS03 contexts, so verify version. |
| Permanent `pipelines/crashed.txt` | Belobug | Legitimate pipelines remain excluded until user deletes file; use expiry/re-evaluation. |
| `VIEW_SLOTS` > NVIDIA 1,000,000 | VIctory/Belobug knowledge catalog | Padding never created; fallback masks bug. |
| `rest()` default `true` in indirect list | AvatarManz | One junk record exhausts budget and drops all following draws. |
| Monolithic tree imports | knowledge plan | Destroy auditability and sometimes overwrite third-party fixes (DexNom `570a941`). |

Several performance claims were corrected by their own authors: `fxceless` withdrew a 6.0 → 8.9 fps draw-window comparison because scenes differed; `Ryanabcraft` found a 6.0 → 8.9 fps README claim compared different scenes; the knowledge repo found commit messages that did not match diffs. Use matched scene/save/cache/driver and p50/p95 numbers.

---

## 7. Private/no-code claims

PortWatch lists private builds that boot or run faster, but there is no public code to inspect or cherry-pick. They are **not actionable fixes**:

| Private effort | Claim from site/tracker | Status |
|---|---|---|
| CGBJ | NVIDIA 20 FPS, 10 GB RAM, 16 GB VRAM; top private leaderboard result | No public repo/code |
| darkworldhm | NVIDIA RTX 50-series free roam 12–15 FPS | No public code |
| NotNozy | AMD 16 FPS | No public code |
| Doomsday | AMD/NVIDIA 3–5 FPS | No public code |
| suri | 3 FPS | No public code |

Public race claims from the fetched site also included AvatarManz 83.1% / AMD 16 FPS, Belobug 79% / AMD 8 FPS, DexNom 78% / AMD 3 FPS, hyphennn 59.8% / NVIDIA 3 FPS, Uilian 59.6% / NVIDIA 4 FPS, VIctory 50.3% / AMD 1 FPS and XCL 35% AMD/NVIDIA. Those percentages are site scores, not code-level instructions. The site's methodology says performance score is average FPS/30 and stability comes from long sessions/READMEs/commits/issues.

---

## 8. General engineering patterns (not PortWatch switches)

These are broad software-engineering ideas, not tested remedies for a black screen or performance issue in this repo. The `VICTORY_*` / `XCL_*` switches and game-specific patches are not portable to this launcher without the corresponding renderer/runtime source.

1. **Cache with an identity, not a filename.** Generate cache keys from source/toolchain/config hashes and runtime feature flags; include vendor/driver/adapter when output depends on them. Prewarm expensive work offline. Invalidate stale entries automatically.
2. **Persistent bounded worker pools.** Replace spawn-per-task with reusable workers, priority bands and bounded queues. Keep slow/heavy jobs on a separate lane so they cannot starve ordinary work.
3. **Async copy/upload queues.** Move blocking I/O and serialization off the foreground thread; use fences/promises and bounded in-flight work. Defer waits until results are actually needed.
4. **Dirty-range tracking and coalescing.** Track changed bytes/pages/fields, join adjacent ranges, skip equal chunks, and avoid whole-object copies. Keep the old valid asset until the replacement is ready.
5. **Memory budgets and graceful degradation.** Separate budgets for assets, render targets/surfaces, staging and worker pools; trim idle pools; drop resolution/mips/detail under pressure; expose a low-memory mode.
6. **Avoid unnecessary round trips.** Do not move data CPU→GPU→CPU or server→client→server unless a consumer truly needs it; when readback is required, make it narrow and asynchronous.
7. **Feature flags and safe mode.** Put risky optimizations behind switches; provide a `-Safe` path that disables newest fast paths; log effective settings with every benchmark.
8. **Telemetry that can falsify a claim.** Record p50/p95/p99 frame or request latency, CPU/GPU where relevant, RAM/VRAM/commit or heap, queue age, dropped work, cache hits/misses and error breadcrumbs. Keep heavy tracing opt-in.
9. **Vendor/device gates.** Detect capabilities (wave width, heap caps, feature level, texture tiling) and choose exact/approximate paths per device; test on the vendor you do not use.
10. **Fail closed and protect user data.** The cross-repo save-deletion bug is the clearest example: ambiguous state must not delete committed user data. Never permanently blacklist work after one timeout; use expiry/re-evaluation.
11. **One change, one measurement.** Pin scene/input/cache/driver, change one switch, measure the same counter, and keep negative results. This discipline produced the trustworthy gains in Ryanabcraft, Pavl3000, LowBacon and fxceless.
12. **License/provenance isolation.** Keep GPL-2.0-only, GPL-3.0, MIT/Apache and generated assets in separate scopes with notices; do not “fix” a license conflict by copy-paste.

Renderer-level fixes must be developed and tested in the separate VIctory-family source tree. This checkout has no renderer to patch; a source-level request needs the exact repository/commit, matched symptom, and test setup.

---

## 9. Repo / branch / license quick table

GitHub SPDX metadata is abbreviated; verify each `LICENSE`/`NOTICE.md` before redistribution. The project README/badge is the stronger statement for XCL.

| Repo | Branch used | License note | Focus |
|---|---|---|---|
| `4lwayz/portwatch-vi` | `main` | site source | Tracker/site data |
| `Marvisak/VIctory` | `main`; `fix/tests-without-gpu` | GPL-3.0-or-later | Canonical VIctory base |
| `fxceless/victory-fork` | `main` | GPL-3.0-or-later | NVIDIA RTX 4070 measurements, diagnostics, cache fingerprint |
| `avatarmanz/VIctory-7900XTX` | `main` | GPL-3.0 tree with identified GPL-2.0-only XCL files | AMD RX 7900 XTX speed |
| `Belobug/VIctory-Belobug-AMD` | `main` (RX 9070 XT); `rx9070xt` (diverged experiment) | GPL-3.0-or-later | AMD RDNA3 / crash / speed |
| `DexNom/VIctory` | `main` | GPL-3.0-or-later | Linear supply line, dirty ranges, VRAM/streaming |
| `Ryanabcraft/scarlett-victory-bench` | `main` | GPL-3.0-or-later | RTX 3050 frame-time benchmark |
| `Linox-IDK/LNX-victory` | `main` | GPL-3.0-or-later | RTX 5060 Ti 8 GB, mip skip, warm cache |
| `JozefDeTremmerie/CCS03` | `ccs03`; `perf/next` | GPL-3.0-or-later | RTX 4060 Laptop 8 GB, integrated reviewed PRs |
| `Dolberthi/neptune-dolberth-nvidia-8gb` | `main` | GPL-3.0-or-later | NVIDIA 8 GB / 16 GB RAM, worker pool, VRAM caps |
| `lucas-TagDev/VKarameloVI` | `main` | GPL-3.0-or-later | Source-reported NVIDIA 20–22 fps example |
| `zsy-miao/victory-perf` | `main` | GPL-3.0-or-later | RTX 4070 SUPER, coalesced compare, stand-ins |
| `Beaver6513/ztrx-lowvram` | `main` | GPL-3.0-or-later | GTX 1650 4 GB / Windows 10 |
| `LowBacon/HybridGt` | `main` | GPL-3.0-or-later | RTX 4070 Ti patch/log set |
| `uiliannn/VItoriaBr` | `main` | GPL-3.0-or-later | Measured architecture review, NVIDIA/AMD presets |
| `wardevsa/victory-pc-layer` | `main` | GPL-3.0-or-later | Weak-GPU 8 GB launcher and BVH builder research |
| `Itsbatt/victory-unified` | `main` | GPL-3.0-or-later | RTX 3070 8 GB, descriptor lifetime fix |
| `Pavl3000/victory-speed` | `main` | GPL-3.0-or-later | RTX 3080 Ti measured switch isolation |
| `GiovannaSGuerrera/Victory-RTX2080` | `main` | GPL-3.0-or-later | RTX 2080 8 GB checkpoint |
| `mravatins/victory-nv` | `main` | GPL-3.0-or-later | NVIDIA 8–10 fps first rooms |
| `xcl-dev/xcl` | `main`; `nvidia-dev`; `amd-dev` | **GPL-2.0-only** per README/badge | Separate compatibility stack |
| `POMXARK/bcpack-gpu-hlsl` | `main` | MIT OR Apache-2.0 | GPU BCPack SDK/demo |
| `Ahmet-Dedeler/bcpack-rs` | `master` | MIT OR Apache-2.0 | CPU BCPack reference decoder |
| `sub-north/xbox-hle-lab` | `main` | MIT tools / CC-BY docs / GPL-2.0 patches | GPU probes and PSO blob cache |
| `lukinhasnojento/gta6-port-knowledge` | `main` | see `NOTICE.md` | Comparative analysis and defect catalog |
| `fishingpvalues/gta6-pc-port-hub` | `main` | see repo | Workstream/license coordination |
| `decantlabs/decant` | `main` + perf branches | MIT | WIP clean-room Xbox/PC layer |

Full 546-row coverage with parent, archived/fork status, branches, GPU hints and commit counts is in [`repo_coverage.tsv`](portwatch-analysis/metadata/repo_coverage.tsv).

---

## 10. Limits and next step

- **Historical at the report timestamp (2026-11-26):** no application code was modified, committed, pushed, or submitted as a PR by that audit. This later branch has separate harness/documentation edits; this report's repository survey itself remains a research snapshot.
- I did **not** build or run the compatibility layers on your NVIDIA hardware; all FPS/RAM/crash numbers in this report are author-reported from READMEs, docs, commit histories and diagnostic logs.
- I did **not** treat private builds, README-only forks with “no results beyond upstream”, DMCA casualties, spam/copies or fake installers as actionable fixes.
- I did **not** include game files, keys, executables or bypass instructions. PortWatch itself says it hosts no game files and warns about malware installers.
- Fork histories are heavily diverged; only DexNom is described as a linear descendant of upstream. File-level grafts need tests; commit-message claims are not proof.
- The Belobug default branch/README mismatch and the XCL license ambiguity are explicitly documented above; verify branch `?ref=` content and legal notices before using code.
- **Next step for a specific black/dark frame:** share a same-scene screenshot, the matching harness `run-*.log`, `run-*.err.log`, and `settings-*.txt`, plus GPU/VRAM, RAM, OS build, and selected engine/commit. The current differential diagnosis is in [`harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md`](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md). A shader/render-path fix must be made in the separate VIctory-family source tree, not in this launcher-only checkout.
