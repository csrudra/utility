# GTA6-btw

GTA6-btw is an experimental Linux/Wine boot-tracing workspace based on [Leonida](https://github.com/ItsNotRexed/Leonida), focused on getting the GTA6 Xbox build running further through its startup/runtime.

> **Status: experimental.** With `victory/` under Proton the game boots, shows its loading screens and loads into the first story mission's world, but runs at about 0.1 fps there and the 3D scene is still black (the HUD draws). Not playable.

## Current progress

- **Wine runtime path working:** cross-build `gta6rt.exe` with clang-cl/lld-link + xwin and run with `LEONIDA_SKIP_INT3=1 ./setup_leonida_wine.sh run`.
- **Startup tracing:** JSONL traces + summaries via `tools/boot_trace.py`; `file_open_failed` now includes capture stacks.
- **XMem fix:** fixed Wine/MSVC static-init issue in `placeholder_api()` so large Xbox `XMemVirtualAlloc` reservations succeed.
- **TLS fix:** general EXE TLS slot-0 redirect for modules with non-zero TLS index. This fixed hardcoded `gs:[0x58]` slot-0 accesses and moved boot significantly further.
- **GameInput fix:** added `GameInput.dll` ordinal `#1` alias for `GameInputCreate`; built with `LEONIDA_SDL3_FETCH=ON`.
- **DirectStorage stub:** added minimal `xcrdapi.dll!DStorageGetFactory` stub to get past unimplemented DirectStorage factory.
- **RAGE device mapping:** mapped `common:` and `platform:` device names to the game package root in the file system shim.
- **RPF/name search:** scanned the full 209GB dump with 6ixpack/sixng and gta6x (name recovery, structured recovery, `.zmt` scan, JOAAT hash checks) - no `version.txt` or `gameconfig.zmt` found by name/hash/extension/content.
- **victory-gta6 / victory-fork:** ported the `common:`/`platform:` mapping to both forks (`crates/victory-hle/src/modules/files.rs`); TLS/GameInput/DStorage/XErrorReport fixes were already present.
- **victory-fork on Linux (Proton-CachyOS):** cross-compiled `victory.exe` for `x86_64-pc-windows-msvc` on Linux using xwin/clang-cl/llvm-lib. Subprocess **probe** pipeline creation in `victory-gpu` (hidden `_pipeline-helper`): child probes PSO creation; on crash/fastfail it refuses, on success parent creates in-process. Avoids vkd3d-proton `__fastfail`/abort kills. Fixed a probe-build bug where missing pipeline library caused all recipe pipelines to be refused with `0xFFFFFFFF` (`drawn=0`). Needs retest. Wine-only run renders white/`drawn=0`.
- **Scarlight (Linux/AMD-focused victory fork):** copied to `scarlight/` (from `pablogonz12/Scarlight`). Ported SEH-guarded PSO creation + subprocess probe pipeline isolation (`VICTORY_PROBE_PIPELINES=1`, hidden `_pipeline-helper`) so vkd3d-proton fastfail/abort PSO crashes are refused instead of killing the process. Using Proton Experimental vkd3d-proton `d3d12.dll`/`d3d12core.dll` overlays removed PSO creation refusals/crashes; a stripped custom compat tool is at `/home/joki/.local/share/Steam/compatibilitytools.d/Proton-CachyOS-Victory`. Cross-checks pass for `victory-gpu` and `victory` on `x86_64-pc-windows-msvc`.
- **victory/ (Belobug AMD fork, current main path):** `victory/` is [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) (lit world, vehicles, distant trees on AMD/Windows) plus Scarlight's Wine/vkd3d-proton fixes (write-watched copy-back, root-signature heap-flag retry, no integer-target blending, `VICTORY_NO_WATCHDOG`) and this repo's SEH/probe PSO isolation, `VICTORY_LOG_FILE`, and int3 handling. See `victory/UPSTREAM.md`. Under Proton-CachyOS-Victory it boots, renders the loading screens and loads the world (`STRY000_INTRO`).
- **Linux/Wine fixes in victory/ (2026-11-25):**
  - *Black screen at 60 fps:* vkd3d-proton (RADV) cannot share a **section view** with the GPU (`OpenExistingHeapFromAddress1`): the GPU reads zeros and its writes never reach the game (`cargo run --example heap_probe` in the prefix shows it). Section views are copied under Wine; private memory stays shared.
  - *The 185 MB GPU heap as one private mapping:* xmem backs it with private memory under Wine instead of a section view, so the GPU uses it in place again (per-frame copies 6-10 GB → ~2 GB; copy time 12-17 s → 1-3 s per world frame).
  - *Crash entering the world:* a tile pointer was rounded down to 64 KiB, which holds on Windows but not for vkd3d's 4 KiB-aligned mappings; fixed.
  - *Pipeline precompile:* vkd3d refuses VIctory's pipeline library, which also stopped the early-start list from being saved. The list is now kept without it: run 2 built 1,584 pipelines while the game created them, no draw waited for a compile, and the world loaded about a minute sooner. vkd3d-proton's and Mesa's caches live in `~/.cache/victory` (see below).
  - *Black 3D world:* two things are needed, neither is in this repo; in game they were only tested together. (1) Microsoft's `d3dcompiler_47` in the prefix (`winetricks d3dcompiler_47`): Wine's (`cachyos-11.0-20261015`) fails to build the indirect-argument clamp and the ambient pass; without the clamp every indirect draw and dispatch is dropped. (2) vkd3d-proton master (tested: `71cae091`): with 5704, some VIctory shaders become invalid SPIR-V; their pipelines crash the driver, or are refused with the pipeline probe on. Replace `d3d12.dll` and `d3d12core.dll` in `<Proton>/files/lib/wine/vkd3d-proton/x86_64-windows/`; copies put into the prefix are overwritten by `proton run`.
  - *First-chance exception log:* the world load raises thousands (25,345 reports in one run); they are now only logged with `VICTORY_CRASH_FIRST_CHANCE=1`.
  - *Where the time goes now:* GPU timestamps show only ~25 ms of real GPU work per world frame, but 4-6 s per frame are spent waiting on fences. VRAM fills to 10.5 of 12 GB and ~7 GB spill to system memory (GTT): the driver moves memory around at each submission. Next: cut VRAM use (Belobug notes the world wants more than a 16 GB card) and look at vkd3d-proton master / Mesa git.
- **Leonida path blocker:** gameconfig load fails (`platform:/data/gameconfig.zmt`, `common:/data/version.txt` not found), `int3` at `+0x2224517` skipped by `LEONIDA_SKIP_INT3`, bad config leads to crash at `game_scarlett_master.exe+0x5b29847` (`host:ucrtbase.dll+0x5fe3a`, memset write 0x0). Next options: supply correct files for this build, or add a temporary Leonida patch around config init to move boot forward.

## Quick start

You need Linux x86_64, Wine, `clang-cl`, `lld-link`, and Python 3. You must provide your own legally obtained GTA6 Xbox files.

```bash
./setup_leonida_wine.sh check
./setup_leonida_wine.sh install-xwin
./setup_leonida_wine.sh build-runtime

export GTA6_DIR="/path/to/GTA6.Xbox.v1.0.2.1"
LEONIDA_SKIP_INT3=1 ./setup_leonida_wine.sh run
```

Inspect traces:

```bash
./setup_leonida_wine.sh traces
python tools/boot_trace.py --latest ~/leonida-wine-logs
```

## Run victory-dexnom (DexNom Runtime + Wine fixes, default)

`victory-dexnom/` is [DexNom/VIctory](https://github.com/DexNom/VIctory) (upstream VIctory up to `940d32f` + the victory-world-runtime Radeon line + DexNom's shader fixes; 25,742 of 25,758 shaders translate) with GTA6-btw's Wine/Linux pieces ported: Wine copy-back into write-watched pages, `VICTORY_NO_WATCHDOG` hooks, `VICTORY_LOG_FILE`, the 1.0.2.1 int3 NOP and `VICTORY_SKIP_INT3`, the early pipeline list kept without a host library, and stack dumps (`VICTORY_STACKS`) written to the log. DexNom's in-place title memory is off by default (`VICTORY_INPLACE`), so the Wine section-view problem does not arise. Its BCPack tables come from upstream (`crates/victory-formats/src/bcpack-tables.bin`, git-ignored, SHA-256 `1F1D4760…`).

```bash
cd victory-dexnom && cargo build --profile diag -p victory --features diagnostics --bins --target x86_64-pc-windows-msvc && cd ..
./scripts/run_victory_proton.sh                      # VICTORY_TREE=victory-dexnom is the default
VICTORY_TREE=victory ./scripts/run_victory_proton.sh # the Belobug-based tree below
```

Each tree keeps its own caches (`~/.cache/<tree>/vkd3d`, and for victory-dexnom `AppData\Local\victory-dexnom\cache` in the prefix); saves are shared.

## Run victory (Belobug AMD fork)

```bash
cd victory && cargo build --profile diag -p victory --features diagnostics --target x86_64-pc-windows-msvc && cd ..
export GTA6_DIR="/path/to/GTA6.Xbox.v1.0.2.1"
./scripts/run_victory_proton.sh
```

The script sets Belobug's `VICTORY_HAIR=1` and Scarlight's Linux settings (`VICTORY_NO_WATCHDOG=1`, `VKD3D_CONFIG=ignore_shared_fence`), skips the title's soft int3 asserts, logs to `/tmp/opencode/victory-trace.log`, and picks the RX 7700 XT. Don't set `VICTORY_PRESENT_TARGET` for normal runs: it is a debug switch that presents an internal texture instead of the game's image (a 1x1 one gives a black screen).

### Shader and pipeline caches

Shaders are translated once and cached; pipelines are built once and cached, and on later runs the ones used before are built ahead, while the game creates them, instead of at their first draw:

| Cache | Where | What |
|---|---|---|
| Shader translations | `<prefix>/drive_c/users/steamuser/AppData/Local/victory/cache/shaders` | console shader → DXIL, per shader |
| Early pipeline list | `.../victory/cache/pipelines/early-pipelines.txt` | pipelines the last runs drew with; started early on the next run |
| vkd3d-proton pipelines | `~/.cache/victory/vkd3d` (`VKD3D_SHADER_CACHE_PATH`) | compiled D3D12 pipelines |
| Mesa RADV shaders | `~/.cache/mesa_shader_cache` (`MESA_SHADER_CACHE_MAX_SIZE=10G`) | driver machine code |

So the **first run** into the world is the slow one (translation and ~2,500 pipeline builds; the loading screen can sit frozen for minutes); let it reach the world once and later runs reuse everything. Deleting these folders forces a rebuild (needed after a driver or vkd3d-proton change only if something looks wrong). `VICTORY_PROBE_PIPELINES=1` probes each new pipeline in a child process first.

## Run Scarlight (older, experimental)

```bash
# Build Scarlight (x64 Windows target, from Linux)
# cd scarlight && cargo build -p victory --target x86_64-pc-windows-msvc --features diagnostics

export GTA6_DIR="/path/to/GTA6.Xbox.v1.0.2.1"
./scripts/run_scarlight_proton.sh
```

`scripts/run_scarlight_proton.sh` defaults to the custom `Proton-CachyOS-Victory` compat tool, `VICTORY_LOG_FILE=Z:\tmp\opencode\victory-trace.log`, and forces the RX 7700 XT via `MESA_VK_DEVICE_SELECT=1002:747e` (override env vars as needed).

## Useful environment variables

| Variable | Purpose |
|---|---|
| `GTA6_DIR` | Path to the GTA6 Xbox package directory |
| `LEONIDA_SKIP_INT3=1` | Diagnostic: skip soft int3 asserts during boot tracing |
| `LEONIDA_WINEPREFIX` | Override Wine prefix (default: `~/.local/share/leonida-wine`) |
| `LEONIDA_XWIN_SDK` | Override xwin SDK path (default: `~/.local/share/xwin-sdk`) |
| `VICTORY_HOST_CACHE_DIR` | Where the run script keeps vkd3d-proton's cache (default `~/.cache/victory`) |
| `VICTORY_DIRECT_MEMORY=1` | victory: let the GPU open section views in place under Wine anyway (to retest newer vkd3d-proton) |
| `VICTORY_WINE_SECTION_VIEWS=1` | victory: keep the GPU heap a section view under Wine (old behaviour) |
| `VICTORY_COPY_MEMORY=1` | victory: copy all title memory, never share it with the GPU |
| `VICTORY_GPU_TIMING=1` + `VICTORY_D3D12_DRED=1` | victory (diagnostics build): GPU time per pipeline every 5 s |
| `VICTORY_CAPTURE=<dir>` | victory (diagnostics build): save presented frames as PNG |

## Notes

- This repo does not include GTA6 game files, assets, keys, or extracted packages.
- Traces/logs can contain runtime details; review before sharing.
- `LEONIDA_SKIP_INT3` is a diagnostic aid, not a fix.

## Legal

For interoperability/research purposes only. Not affiliated with or endorsed by Rockstar Games, Take-Two, or Microsoft.