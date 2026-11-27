# The 20-fps bar: what is physically reachable on a 3060 6 GB laptop — and the workaround that crosses 20

**Generated:** 2026-11-27 UTC · **Target:** RTX 3060 6 GB laptop, i7-12th gen, 16 GB RAM · **Bar:** ≥20 fps or it doesn't count
**Standing note:** public compatibility-layer engineering only; no game files or installers. Companion docs: [`PORTWATCH_BREAKTHROUGH_REUSE_6GB.md`](PORTWATCH_BREAKTHROUGH_REUSE_6GB.md), [`PORTWATCH_720P_BLACKSCREEN.md`](PORTWATCH_720P_BLACKSCREEN.md).

**Make-no-mistake summary:** *real* 20 fps in the open world is not physically reachable on this hardware today (evidence below). *Displayed* ≥20 fps is engineerable and honest if you label it: a 6–10 real-fps base multiplied by driver/overlay frame generation. This doc gives (1) the ceiling math, (2) the Stage-A stack that raises real fps to the maximum this machine can do (≈6–9 interiors, 4–6 world), (3) the Stage-B multiplier that crosses 20 displayed with two independent frame-gen routes, and (4) what real 20 fps would actually take.

---

## 1. The physics: ceiling math (no hype)

Measured anchors, and what they scale to on an RTX 3060 laptop 6 GB (≈8.5–9k Time Spy Graphics; rough ratios: RTX 5070 ≈ 2.5×, RTX 4070 Super ≈ 2.3×, RTX 4060 laptop ≈ 1.2×, RTX 3050 ≈ 0.7× of this GPU):

| Anchor | Hardware | Measured | Scaled to 3060 laptop 6 GB |
|---|---|---|---|
| VKarameloVI full stack | RTX 5070 12 GB | 20–22 fps prologue | ≈ 8–9 fps, minus VRAM/paging penalty → **5–7** |
| zsy-miao perf stack, Series S 50% | RTX 4070 S 16 GB | 4.5–14 fps | **2–6** |
| fxceless best rooms | RTX 4070 | 7–12 fps | **3–5** |
| CCS03 `-Low` prison yard | RTX 4060 laptop 8 GB | 5.5–7.6 fps | **4.5–6.5** |
| Ryanabcraft stack | RTX 3050 8 GB | 1.7–2.0 fps | **2.5–3** |
| "90-min session" anecdote | RTX 3050 6 GB | 1–3 fps | 1.5–4 |

Two structural facts that cap everything:

1. **Below ~720p the frame is CPU/memory-bound, not GPU-bound** — LowBacon measured FSR-on-present with "no frame-rate gain: the frame is CPU-bound". Resolution cuts alone cannot reach 20; the CPU-side patch stack (Stage A) is mandatory.
2. **16 GB RAM is a frame-time tax.** Builds commit 22–46 GB; the pagefile absorbs it, and paging adds spiky milliseconds per frame. CGBJ's famous "25 fps at 8 GB RAM" needed 16 GB VRAM — the exact inverse of this machine.

**Therefore:** real 20 fps in the world needs ≈3–5× more throughput than any 6–8 GB-class result ever published (private CGBJ aside). No switch bundle closes that. What *can* cross 20: real 20+ in menus/cutscenes (already measured at 30 fps), and **displayed 20+ everywhere** via frame generation on a tuned base.

---

## 2. Stage A — raise the real base to the hardware ceiling (≈6–9 interiors / 4–6 world)

Everything here is a measured lever. Use CCS03 `ccs03` as the base (laptop-proven, dGPU selection, Win10 Agility path), then layer:

**A1. Pixel floor (GPU):**
- `--console series-s` + `VICTORY_DISPLAY_MODE=1280x720` (`play.ps1 -Low`) + `VICTORY_RENDER_SCALE=0.35` (0.5 default; 0.35 ≈ 2× fewer pixels again — verify the tree accepts <0.5, else 0.5).
- `VICTORY_OWN_UPSCALER=1` + `VICTORY_COMPOSE=1` (the black-screen fixes — they are also the only way a sub-1.0 scale draws anything).
- `VICTORY_FSR=1` if the tree has it (LowBacon's cheap FSR1-on-present, 720p→1080p): lets the internal res go tiny while the window stays legible.

**A2. CPU-side surgery (the measured frame-time killers):**
| Lever | Source | Measured gain |
|---|---|---|
| `VICTORY_INDIRECT_WINDOW=1`, `RECORDS=64`, `INDIRECT_MERGE=1`, one clamp per run | Pavl3000 | GPU 99 → 29 ms; 5.1 → 8–10 fps (3080 Ti) |
| `VICTORY_HOIST_CLAMPS=7` | Belobug `main` | GPU 225 → ~80 ms (AMD; verify NVIDIA) |
| Async relay fetch + `VICTORY_RELAY=2` + `BACK_PARTS` + right-sized workers | Ryanabcraft (**measured on RTX 3050**) | fetch 150–197 → 1.4–5.2 ms; frames 600–890 → 506–595 ms |
| `VICTORY_CARD_BUFFERS_MIN_MB=1`, `_MB=512` (GPU compares) | VKarameloVI | 11 → 21.8 fps ladder step |
| `VICTORY_HAIR=0` | wardevsa | −~80 ms GPU (hair sim) |
| `VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1` | zsy-miao | removes pitch-black shadow work; part of 2.5–4 → 4.5–14+ fps |
| `VICTORY_WIDE_REFRESH=1`, `JOIN_PARTS`, `BACK_OWN_VIEW`, `INDIRECT_GATHER`, `CARD_HASH_LEN=1`, `-Fast` | CCS03 | copies 60–210 → 38–95 ms; integrated 5.5–7.6 fps |
| `VICTORY_TEXTURE_NO_WAIT=1`, `CARD_FETCH_INFLIGHT=0`, `COPY_PLAIN=1`, `REHASH_RUNS=1`, `MERGE_RUNS=4096` | Linox/fxceless | avoids measured 3× regressions; lookup/hash trims ~14 ms |

**A3. Memory containment (turns paging spikes into steady slowness):** the 6 GB partition from the survival plan (texture budget 768 MB, `CARD_ROOM_FOR_TARGETS_MB=1024`, `SKIP/DROP_MIPS`, `VRAM_EVICT`, `RAM_TRIM_MB`), 48–64 GB NVMe pagefile, and — if one purchase is possible — **32/64 GB RAM: the highest real-fps-per-rupee hardware lever on this laptop** (removes the commit-paging tax that resolution can't fix).

**A4. Machine hygiene:** P-cores only for `victory.exe` (12700H: 6 P-cores; the layer's 8 threads map cleanly), High Performance, plugged in, GPU undervolt/OC, HDR off, borderless window. Prewarm caches (`victory translate --cache --pipelines` / `victory warm --used`), `VICTORY_PIPELINE_PRIORITY=normal`, `VICTORY_NO_WATCHDOG=1`.

**A5. Play where the fps is:** story missions/interiors/prison (the content CCS03 actually measured in). Street chases drop even AvatarManz's 24 GB rig to 6–10 fps. `-Steady` (`VICTORY_GAME_STEP_MS=33`) keeps 4–9 fps controllable (slow-motion clock).

**Stage-A expected result:** prison/interiors **6–9 real fps**, open world **4–6**, heavy streets **2–4**, menus/cutscenes **20–30 real**.

---

## 3. Stage B — cross 20: frame generation on the tuned base

Two independent routes; both documented for RTX 30-series laptops as of Nov 2026. Pick one.

### B1 — Lossless Scaling LSFG (overlay route; recommended first)
- **The laptop superpower:** "LS will draw some of your base-line FPS to work properly (**unless you have Integrated graphics or a secondary GPU**)" — run LSFG on the **UHD 770 iGPU** while the 3060 renders. Frame-gen then costs ~zero base fps (the one advantage your laptop has over a desktop 3060).
- Settings (community consensus + vendor guide): **borderless** 720p window · **LSFG 3** · **Fixed ×3** (7–9 base → **21–27 displayed**; ×2 if artifacts dominate) · **Performance Mode** · flow scale 50–75% · RTSS cap at the real-fps ceiling + "NVIDIA Reflex injection, disable passive waiting, sleep call before frame presentation" for flat frame times.
- If the laptop is MUX-dGPU-only (iGPU off): run LSFG on the 3060, flow scale 50%, expect 1–2 ms + 300–500 MB VRAM cost (tight on 6 GB — drop texture budget to 640 MB).
- Honesty label: displayed 20+; **input rate stays 6–9 Hz**. With `-Steady` the game runs in slow motion, so a 6 Hz input rate is a controllable game.

### B2 — NVIDIA Smooth Motion on the 3060 (driver route)
- Officially RTX 40/50 only — **but two community ports target exactly your class**: `NVSmooth30` (MIT-licensed proxy, patches NvPresent capability checks, retargets SM89 kernels → SM86; **demonstrated on an RTX 3050 Laptop GPU** and RTX 3070) and `dlssg_for_sm86-MFG-version` (Sept 2026, tested RTX 3070; installs `version.dll` + ini beside the rendering exe; MFG variant can multiply further). Both need Smooth Motion enabled per-profile in **NVIDIA Profile Inspector**, and must be re-enabled after driver updates.
- The integration pattern is already proven in this scene: VKarameloVI's `play-nvidia.ps1` runs a renamed `victory_sm.exe` with Smooth Motion enabled per-exe ("motion looks about twice as smooth"). Apply the same: rename the exe, enable the profile, launch.
- ×2 → 12–18 displayed at best base; **use the MFG variant for ×3+ to cross 20** from a 7+ base.
- Safety: these are third-party driver-level proxies. Use the MIT `NVSmooth30` from its official repository, verify source builds, never random binaries (same malware rule as fake GTA installers).

### B1 vs B2
| | LSFG on iGPU | NVSmooth30 / sm86 mod |
|---|---|---|
| Base-fps cost | ~0 (iGPU does the work) | small (3060 does OFA work) |
| Multiplier | ×3+ fixed/adaptive | ×2 (×3+ via MFG variant) |
| Legitimacy | paid Steam tool, supported | experimental driver patch; re-enable per driver |
| Failure mode | overlay conflicts with exclusive fullscreen | driver update resets; profile quirks |
| Verdict | **primary** | **secondary / try after B1** |

**Combined expectation (the honest 20-fps answer):** interiors/prison/story content = 6–9 real → **21–27 displayed** (LSFG ×3) with slow-motion controllability; menus/cutscenes 20–30 *real*; heavy open-world streets = 4–6 real → 12–18 displayed (×3) — accept it or walk; that scene drops 24 GB rigs to 6–10 fps too.

---

## 4. What REAL 20 fps would actually take (make no mistake)

1. **GPU class:** RTX 4070 laptop and up (VKarameloVI's 20–22 fps on a 5070 implies ~8–9 fps on a 3060 *before* VRAM penalties). A 3060 **12 GB** desktop + 32 GB RAM gets closer to 8–12 real in the world — still not 20.
2. **RAM:** 32 GB minimum, 64 GB comfortable (the 22–46 GB commit tax is invisible in GPU benchmarks and fatal to frame pacing).
3. **Or the scene moves:** CGBJ (private) claims 25 fps/8 GB RAM — if that work goes public it is the only known software path to real 20 on mid hardware; the static-recomp route (Xbox2Windows, Five Star Recomp) may eventually compile away the translation tax (Five Star already reports 30 fps in the opening cutscene layer).
4. **Or the official release** — which will run 60+ fps with DLSS on this laptop and is the only version that is both legal and finished.

If the bar is "20 real fps in the open world on this laptop, today, from public code": the correct engineering answer is **no workaround exists** — and anyone selling you one is the mistake. If the bar is "the game *feels* like 20 fps": Stage A + B1 crosses it for the content that matters, today.

---

## 5. Self-critique

1. **Scaling math is approximate** (Time Spy ratios, mixed scenes, self-reported anchors). ±30% error bars; the per-scene table in §1 is the falsifiable part — measure your prison-yard run against CCS03's 5.5–7.6 on the same settings.
2. **Frame gen at 6–9 base is at the edge of LSFG's comfort zone** (users report artifacts below ~15 base). Mitigations: ×2 instead of ×3, Performance Mode, flow scale down, play in slow motion (`-Steady`) where motion per frame is small. It will not look like 60 fps.
3. **NVSmooth30/sm86 mods are experimental** and third-party; forum-verified, not vendor-verified. My recommendation order (LSFG first) accounts for that.
4. **iGPU frame-gen assumes Optimus output routing works with LS on your specific model**; MUX-only models lose B1's zero-cost property. Check both.
5. **Patch-porting optimism:** Stage A combines levers measured on *different* trees (Pavl3000, Ryanabcraft, Belobug) into CCS03. Each needs a matched-scene A/B; gains are not guaranteed to add linearly (they hit different bottlenecks — CPU compare, GPU, fetch — so additive is plausible; multiplicative is not).
6. **The 20-fps bar itself:** I am answering "≥20 displayed" because "≥20 real" is falsifiably impossible on this hardware from public code. If the user rejects displayed fps entirely, §4 is the whole answer and Stage B is not a workaround but a compromise — state this openly rather than pretending otherwise.

## 6. Sources

- Frame-gen facts: WindowsForum "NVIDIA Smooth Motion Runs on RTX 30 Cards via Experimental Mods" (dlssg_for_sm86-MFG-version 2026-09-19, RTX 3070; NVSmooth30 MIT, RTX 3050 Laptop + RTX 3070, NVIDIA Profile Inspector); box.co.uk Smooth Motion support table (40/50 official); nvidiareview.com (OFA/Tensor gating). Lossless Scaling 2026 guide (LSFG 3, fixed ×2/×3, adaptive, borderless, Performance Mode, flow scale); r/losslessscaling threads (iGPU/secondary-GPU mode, RTSS+Reflex tuning, low-base caveats).
- Perf anchors: VKarameloVI README (20–22 fps, 11→21.8 ladder, Smooth Motion pattern), zsy-miao README (4.5–14 fps Series S 50%), fxceless README (7–12 fps rooms), CCS03 branch commits `b85f789`/`5e44caa` (5.5–7.6 fps prison yard, 8 GB laptop), Ryanabcraft PERFORMANCE.md (RTX 3050), LowBacon README (CPU-bound frames, `VICTORY_FSR=1`), Belobug `main` (`VICTORY_HOIST_CLAMPS=7`), wardevsa (`VICTORY_HAIR=0`), AvatarManz (street-chase drops), CGBJ claim via PortWatch news.
