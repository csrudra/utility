# Series S + 720p "no screen" — root causes, fixes, and the laptop runbook

**Generated:** 2026-11-27 UTC · **Target:** RTX 3060 6 GB laptop, i7-12th gen, 16 GB RAM
**Symptom:** launching with `--console series-s` (and 720p display mode) shows no picture / a black window.
**Verdict up front:** this is a *documented failure class*, not a mystery. The Series S profile changes the game's entire present path (two planes + an AMD FSR upscale step that does not translate), and four separate repo-level traps can each individually produce a black screen. Fix order below is ranked by (evidence × likelihood).

Legal standing note: analysis of public compatibility-layer engineering only; no game files, no installers, no bypass help.

---

## 1. Why Series S + 720p shows nothing — the mechanism

On the Xbox Series S the title presents **two planes per frame**: the 3D world (1080p-class) and the interface plane (menus/HUD/subtitles at 4K), then upscales the world with **AMD FidelityFX (FSR)** [lucas-TagDev/VKarameloVI README §§1,3,9]. Three consequences, each measured in public repos:

1. **The FSR step draws nothing.** "On Series S the title upscales with AMD FidelityFX (FSR), whose compute programs cannot be translated here, **so that step drew nothing**" (VKarameloVI §3). Worse, when the FSR path *does* run its DLL entry points on NVIDIA it throws `DXGI_ERROR_INVALID_CALL` / `0x887A0001` and kills the run (Itsbatt; zsy-miao/victory-perf: "Avoids AMD FFX FSR4 `DXGI_ERROR_INVALID_CALL` crash via `VICTORY_OWN_UPSCALER=1`"). The title calls FSR **only on its Series S path** (LowBacon/HybridGt). ⇒ *Series S without an own-upscaler patch = empty upscale output or a present failure = black screen.*
2. **Only the world plane is shown unless the layer composes.** "A Series S title presents two planes: the game (1080p) and the interface (4K). **Only the first was shown, so menus, loading screens and subtitles were black until gameplay**" (VKarameloVI §9, ported from fxceless PR 1189 by Tissma95). ⇒ *Series S without the compose patch = black menus/loading — the exact "doesn't show screen" experience at boot.*
3. **Series S render targets are R9G9B9E5 — NVIDIA naming trap.** `VICTORY_RGB9E5_AS_R11=1` exists precisely because "Series S render targets on NVIDIA" need that mapping (Linox-IDK/LNX-victory; it breaks the title's packed light as a cost). ⇒ *On NVIDIA, a tree without Series-S render-target handling can present a black/garbled world.*

And one tree reproduces your symptom verbatim: **"Series S mode (`--console series-s`, lower resolution): it stopped at a black screen"** (LowBacon/HybridGt README) — in that tree the Series S boot is "blocked on device method 0x1c8", i.e. its renderer path was incomplete. ⇒ *A tree/commit without a working Series S path will always black-screen, no matter which switches you set.*

### Why 720p specifically is innocent (mostly)

- `VICTORY_DISPLAY_MODE=1280x720` is a **supported, measured** mode: CCS03's `play.ps1 -Low` uses it, and the RTX 2080 checkpoint (GiovannaSGuerrera) runs the whole Series S profile at 1280x720. VItoriaBr confirms the mechanism: "reduz a resolução interna de renderização mesmo em monitores 4K (a janela apenas faz upscale barato no `Present`)".
- BUT the title can ignore it: fxceless run 303 had `VICTORY_DISPLAY_MODE` silently ignored (still presented 4K) → VRAM blowout on a 6 GB card → device removal → screen goes black. And a swapchain-creation failure can be **masked**: "`PresentX` degrada para headless mascarando falha de criação de swapchain (e a mensagem fala de outra coisa)" (OpenScarlett D-10, confirmed) — the run "works" with no window and a misleading error.
- Windowed/borderless is safer than exclusive fullscreen at 720p on a 1080p laptop panel (Dolberthi ships "windowed mode" as the low-VRAM alternative for a reason).

---

## 2. Diagnosis ladder (do these in order; each takes minutes)

| # | Check | What you're looking for | Fix if it matches |
|---|---|---|---|
| 1 | **Which tree/commit?** | LowBacon-class tree with incomplete Series S path (black at boot, log shows no present) | Use a tree with the Series S present stack: **CCS03 `ccs03`** (laptop-proven), VKarameloVI, zsy-miao, or Linox. This is the most likely cause if you picked a random fork |
| 2 | **The log's adapter line** (CCS03 logs name the GPU in use) | Device = Intel UHD / iGPU, or "no SM 6.6 device" | Force dGPU: NVIDIA Control Panel → preferred GPU; Windows Settings → Graphics → the exe → High performance; `VICTORY_D3D12_ADAPTER=<index\|name>` (CCS03); export `NvOptimusEnablement=1` if the tree lacks laptop selection (pattern from MoonLight/PAG6Port PR #4 "the discrete GPU on laptops") |
| 3 | **Own upscaler set?** | Missing `VICTORY_OWN_UPSCALER=1` → FSR step draws nothing / `DXGI_ERROR_INVALID_CALL` / `0x887A0001` in the log | `VICTORY_OWN_UPSCALER=1` (requires a tree with the hook patch — CCS03/VKarameloVI/zsy-miao have it) |
| 4 | **Compose set?** | Black **menus/loading** but (maybe) world visible later; or `VICTORY_PRESENT_PLANE` unset in a tree that shows one plane only | `VICTORY_COMPOSE=1`; debug with `VICTORY_PRESENT_PLANE=0` then `=1` (Linox) — if one plane shows and the other doesn't, the compose pass is the broken part |
| 5 | **Windows 10?** | **"Without help no pipeline can be made and the screen stays black"** (CCS03 README, exact words) — Win10's built-in D3D12 refuses the title's SM 6.6 directly-indexed descriptor heaps | Agility SDK 1.614: put `D3D12Core.dll` + `d3d12SDKLayers.dll` in a `D3D12\` folder beside `victory.exe` (CCS03 PR 7 / VIctory PR 968), or `VICTORY_D3D12_DIR` (Beaver's Win10 path). **Windows 11 is not affected** |
| 6 | **Pipelines building?** | Log: pipelines refused/skipped, or a cold run with 10–12 s frames → TDR → Windows resets the driver and every monitor goes black (fxceless) | Prewarm (`victory translate`/`victory shaders`, `VICTORY_WARM_CACHE=1`), `VICTORY_PIPELINE_WAIT_MS=10000`, `VICTORY_PIPELINE_PRIORITY=normal` (Linox: default below-normal builders get starved by the title), `VICTORY_NO_WATCHDOG=1`; check Event Viewer for `nvlddmkm` TDR events |
| 7 | **Windows HDR on?** | Swapchain failures/masking; HDR swapchains even run out of memory ("SDR swapchain when HDR runs out of memory", MythosOfs/Orchid; `TrySetHdrModeAsync` blocks device init, xvalkyrie) | Turn **Windows HDR off**; SDR only |
| 8 | **Commit + disk** | Task Manager → Memory → **Committed** at boot ("the title needs several GiB of available Windows commit at startup", Linox); disk free < ~10 GB | 48–64 GB fixed pagefile on the NVMe; free disk for the ~5 GB shader cache (per-PC via `VICTORY_CACHE_DIR` — never reuse a cache copied from another machine/card) |
| 9 | **Screen rarely updates / character teleports** | Descriptor-table refusals in log (thousands/frame) | `VICTORY_DYNAMIC_SLOTS=262144..524288` (VKarameloVI §8 — this exact bug made the screen "rarely update") |
| 10 | **720p ignored → VRAM death** | Log still shows 4K targets; GPU-Z shows VRAM pegged then device removal | Prefer the tree's own flag: CCS03 `play.ps1 -Low` (720p); else 1080p + `VICTORY_RENDER_SCALE=0.5` instead of relying on `DISPLAY_MODE` |

**Quick isolation trick:** run **Series X profile at 720p** (`--console series-x` or omit, with `VICTORY_DISPLAY_MODE=1280x720`). If you get *a* picture (menus at least) but Series S shows nothing, your tree's Series S present path (FSR/compose/RGB9E5) is the confirmed culprit — points 1/3/4. If both are black, it is pipelines/adapter/Win10 (points 2/5/6).

---

## 3. "Something I missed" — the full list (including my earlier plan's gaps)

**Missed switches/patches (these are the screen-fixers):**
1. `VICTORY_OWN_UPSCALER=1` — *the* Series S enabler (FSR draws nothing / crashes). If your tree lacks the hook patch, the switch alone won't save it — you need a tree that has it.
2. `VICTORY_COMPOSE=1` + the compose pass (fxceless PR 1189) — without it menus/loading are black **by design of the present path**.
3. `VICTORY_PRESENT_PLANE=<n>` — debug which of the two planes is broken.
4. `VICTORY_RGB9E5_AS_R11=1` — Series S render targets on NVIDIA (Linox; cost: packed-light artifact).
5. `VICTORY_DYNAMIC_SLOTS=262144+` — NVIDIA 1M-view cap → dropped draws → "screen rarely updates".
6. Win10 Agility SDK `D3D12\` folder — literal "screen stays black" without it on Windows 10.
7. `VICTORY_PIPELINE_PRIORITY=normal` — pipeline builders starve at default priority on a busy laptop.
8. `VICTORY_NO_WATCHDOG=1` + `VICTORY_PIPELINE_WAIT_MS=10000` — cold shader compiles (10–12 s frames) otherwise get killed mid-boot → black.

**Missed laptop mechanics:**
9. **dGPU selection** — laptop adapter choice (CCS03 does it and logs the adapter; other trees may not). MUX/Advanced Optimus → dGPU-only if your laptop has it; else Windows per-app GPU preference + NVIDIA Control Panel.
10. **Windows HDR off** (SDR swapchain).
11. **Windowed/borderless first** (exclusive 720p fullscreen on a 1080p panel is a swapchain-failure risk).
12. **Plugged in + High performance power plan**; laptop GPU on battery will not sustain boost in a 500 ms-frame workload.
13. **`-Steady` (`VICTORY_GAME_STEP_MS=33`)** — at 3–5 fps the world moves in 250–300 ms jumps and is uncontrollable; this makes the game clock run slow-motion instead (CCS03; cutscene audio may drift). *This is the single biggest "actually usable on a laptop" quality lever and it was missing from my earlier plan.*
14. **`play.ps1 -Smooth`** — holds the texture pass to 25 ms / 48 MB a frame; fewer stalls on 6 GB.
15. **`-Diag` run** — logs *why draws are dropped*. Diagnose before tuning.

**Missed in my 2026-11-27 plan (errata, also appended there):** Win10 Agility SDK (§2.5), HDR off, adapter forcing + log check, `PRESENT_PLANE` debug, RGB9E5 mapping, `PIPELINE_PRIORITY`, `-Steady`, per-PC `VICTORY_CACHE_DIR`, windowed-mode preference, and the exact CCS03 invocation (`play.ps1 -Title …\game_scarlett_master.exe`, `--execute --console series-s`). The plan's switch block was also too aggressive in one place: do **not** combine `VICTORY_TEXTURE_BUDGET_MB`-style caps *without* `VICTORY_CARD_ROOM_FOR_TARGETS_MB=1024` — starved render targets are themselves a black-surface cause.

---

## 4. The laptop runbook (RTX 3060 6 GB / i7-12th gen / 16 GB RAM)

### 4.1 Pick the tree: CCS03 `ccs03` (built from source)

Why: it is the only tree with **measured laptop runs** — "the evening's runs on the 8 GB laptop: the player in control in the prison yard, 5.5 to 7.6 fps" (branch commits, 2026-11-25) — it auto-selects the laptop dGPU and logs the adapter, it ships the Win10 Agility path, the compose/upscaler stack, `-Low` 720p, `-Steady`, `-Smooth`, `-Diag`, and per-PC caches. Build: `cargo build --release -p victory` (Rust pinned by `rust-toolchain.toml`; needs AVX2 CPU, SM 6.6 GPU + mesh shaders — the 3060 qualifies).

Alternate with the most explicit Series S present debugging: **Linox-IDK/LNX-victory** (`PRESENT_PLANE`, `RGB9E5_AS_R11`, warm cache). Reference-only for switches: VKarameloVI (compose/upscaler explanations above).

### 4.2 One-time laptop prep

```
1. Windows HDR: OFF.            2. NVIDIA Control Panel: victory.exe → High-performance NVIDIA processor.
3. MUX/Advanced Optimus → dGPU-only mode if available.   4. Power: plugged in, High performance.
5. Pagefile: fixed 48-64 GB on the NVMe.                 6. Disk: keep 30+ GB free (shader + pipeline caches).
7. Close browsers/apps (16 GB RAM is the scarce resource; check Task Manager "Committed" before launch).
```

### 4.3 Launch (the CCS03 way)

```powershell
# first run / after shader-emitter changes: prewarm (builds the per-PC cache)
victory translate --cache --pipelines   # or: victory shaders <archives>; victory warm --used

# play: 720p, steady game clock, smooth texture pass, logs kept per run
powershell -ExecutionPolicy Bypass -File ccs03\play.ps1 `
  -Title <game folder>\game_scarlett_master.exe -Low -Steady -Smooth
```

The script sets CCS03's measured 8 GB/laptop bundle (keep it; it is tuned as a unit):
```
VICTORY_DISPLAY_MODE=1920x1080   # -Low overrides to 1280x720
VICTORY_RELAY=2 VICTORY_ASYNC_SUBMIT=1 VICTORY_QUEUE2=1 VICTORY_INDIRECT_WINDOW=1
VICTORY_COPY_PLAIN=1 VICTORY_TEXTURE_NO_WAIT=1 VICTORY_WIDE_TEXTURES=1
VICTORY_TEXTURE_DROP_MIPS=1 VICTORY_TEXTURE_ROOM_PERCENT=86
VICTORY_CARD_ROOM_FOR_TARGETS_MB=1024 VICTORY_CARD_BUFFERS_MB=768 VICTORY_AMBIENT=0.9
VICTORY_JOIN_PARTS=1 VICTORY_BACK_OWN_VIEW=1 VICTORY_INDIRECT_GATHER=1 VICTORY_CARD_REHASH_RUNS=1
VICTORY_TEXTURE_BACK=1 VICTORY_CARD_HASH_LEN=1
victory.exe run <game folder>\game_scarlett_master.exe --execute --console series-s
```
Add for **6 GB** (the tree's defaults are 8 GB): `VICTORY_TEXTURE_BUDGET_MB=768`, `VICTORY_CARD_BUFFERS_MB=512`, `VICTORY_TEXTURE_SKIP_MIPS=1` (if supported on top of `DROP_MIPS`), and verify the adapter line in the log. Add `VICTORY_OWN_UPSCALER=1` and `VICTORY_COMPOSE=1` explicitly if the script doesn't (they are the black-screen fixes).

### 4.4 If it is *still* black — the last four gates

1. `-Diag` run and read dropped-draw reasons.
2. `VICTORY_PRESENT_PLANE=0` / `=1` (world vs interface plane isolation).
3. Series X profile at 720p for comparison (isolates the Series S path).
4. Event Viewer → `nvlddmkm` TDR / `DXGI_ERROR_*` in the log → map to §2 rows 3/5/6.

### 4.5 Expected result on this laptop (honest)

- The 8 GB laptop reference (RTX 4060-class, CCS03): **5.5–7.6 fps in the prison yard**, world playable in slow motion with `-Steady`, 2.5–31 min per session.
- A 6 GB 3060: expect **3–5 fps** in the same scenes (VRAM budget cuts → more texture pop), menus ~30 fps, sessions of 15–45 min before the known device-removal class. Drivers reset ("every monitor goes black") are a known residual (`0x887A0005` in long fxceless runs is *unfixed*).
- Do not expect "playable GTA VI" — expect a technically fascinating slideshow you can steer with `-Steady`. The official release remains the way to actually play.

---

## 5. Evidence index

| Claim | Source |
|---|---|
| Series S = two planes (game 1080p + interface 4K); compose pass fixes black menus/loading | lucas-TagDev/VKarameloVI README §9 (fxceless PR 1189, Tissma95) |
| Series S FSR step draws nothing (untranslated compute); own upscaler required below scale 1 | VKarameloVI README §3; Marvisak/VIctory README "Upscaling (Series S mode)" |
| Series S + FSR4 → `DXGI_ERROR_INVALID_CALL` / `0x887A0001`; stable with `VICTORY_OWN_UPSCALER=1` | Itsbatt negative-control row (PORTWATCH_FIX_MATRIX.csv #69); zsy-miao/victory-perf README |
| "Series S mode … stopped at a black screen"; Series S boot blocked on device method 0x1c8 | LowBacon/HybridGt README (Progress table + run notes) |
| Win10: no pipeline can be made → "the screen stays black"; fix = Agility SDK 1.614 `D3D12\` | JozefDeTremmerie/CCS03 README "Windows 10" |
| Laptop adapter auto-select + `VICTORY_D3D12_ADAPTER`; 8 GB laptop runs 5.5–7.6 fps prison yard | CCS03 README "Getting started"/branch commits `b85f789`, `5e44caa`, `7fe3ef7` |
| `-Low` = 1280x720; `-Steady` = `VICTORY_GAME_STEP_MS=33`; `-Smooth` 25 ms/48 MB; `-Diag` | CCS03 README "Running" |
| Series S render targets RGB9E5 on NVIDIA; `VICTORY_PRESENT_PLANE` debug | Linox-IDK/LNX-victory README switch table |
| `VICTORY_DISPLAY_MODE` can be ignored (still presents 4K) | fxceless/victory-fork run 303 (fix matrix row 26/§6 of PORTWATCH_FIX_REPORT.md) |
| Swapchain-creation failure masked as headless with a misleading message | OpenScarlett D-10 (gta6-port-knowledge defect catalog, CONFIRMADA) |
| TDR: Windows resets display driver, all monitors black; `0x887A0005` unfixed in long runs | fxceless README; PORTWATCH_FIX_REPORT.md §4 |
| HDR swapchain memory failure → SDR swapchain; `TrySetHdrModeAsync` blocks init | MythosOfs/Orchid `ab5b088`; sammwyy/xvalkyrie `67c209d` (portwatch_unique_fixes.tsv) |
| dGPU selection on laptops, Series S default under 24 GB | amirshaker000/PAG6Port PR #4 `11ed9aa`; MoonLightDEV3 `47eb9a4` (NvOptimusEnablement) |
| Descriptor-table refusals → "screen rarely updated" | VKarameloVI README §8 |
| Pipeline builders starved at default priority | Linox README `VICTORY_PIPELINE_PRIORITY` |
| "several GiB of available Windows commit at startup"; per-PC caches | Linox README; CCS03 `VICTORY_CACHE_DIR` |
| Windowed mode as low-VRAM alternative | Dolberthi/neptune-dolberth-nvidia-8gb README |
