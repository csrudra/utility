# PortWatch breakthroughs → what worked, what reuses, what combines — and a 6 GB VRAM / 16 GB RAM survival plan

**Generated:** 2026-11-27 UTC
**Target hardware:** NVIDIA RTX 3060 **6 GB**, Intel Core i7 12th-gen, **16 GB** RAM, Windows
**Inputs:** the 2026-11-26 audit in [`PORTWATCH_FIX_REPORT.md`](PORTWATCH_FIX_REPORT.md) and [`PORTWATCH_FIX_MATRIX.csv`](PORTWATCH_FIX_MATRIX.csv) (546 repos, 106,106 commits, 6,343 relevant fix headlines), plus a fresh fetch of [portwatch-vi.xyz](https://portwatch-vi.xyz/) on 2026-11-27 (leaderboard, private builds, news, watchlist).
**Companion files:** [`PORTWATCH_FIX_MATRIX.csv`](PORTWATCH_FIX_MATRIX.csv) (69 curated fix rows), [`portwatch-analysis/`](portwatch-analysis/README.md) (full catalogs).

---

## 0. Scope and legality (read first)

- This document analyzes **public** compatibility-layer engineering (Xbox Series → Windows translation layers, D3D12/Vulkan internals, memory management). That is ordinary emulation/translation research.
- **What I will not help with:** obtaining the leaked Xbox Series build, game files, keys, cracked executables, DMCA-bypass, or "GTA VI PC installer" downloads. The leaked build is stolen property running through unofficial layers; the legitimate path is the official release. PortWatch itself warns that fake "PC installer" `.exe` repos are commonly **malware** — do not run any of them.
- All FPS/RAM numbers below are **author-reported** unless labeled "PortWatch-verified". Several claims were retracted by their own authors (fxceless, Ryanabcraft), so treat single-run numbers as hypotheses.
- License gate: the VIctory family is **GPL-3.0-or-later**; XCL is **GPL-2.0-only**; two AvatarManz loader files are verbatim XCL code inside a GPL-3.0 tree. Do not merge code across those families without legal review; clean-room the design instead (§2.2).

---

## 1. Breakthrough catalog — what actually worked

Reuse classes used below:
**[SW]** = environment switch, copy-paste reusable · **[PT]** = patch, needs porting/testing per tree · **[DS]** = design pattern, reimplement · **[TL]** = tooling/data, directly reusable · **[NT]** = negative result (reusable knowledge).

### 1.A Robustness breakthroughs (crash/device-removal killers)

| # | Breakthrough | What it fixed | Evidence | Reuse |
|---|---|---|---|---|
| A1 | `VICTORY_SHOW_AFTER=1` — never present a texture slot before its upload ran | Device loss every ~15–16 min | AvatarManz, Belobug branch, VKarameloVI ("likely fixed") | **[SW]** |
| A2 | `VICTORY_TEXTURE_BACK=1` — read back shader-written ocean height/displacement textures to title CPU | Boats sinking, ocean physics, random deaths | fxceless, AvatarManz, CCS03, VKarameloVI | **[SW]** |
| A3 | Defer descriptor unmake/view-remake until GPU idle (`flush_idle_heaps()`) | NVIDIA `0x887A0006` MMU faults after ~50 min → ~58 min crash-free | Itsbatt/victory-unified | **[PT]** |
| A4 | NVIDIA descriptor limits: cap shader-visible heap at 1,000,000 views, null out-of-range views, cap CBVs at 64 KiB, `VICTORY_DYNAMIC_SLOTS=524288` | Thousands of refused descriptor tables/frame, invalid-device removals | VIctory, VItoriaBr, fxceless, VKarameloVI, CCS03 | **[SW]+[PT]** |
| A5 | Wave64-on-wave32 correctness (exact cross-half exchange or refuse-to-split; `VICTORY_WAVE_WIDE=0` default) | NVIDIA hangs, LDS traps, deadlocks | VItoriaBr, CCS03, XCL differential tests | **[PT]** |
| A6 | Depth/PSO state validation + integer-target blend bypass | PSO refusals, black surfaces | DexNom `ddb7332`, Belobug, CCS03 PR 13 | **[PT]** |
| A7 | Stale-BVH containment: `VICTORY_BVH_MISS=1` (all stale tests miss) + builder quarantine + sub-2^40 upload placement + `DispatchX` thread-vs-group fixes | Hangs, corrupted title pointers, ray-builder faults | VKarameloVI, wardevsa | **[SW]+[PT]** |
| A8 | Save-version fail-closed (only exact `v<N>` is a version) | **User-data deletion** when a residual `v01` sat beside `v1` | DexNom, VItoriaBr, AvatarManz; 3 of 6 forks still lacked it | **[PT]** |
| A9 | Blacklist expiry / re-evaluation instead of permanent `crashed.txt` exclusion | Legitimate pipelines permanently excluded after one timeout | knowledge repo, Belobug known problems | **[PT]** |
| A10 | Cheap always-on breadcrumbs (`VICTORY_D3D12_DRED=light\|faults`, named resources) | Makes TDR/device-removal diagnosable (full DRED costs ~50 ms/frame) | fxceless, XCL, Pavl3000 | **[SW]** |
| A11 | Driver-timeout management: `VICTORY_PIPELINE_WAIT_MS=10000`, prewarm, `PASS_BUDGET` guard, bounded waits | Slow frames killed by watchdog | Ryanabcraft, VItoriaBr | **[SW]** |

### 1.B Performance breakthroughs (frame-time killers)

| # | Breakthrough | Measured effect | Evidence | Reuse |
|---|---|---|---|---|
| B1 | **Pixels first:** Series S profile + `VICTORY_RENDER_SCALE=0.5` + `VICTORY_OWN_UPSCALER=1` + `VICTORY_COMPOSE=1` (keep 4K UI plane over 1080p world) | 6 → 7.2 → 11 → 21.8 fps ladder on RTX 5070 | VKarameloVI | **[SW]** |
| B2 | GPU-side memory compares (`VICTORY_CARD_BUFFERS_MIN_MB=1`, bounded `_MB`) after render load drops | ~190 MB/frame CPU compares moved to GPU; copy-back 27 → 10 ms; 11 → 21.8 fps | VKarameloVI | **[SW]** (budget must shrink for 6 GB) |
| B3 | Indirect-stream surgery: one clamp per window, one `ExecuteIndirect` per run, record count 64, `VICTORY_INDIRECT_REST=0` | RTX 3080 Ti 5.1 → 8–10 fps; GPU 99 → 29 ms; clamps 501 → 46 | Pavl3000 | **[PT]** |
| B4 | Texture-pass containment: skip unchanged heap-texture slots, bound the texture pass, count reuploads | Texture pass 246–420 → 32 ms; heap walk −54.5 ms/frame | Pavl3000 | **[PT]** |
| B5 | Writeback joining: join writeback runs, opened-copy-first, merge cap | 250,236 kernel writes → 167/frame; −90.4 ms | Pavl3000 | **[PT]** |
| B6 | Async relay fetch + right-sized worker pool + `VICTORY_JOIN_PARTS`/`BACK_PARTS` | RTX 3050 (**6 GB class**): 600–890 → 506–595 ms/frame; fetch 150–197 → 1.4–5.2 ms | Ryanabcraft/scarlett-victory-bench | **[SW]+[PT]** |
| B7 | Lookup cache, joined parts, short hash, small card buffers | ~14 ms/frame lookup cache; 68 → 49.8 ms card list; 7–12 fps rooms | fxceless | **[PT]** |
| B8 | GPU buffer copies/fills, masked merge-under-writes | 3.5 → 3.7–4.2 fps; −77 ms settle | LowBacon/HybridGt | **[PT]** |
| B9 | Coalesced compare/L0 readback, scoped barriers, AOT shader precompile | 2.5–4 → 4.5–14+ fps; relay stalls ~200 → ~0 ms | zsy-miao/victory-perf | **[PT]** |
| B10 | Truthful display mode (`VICTORY_DISPLAY_MODE=1920x1080`), wide refresh, mip drop | Fixes 4K-into-1080p overdraw; copies 60–210 → 38–95 ms | CCS03, Ryanabcraft, wardevsa | **[SW]** |
| B11 | `VICTORY_HOIST_CLAMPS=7` | GPU 225 → ~80 ms | Belobug `main` | **[SW]** |
| B12 | Draw-call translation on 8 threads (`VICTORY_THIN=1`), async submit, texture copy queue, separate frame-prep thread | 280 → 46–65 ms/frame indoors (RX 7900 XTX) | AvatarManz | **[SW]+[PT]** |
| B13 | `victory shaders` + `victory warm --used` + driver-blob caches + cache fingerprint (fxceless) | Removes 10–12 s first-use frames and dropped draws; ~5 GB shader cache rewritten on cold start | AvatarManz, fxceless, xbox-hle-lab (5 ms vs 681 ms PSO replay) | **[TL]** |
| B14 | Wide snapshots/copy-back, `VICTORY_ASYNC_SUBMIT=1` | Snapshot 43 → 33 ms; CPU 200–238 → 150–186 ms | Belobug | **[SW]** |

### 1.C Memory breakthroughs (the ones that matter most for you)

| # | Breakthrough | Effect | Evidence | Reuse |
|---|---|---|---|---|
| C1 | Texture budget ≈ 1/6 VRAM (`VICTORY_TEXTURE_BUDGET_MB`) | Card use 6.0 → 4.1 GB against a 3.3 GB budget (GTX 1650 4 GB) | Beaver6513/ztrx-lowvram | **[SW]** |
| C2 | Mip/dimension caps: `VICTORY_TEXTURE_DROP_MIPS=1`, `VICTORY_TEXTURE_SKIP_MIPS=1`, `VICTORY_TEXTURE_MAX_DIM=1024` | ~1.5–4 GB VRAM saved; late/blurry textures as the cost | Dolberthi, Linox, CCS03 | **[SW]** |
| C3 | Separate **render-target room** budget (`VICTORY_CARD_ROOM_FOR_TARGETS_MB=1024`, `VICTORY_TEXTURE_ROOM_PERCENT=86`) | Prevents black/late surfaces when textures starve targets | CCS03, Beaver | **[SW]** |
| C4 | Eviction + bounded pools: `VICTORY_VRAM_EVICT`, `VICTORY_SLOT_EVICT`, `VICTORY_LIST_POOL_MB`, `VICTORY_RAM_TRIM_MB`, staging/snapshot pool caps | Prevents `0x887A0006`, caps commit growth | Dolberthi, XCL amd-dev | **[SW]** |
| C5 | Keep a valid resident mip until its replacement upload runs; coalesce dirty ranges; 32-byte equal-chunk skip | Stops texture thrash and redundant copies | knowledge repo TODOs, AnyXboxX | **[DS]** |
| C6 | `VICTORY_CARD_FETCH_INFLIGHT=0`, `VICTORY_TEXTURE_NO_WAIT=1`, `VICTORY_TEXTURE_CATCHUP=0` | Avoids measured 3× GPU-time regressions of inflight=1; keeps frame loop moving | Linox, CCS03, VItoriaBr (negative control: LowBacon, Ryanabcraft) | **[SW]** (hardware-specific!) |
| C7 | Low-commit throttle, commit-reserve floor, `XCL_DSTORAGE_MEMORY_BUDGET_MIB`, 4 KiB-aligned VRAM packing | Commit exhaustion (error 1455) containment | XCL amd-dev | **[DS]** |
| C8 | **RAM↔VRAM tradeoff datapoint:** CGBJ (private) claims 25 fps with only **8 GB system RAM** but **16 GB VRAM** | Proves host RAM footprint collapses when textures stay resident on the card | PortWatch-verified video, no code | **[NT for you]** — you have the *inverse* budget (6 GB VRAM), so expect host mirrors to grow. Plan for it. |

### 1.D Tooling / infra breakthroughs

| # | Breakthrough | Effect | Reuse |
|---|---|---|---|
| D1 | GPU BCPack decode (bcpack-gpu-hlsl, MIT/Apache): BC1 11.33 GB/s vs ~40 MB/s CPU; VRS +31.6%; descriptor paging 1.25M → 262K slots | Streaming/late-texture cure in principle | **[TL]** — needs shared `ID3D12Device` integration into the layer (non-trivial **[PT]**); synthetic benchmark only so far |
| D2 | CPU BCPack reference decoder (bcpack-rs, MIT/Apache), 0 differing blocks over 85.8M blocks | Correctness oracle / offline conversion | **[TL]** |
| D3 | Driver-blob cache keyed by adapter+driver, sub-2^40 placement, watchdog probes (xbox-hle-lab, MIT) | PSO replay 681 ms → 5 ms | **[TL]** |
| D4 | Defect catalog (gta6-port-knowledge: 305 defects, 13-repo comparison) + workstream hub (license matrix, shader census) | Cross-repo root causes, negative controls, license map | **[TL]** |
| D5 | Static recompilation route (Xbox2Windows, Five Star Recomp, Palmetto) | Menus/cutscene audio at 30 fps; different memory profile (compile only what runs) | **[DS]** — early, but potentially **lighter on RAM** than full HLE translation |

### 1.E Quality breakthroughs

| # | Breakthrough | Reuse |
|---|---|---|
| E1 | RT working on AMD (DexNom, Belobug) and via builder modes (wardevsa) — but RT costs 1.6–2.1 fps at "nearly full RAM" | **[NT]** for a 6 GB card: RT is off the table |
| E2 | 25,742/25,758 shaders translated; all 2,191 vertex shaders pass DXIL validator (DexNom) | **[DS]** translation-correctness methodology |
| E3 | Cache-key discipline: include shader-emitter version, vendor/driver/adapter in the fingerprint (fxceless) | **[DS]** |
| E4 | Matched-scene benchmarking (same scene/save/cache/driver, p50/p95) — multiple self-corrections prove it is needed | **[DS]** |

---

## 2. Can it be reused? Can it be combined?

### 2.1 Reuse classes — the short answer

1. **Switches ([SW]) — freely reusable, within a tree that implements them.** ~25 of the breakthroughs are env-var switches. The catch: switches are not portable across forks by name alone — each tree implements its own subset (VKarameloVI's launcher block must not be pasted into CCS03 blindly). Check `--help`/README per tree.
2. **Patches ([PT]) — reusable with porting effort.** These are the big FPS wins (B3–B9) and crash wins (A3–A8). Fork histories are heavily diverged; graft one patch at a time with the matched-scene method of E4.
3. **Designs ([DS]) — reusable anywhere via clean-room reimplementation**, which is also the *only* license-safe way to move XCL ideas (GPL-2.0-only) into GPL-3.0 VIctory forks.
4. **Tools ([TL]) — directly reusable.** Shader prewarm, BCPack decoders, defect catalog, driver-blob caches are standalone.
5. **Negative results ([NT]) — the most underrated reuse.** The negative-control table (§6 of the main report) saves you from `CARD_FETCH_INFLIGHT=1`, `ASYNC_PRESENT=1`, `FAST_COPY=1`, `INPLACE=2`, `WAVE_WIDE=1` on particle atlas shaders, full DRED, permanent blacklists, 16 mapping threads, Series S + FSR4, and monolithic tree imports.

### 2.2 License gate (hard constraint on "combining")

- **GPL-3.0 family** (Marvisak VIctory + most forks): can share patches among themselves (keep license headers, credit upstream commits).
- **GPL-2.0-only** (XCL): cannot be absorbed into GPL-3.0 trees. Treat as a **design reference only**. The knowledge repo already caught two AvatarManz files that are verbatim XCL code — do not repeat that.
- **MIT/Apache** (bcpack-*, xbox-hle-lab tools, decant): can be integrated anywhere with notices.
- Practical rule: **combine commits within one license family; combine ideas across families; never copy text across the GPL-2/GPL-3 boundary.**

### 2.3 Technical compatibility — what combines well

**Known-good stacks (already proven together in one tree):**
- VKarameloVI stack: B1 + B2 + A7(`BVH_MISS`) + A4(`DYNAMIC_SLOTS`) + A1 + A2 + A10 + B13 + B12(`THIN`/`ASYNC_SUBMIT`/`QUEUE2`/`JOIN_PARTS`) — the most complete measured NVIDIA bundle.
- CCS03 stack: B10 + C2 + C3 + C4 (8 GB laptop profile) — the closest *integrated* memory profile to your card class.
- AvatarManz stack: B12 + A1 + A2 + B13 + A11 — deepest frame-time work, but sized for 24 GB VRAM / 64 GB RAM (re-size the constants before reuse).

**Known-bad combinations (measured regressions — do not combine):**
| Combo | Why not |
|---|---|
| `VICTORY_CARD_FETCH_INFLIGHT=1` + low-VRAM budgets | 3× GPU time on 4070 Ti/5060 Ti/Blackwell tests (but it *helped* on a 3080 Ti — hardware-specific; default 0 for you) |
| `VICTORY_FAST_COPY=1` + `VICTORY_INPLACE=2` + `JOIN_COPIES=1` | All measured worse or broke boot (Ryanabcraft) |
| `VICTORY_FIRSTLANE_OWN=1` + BVH builder | Title crash ~2 min in (corrupted AABBs) |
| Series S + the title's FSR4 path | `0x887A0001` or black frames — use `VICTORY_OWN_UPSCALER=1` |
| `VICTORY_ASYNC_PRESENT=1` on NVIDIA | Crash in `nvwgf2umx.dll` |
| `VICTORY_WAVE_WIDE=1` + particle light-atlas shaders | Can hang the card (use `VICTORY_WAVE_WIDE_SKIP`) |
| Texture budgets + no render-target room | Black/late surfaces (budgets must be partitioned, C3) |
| More threads = more speed (16 mapping threads) | 125 → 260 ms; 8 threads is the sweet spot so far |
| Monolithic merges of fork trees | Destroy auditability; overwrote third-party fixes (DexNom `570a941`) |

### 2.4 Three combination recipes

**Recipe 1 — "6 GB survival" (recommended for you):** base = `JozefDeTremmerie/CCS03` `ccs03` (best integrated 8 GB-class tree, reviewed PRs) **or** `Beaver6513/ztrx-lowvram` (4 GB budget discipline), then cherry-pick *switches* from VKarameloVI's bundle (B1/B2 with smaller budgets), the crash bundle A1–A10, and Pavl3000's indirect/texture-pass patches (B3–B5) if you can port them. License family is uniform GPL-3.0.
**Recipe 2 — "study/benchmark":** `Pavl3000/victory-speed` + `Ryanabcraft/scarlett-victory-bench` — the only trees with clean per-switch measurements on consumer cards, including an **RTX 3050 (6 GB class)**. Use them to learn which switches are worth porting into Recipe 1.
**Recipe 3 — "clean-room ideas":** XCL amd-dev/nvidia-dev (pools, throttles, packing, PSO caches) + bcpack GPU decode + xbox-hle-lab blob cache, reimplemented behind your own flags. Highest ceiling, highest effort.

---

## 3. The workaround: 6 GB VRAM + i7-12th gen + 16 GB RAM

### 3.1 Reality check (do the math before anything else)

| Resource | Your rig | What the public builds want | Gap |
|---|---|---|---|
| VRAM | 6 GB (~4.5–5 GB usable after OS) | 8–16 GB typical; Belobug >16 GB; CGBJ 16 GB | **−2 to −11 GB** → texture mip/budget cuts + eviction are mandatory, not optional |
| System RAM | 16 GB | AvatarManz 40–46 GB; Marvisak ~33 GB commit; Belobug ~22 GB + 33 GB commit; even Beaver (4 GB card) overruns its 3.3 GB VRAM budget | **The real blocker.** 16 GB is below every deep build. CGBJ's 8 GB claim exists only because 16 GB of VRAM absorbed the textures — the exact opposite of your ratio |
| CPU | i7-12th gen (8P+E) | i9-12900K is the reference platform (AvatarManz) | **Match.** CPU is not your problem; 8 translation threads (B12) fit well |
| Driver/OS | Windows + recent NVIDIA driver | Windows 10/11, tiled-resources tier 2 (Linox) | Fine. Keep driver ≥ the one your chosen tree tested |

**Anchor datapoint:** PortWatch/Tom's Hardware note a build playing **90+ minutes on an RTX 3050 (6 GB) without crashes at 1–3 fps**, and Ryanabcraft measured on the same class of card. So a 3060 6 GB *can* run these layers — at slideshow speed. Target outcome for this plan: **menus ~30 fps, world 2–6 fps, 30–90 min sessions** — curiosity/technical demo, not "playing GTA VI".

### 3.2 Base-tree choice for this rig

1. **Primary: `CCS03/ccs03`** — 8 GB laptop profile already partitions texture/target budgets the way a 6 GB card needs; integrated reviewed PRs (integer-blend bypass etc.).
2. **Alternate: `Beaver6513/ztrx-lowvram`** — only tree measured on a 4 GB card; its 1/6-VRAM budget arithmetic is exactly what a 6 GB card needs (budget ≈ 768–900 MB).
3. **Do not start from VKarameloVI/AvatarManz/Belobug trees as-is** — they are tuned for 12–24 GB cards and 32–64 GB RAM; steal their switches, not their defaults.

### 3.3 Concrete 6 GB profile (composite; verify each switch exists in your tree)

```powershell
# --- pixels & console profile -------------------------------------------
--console series-s                 # Series S = a 10 GB unified-memory console; the closest console analogue to this rig
VICTORY_DISPLAY_MODE=1920x1080     # truthful mode; drop to 1280x720 if VRAM still overflows
VICTORY_RENDER_SCALE=0.5           # 0.35-0.5; quarters world pixels
VICTORY_OWN_UPSCALER=1             # NEVER the title's FSR4 path (measured 0x887A0001/black frames)
VICTORY_COMPOSE=1                  # keep the UI plane legible over the soft world

# --- crash bundle (non-negotiable) --------------------------------------
VICTORY_SHOW_AFTER=1               # A1: no present before upload
VICTORY_TEXTURE_BACK=1             # A2: ocean/height readback (boats stop sinking)
VICTORY_BVH_MISS=1                 # A7: stale-BVH containment (cost: no bounced indirect light)
VICTORY_WAVE_WIDE=0                # A5: wave64 safety on NVIDIA
VICTORY_DYNAMIC_SLOTS=262144       # A4: under NVIDIA's 1M cap; 524288 if VRAM allows
VICTORY_D3D12_DRED=light           # A10: cheap breadcrumbs
VICTORY_PIPELINE_WAIT_MS=10000     # A11: PSO patience

# --- 6 GB memory partition (the heart of this plan) ---------------------
VICTORY_TEXTURE_BUDGET_MB=768      # C1: ~1/8 of 6 GB (Beaver rule is 1/6; start lower)
VICTORY_TEXTURE_MAX_DIM=1024       # C2: hard dimension cap
VICTORY_TEXTURE_SKIP_MIPS=1        # C2: drop top mips
VICTORY_CARD_ROOM_FOR_TARGETS_MB=1024  # C3: ring-fence render targets FIRST
VICTORY_TEXTURE_ROOM_PERCENT=80    # C3
VICTORY_CARD_BUFFERS_MIN_MB=1      # B2: GPU compares, small budget
VICTORY_CARD_BUFFERS_MB=512        # B2: down from 1536 on 12 GB cards
VICTORY_CARD_FETCH_INFLIGHT=0      # C6: measured 3x regressions when 1
VICTORY_TEXTURE_NO_WAIT=1          # C6
VICTORY_TEXTURE_CATCHUP=0          # C6
VICTORY_TEXTURE_STAGE_MS=25        # C4: bounded staging
VICTORY_TEXTURE_STAGE_MB=48
VICTORY_VRAM_EVICT=1               # C4
VICTORY_SLOT_EVICT=1
VICTORY_RAM_TRIM_MB=4096           # C4: cap host mirrors; tune with Task Manager
VICTORY_LIST_POOL_MB=256           # C4
VICTORY_RELAY=2                    # Beaver low-VRAM relay mode

# --- CPU / frame loop (i7-12th gen) ------------------------------------
VICTORY_THIN=1                     # B12: 8 draw-translation threads (do NOT raise mapping threads)
VICTORY_ASYNC_SUBMIT=1
VICTORY_QUEUE2=1
VICTORY_JOIN_PARTS=8
VICTORY_HOIST_CLAMPS=7             # B11: GPU 225 -> ~80 ms on AMD; verify on NVIDIA

# --- cold-start hygiene -------------------------------------------------
victory shaders <archives>         # B13: precompile ONCE, offline
victory warm --used                # B13: prewarm before benchmarking
```

Host-side setup (Windows):
- **Pagefile: fixed 48–64 GB on the fastest NVMe.** This is not optional tuning — builds report 22–46 GB of *commit*; with 16 GB physical RAM, error 1455 (commit exhaustion) will hit a default pagefile within minutes. The pagefile turns "won't boot" into "boots, slowly".
- Close background RAM eaters (browsers!), keep Hardware-Accelerated GPU Scheduling on, Windows power plan = High performance, GPU undervolt for sustained boost (a 3060 thermal-throttling is free frame loss).
- Optional: drive the desktop from the iGPU (12th-gen UHD 770) to reclaim ~200–400 MB on the 3060.

### 3.4 Idea bank — 30 ideas with self-critique

Each idea: **claim → critique → verdict.** Verdicts: ✅ do it · ⚠️ conditional · ❌ skip.

**Base & route choice**

1. **Start from CCS03 `ccs03` (8 GB integrated tree).** *Critique:* it is measured at 3–7.8 fps on an 8 GB 4060 laptop, so a 6 GB card will land below that; but its budget partitioning is the closest public starting point and its PRs are reviewed. Verdict: ✅ (with Beaver as fallback/second opinion).
2. **Start from Beaver `ztrx-lowvram` (only 4 GB evidence).** *Critique:* its numbers are the worst-case envelope you need (548 ms/frame), and its 1/6-VRAM arithmetic ports to 6 GB; but the tree is single-purpose and lacks the reviewed crash-PR integrations of CCS03. Verdict: ✅ as reference/second tree; ⚠️ as daily base.
3. **Start from VKarameloVI (20–22 fps!).** *Critique:* that number is a 12 GB RTX 5070 with Series S + 0.5 scale; its defaults assume 1.5 GB card buffers and 12 GB VRAM. Pasting its launcher on 6 GB will OOM the texture heap. Verdict: ❌ as base, ✅ as switch donor.
4. **Use XCL generic stack (runs other games too).** *Critique:* GPL-2.0-only, GTA VI hits a GPU watchdog 3–14 min in even on 16 GB cards, BCPack textures not decoded. More general, less far along for this title. Verdict: ⚠️ follow, don't start here.
5. **Static recompilation route (Xbox2Windows / Five Star Recomp).** *Critique:* appealing RAM story (compile only executed code) and 30 fps cutscene audio reported, but 3D world doesn't draw yet anywhere; 25% progress. Verdict: ⚠️ watchlist — possibly the best future path for low-RAM rigs.
6. **Wait for the official PC release / buy the game.** *Critique:* zero fps today, infinite fps later, no malware risk, no legal risk, and your 3060 will run the real thing with DLSS far better than a leaked build at 3 fps. The leaked build is stolen property. Verdict: ✅ the only idea that is simultaneously the fastest and the cleanest. Everything else on this list is a technical hobby, which is a fine thing to be — just call it that.

**VRAM containment**

7. **Series S profile + truthful 1080p display mode.** *Critique:* Series S is literally a 10-GB-unified-memory target — the closest console profile to this rig; measured as step 1 of the 6→21.8 fps ladder. Risk: some forks ignored `DISPLAY_MODE` (fxceless run 303) — verify in logs. Verdict: ✅.
8. **Render scale 0.5 + own upscaler + compose.** *Critique:* the single biggest measured FPS lever anywhere in the corpus (B1); halves VRAM for render targets; cost is soft image and dark bounced light (already lost to `BVH_MISS`). Verdict: ✅.
9. **Texture budget 768 MB + max dim 1024 + skip mips.** *Critique:* measured 1.5–4 GB VRAM saved across three trees; cost is late/blurry textures — on a slideshow build you will not care. Too-small a budget causes the late-texture complaints, so keep render-target room (idea 10). Verdict: ✅.
10. **Ring-fence render-target room before textures (1024 MB).** *Critique:* this is the fix for "black surfaces" that kills naive texture-budget tuning; free correctness, costs 1 GB of budget headroom. Verdict: ✅ mandatory.
11. **Eviction + bounded pools (`VRAM_EVICT`, `SLOT_EVICT`, `RAM_TRIM`, `LIST_POOL`).** *Critique:* contains the 50-min MMU-fault class and commit creep; measured in Dolberthi/XCL; risk of thrash if trim is too aggressive — tune with a GPU-Z/Task Manager session. Verdict: ✅.
12. **48–64 GB NVMe pagefile.** *Critique:* not a speed trick — a boot trick. 16 GB physical RAM cannot hold 22–46 GB of commit; SSD paging will be slow but alive. Put it on NVMe, not a spinning disk; fixed size avoids resize hitches. Verdict: ✅ mandatory.
13. **iGPU as display adapter.** *Critique:* frees 200–400 MB VRAM and one compositor path; desktop boards with 12th-gen iGPU do this cleanly, laptops with mux-less designs get stutter. Small but real on a 6 GB card. Verdict: ⚠️ easy win if your board allows it.
14. **Lossless Scaling / AFMF-style frame generation on top.** *Critique:* frame gen at 3–6 fps base produces artifacts and latency and costs *more* VRAM — the one resource you lack. Only rational if you first reach 8–10 fps (menus/indoor rooms). Verdict: ⚠️ later, only at ≥8 fps base; expect VRAM cost.
15. **Undervolt the 3060 / raise power limit for sustained boost.** *Critique:* these layers are GPU-bound at high load; 3060s throttle. Gains are small (5–10%) but free and orthogonal. Verdict: ✅.

**CPU / frame loop**

16. **8 translation threads (`THIN=1`), never more.** *Critique:* AvatarManz measured 16 mapping threads *doubling* frame time; your 12th-gen has the same core mix as their reference i9. Verdict: ✅ (resist the "more cores" urge).
17. **Async submit + second queue + joined parts.** *Critique:* measured CPU wins on both vendors (Belobug −40 ms, AvatarManz deep work); risk of ordering bugs, so keep `JOIN_PARTS=8` as measured and test saves. Verdict: ✅.
18. **Indirect-stream surgery (Pavl3000 B3–B5).** *Critique:* the biggest isolated GPU win (99→29 ms GPU on 3080 Ti) and it reduces CPU work too — perfect for a 6 GB card where GPU and CPU both hurt. But it is patch-level work to port. Verdict: ✅ if you can port patches; ⚠️ otherwise send the patch upstream to your base tree.
19. **Async relay fetch + worker sizing (Ryanabcraft).** *Critique:* measured on an RTX 3050 — the exact GPU class of this plan — cutting fetch 150→5 ms. Porting cost is moderate. Verdict: ✅ highest-relevance perf patch for this rig.
20. **Set `VICTORY_CARD_FETCH_INFLIGHT=0` (refuse the "optimism" flag).** *Critique:* three independent negative measurements (3× GPU time) vs one positive on a 3080 Ti; on a starved 6 GB card the negative path is far more likely. Verdict: ✅ (as a negative control).

**Rendering quality surgery**

21. **Kill ray tracing entirely (`BVH_MISS=1`, `--no-rt`, ambient fallback).** *Critique:* RT builders run 1.6–2.1 fps at nearly-full RAM even on big cards; on 6 GB it is fantasy. Cost: flat indirect lighting — acceptable in a technical demo. Verdict: ✅.
22. **`VICTORY_OWN_UPSCALER=1` instead of FSR paths.** *Critique:* the title's FSR4 path is a measured crash source (`0x887A0001`/black frames) and its compute shaders are untranslated; the own-upscaler path is the measured-safe alternative. Verdict: ✅.
23. **Integrate GPU BCPack decode (bcpack-gpu-hlsl) to cure late textures.** *Critique:* 11 GB/s vs 40 MB/s is real — but on synthetic assets; integration needs shared-device work in a GPL-3.0 tree (MIT/Apache code is license-compatible, the *engineering* is not free). Also, on 6 GB your late textures come from budget cuts, not decoder speed — this fixes the wrong bottleneck first. Verdict: ⚠️ great upstream contribution, low priority for this rig.
24. **VRS (variable rate shading) from the toolkit.** *Critique:* +31.6% synthetic; needs integration; interacts with render-scale already doing pixel reduction — diminishing returns stacked under `RENDER_SCALE=0.5`. Verdict: ⚠️ only after the switch bundle is stable.

**Stability & workflow**

25. **Prewarm everything (`victory shaders`, `victory warm --used`, driver blobs).** *Critique:* removes 10–12 s first-use frames and the ~5 GB cold cache rewrite — which on an NVMe-paged system is doubly painful. Costs disk, not RAM/VRAM. Verdict: ✅.
26. **Crash bundle A1+A2+A3+A4+A8+A9 regardless of tree.** *Critique:* these are the difference between "15-minute crash loop" and the 90-minute RTX 3050 session in the news; save-version fail-closed protects your data. Verdict: ✅ mandatory.
27. **Keep `DRED=light` + frame logs + matched-scene benchmarking.** *Critique:* you will iterate on switches constantly; without breadcrumbs you cannot tell a TDR from a bad switch, and the corpus is full of retracted claims from unmeasured comparisons. Verdict: ✅.
28. **RAM upgrade to 32 GB (2×16) or 64 GB (2×32).** *Critique:* 12th-gen i7 boards take cheap DDR4 or DDR5; this is the **single highest-leverage hardware change** — it directly attacks the 22–46 GB commit gap that no switch can fully close. A used 3060 **12 GB** (same GPU, double VRAM) is the second. Verdict: ✅ the best money you can spend on this project — and both parts help every other game too.
29. **Download a "GTA VI PC installer"/prebuilt exe from a random repo.** *Critique:* PortWatch explicitly warns these are malware vectors; the CGBJ launcher saga and 3,007-repo DMCA wave mean most binary drops are unauditable. Verdict: ❌ never.
30. **Build from source of the chosen tree only (no binary builds, no "mod menus").** *Critique:* slower setup, but auditability is the whole reason the fix matrix exists; GPL-3.0 trees must ship their source anyway. Verdict: ✅.

### 3.5 Ranked plan (do these in order)

| Phase | Actions | Expected result |
|---|---|---|
| **0. Hardware truth** | Confirm the card is really 6 GB (some desktop 3060s are 12 GB! `nvidia-smi`). If 12 GB — much of this plan relaxes. Buy RAM to 32/64 GB if any budget exists (idea 28). Set 64 GB NVMe pagefile (12). | Removes the fatal constraints |
| **1. Base** | Clone CCS03 `ccs03` (or Beaver) **from source**, read its README switch list, apply §3.3 *only the switches your tree implements* | First boot / menus at ~30 fps |
| **2. Survive** | Crash bundle (26), prewarm (25), `DRED=light` logs (27) | 30–90 min sessions (3050-class evidence) |
| **3. Contain** | VRAM partition (7–11), pagefile verify via error-1455 watch | World renders 2–4 fps without texture-heap death |
| **4. Speed** | B2 GPU compares at 512 MB, B11 hoist clamps, B12/B17 thread+queue stack, then Pavl3000 (18) and Ryanabcraft (19) patches if porting | Push toward 4–6 fps; indoor rooms maybe 8+ |
| **5. Polish** | iGPU display (13), undervolt (15), frame-gen only if ≥8 fps base (14) | Quality-of-life on a slideshow |
| **6. Contribute upstream** | Send your 6 GB budget findings/patches to the base tree (they all lack 6 GB-class testing) | The scene's first measured 6 GB profile; good citizenship under GPL |

### 3.6 Success criteria (be honest with yourself)

- **Win:** the world renders, you can walk around the prologue at 2–6 fps for 30+ min without device removal, saves don't delete themselves.
- **Stretch:** 8–10 fps indoors/first rooms (matches mravatins/fxceless room numbers on bigger cards after the same levers).
- **Not a win:** "playable GTA VI". No public build is playable on 6 GB today; the ones that are close need 12–16 GB VRAM and 22–46 GB RAM (or hide their code). If the goal is actually *playing*, idea 6 is the answer.

---

## 4. Self-critique of the whole document

1. **Evidence asymmetry.** Everything is second-hand from READMEs/commits; none of this has run on a 6 GB card except the RTX 3050 anecdote and Ryanabcraft's bench. The plan's fps estimates are extrapolations with error bars of ±2×. Falsification method: matched-scene runs (E4) at each phase.
2. **Switch names are tree-local.** §3.3 mixes names from several trees; a given build may implement half of them. The first real work session is "which of these exist in my tree?" — the plan assumes you do that check.
3. **The 16 GB RAM gap is under-discussed in the scene.** Most trees were built on 64 GB machines; even "low VRAM" forks keep huge host mirrors. My pagefile answer keeps it *running*, not fast — paging on NVMe during a 500 ms frame will make it worse before it is better. The RAM upgrade (28) is doing more work in this plan than any switch, and I cannot ship it in a repo.
4. **Recipe mixing risk.** CCS03 + VKarameloVI switches + Pavl3000 patches is *my* composition; no one has validated that combination. The negative-control table reduces but does not eliminate interaction risk (e.g., GPU compares at 512 MB + eviction may thrash; watch logs).
5. **Am I overselling "2–6 fps"?** The RTX 3050 1–3 fps figure is the floor; 3060 6 GB is ~20–30% faster with 50% more bandwidth. The ceiling depends on patches you can actually port. If zero patching happens, expect 1–3 fps in the world — closer to the floor.
6. **License section is not legal advice.** "Clean-room" needs discipline (independent implementation from published specs/behavior, not from reading the GPL-2 code and paraphrasing it) — I flag it, I don't adjudicate it.
7. **The private-build carrot (CGBJ 25 fps on 8 GB RAM) is not actionable.** Its code is offline; treating its claim as a roadmap is exactly how people end up downloading malware "launchers". I cite it only as a RAM↔VRAM tradeoff datapoint.
8. **Ecosystem velocity.** The board moved from ~74% to "Playable 91%" in days; by the time you read this, a public 6 GB-viable tree may exist (or the DMCA wave may have deleted the base you cloned — **clone and mirror now**, licenses permitting). This document is a snapshot of 2026-11-27.

---

## 5. Sources

- Live tracker: [portwatch-vi.xyz](https://portwatch-vi.xyz/) (leaderboard, private builds, news, watchlist; fetched 2026-11-27) — site source `4lwayz/portwatch-vi`.
- Prior audit: [`PORTWATCH_FIX_REPORT.md`](PORTWATCH_FIX_REPORT.md) (2026-11-26), [`PORTWATCH_FIX_MATRIX.csv`](PORTWATCH_FIX_MATRIX.csv), [`portwatch-analysis/`](portwatch-analysis/README.md) (546-repo coverage, 106,106 commits, 6,343 fix headlines, 305-defect catalog).
- Key technical sources named above: `Marvisak/VIctory`, `fxceless/victory-fork`, `lucas-TagDev/VKarameloVI`, `Pavl3000/victory-speed`, `Ryanabcraft/scarlett-victory-bench`, `JozefDeTremmerie/CCS03`, `Beaver6513/ztrx-lowvram`, `Dolberthi/neptune-dolberth-nvidia-8gb`, `Linox-IDK/LNX-victory`, `avatarmanz/VIctory-7900XTX`, `Belobug/VIctory-Belobug-AMD`, `DexNom/VIctory`, `Itsbatt/victory-unified`, `uiliannn/VItoriaBr`, `xcl-dev/xcl`, `POMXARK/bcpack-gpu-hlsl`, `Ahmet-Dedeler/bcpack-rs`, `sub-north/xbox-hle-lab`, `lukinhasnojento/gta6-port-knowledge`.
- News context: Tom's Hardware (Take-Two DMCA, 3,007 repos; RTX 3050 90-min session), PortWatch news (CGBJ in-game report; Belobug ahead; ZETTROX stability; prologue→"Gone Fishing"; new progress scale).
