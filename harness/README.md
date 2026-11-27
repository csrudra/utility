# GTA VI harness — the ONE launcher (6 GB / 16 GB laptop)

**Start with `START.cmd`.** The launcher offers a menu and remembers configuration, but this is an experimental wrapper: scripts are not Windows-validated in this review, and setup can fail on unsupported hardware, fork drift, or toolchain/network problems. Logs are collected under the configured data folder.

```
  [1] PLAY               launcher profiles + live stats (RAM / GPU / VRAM)
  [2] CHECK MY PC        is everything ready?
  [3] DIAGNOSE BLACK SCREEN   read-only checks (no auto-fix)
  [4] TUNE AMBIENT LIGHT      CCS03-only fallback control
  [5] SCENE TEST LOOP    replay the same spot again and again
  [6] CHANGE SETTINGS    game file, folders, start over
  [7] EXPORT LOGS FOR AI makes ONE .zip to send
  [8] OPEN LOG FOLDER
  [9] UPDATE FROM GITHUB get the newest fixes
  [10] Quit
  [11] RESOURCE SNAPSHOT  system totals only; no per-switch attribution
```

## First-time setup (4 basic questions; profile selection if needed)

1. **Where is the game file?** — a file picker opens; choose your `game_scarlett_master.exe`.
2. **Where is the harness?** — choose `victory.exe` (built from CCS03, see below).
3. **Where should logs go?** — pick any folder (default: `harness\data\`). This folder is your "send to AI" bundle.
4. **Windows 10?** — detected automatically; the CCS03-specific D3D12 file check is advisory and does not diagnose every black screen.

When the harness executable is changed or its install path is not recognized, setup asks which engine profile it belongs to. Do not guess: fork/profile mismatch can change the console path and environment switches.

## While the game runs

The game gets its own window. The launcher window shows its health, updated every 2 s:

```
  GAME RUNNING  for 00:12:41
  -------------------------------------------
  CPU             :  61 %
  RAM             : 13.2/15.8 GB   (peak 14.1)
  Windows commit  : 21.4/47.8 GB   (peak 23.0)
  NVIDIA GPU      :  94 %   VRAM 5.4/6.0 GB
  Intel iGPU busy :  38 %  (display copy)
  Game window     : 1920 x 1080  (window bounds; render resolution may differ)
```

The panel attempts to stay **on top of the game** (drag it to a corner). `Game window` reports window bounds only; it does not prove the internal render resolution, upscaler, or present path.

On engines that expose the timing switch, PLAY also offers the default timing or a slow-motion diagnostic. At low frame rates, simulation pacing is fork-specific; selecting “real-time” does not guarantee real-time world simulation.

Every sample is saved to `telemetry-*.csv`. When you close the game you get a summary (peaks, averages) and an offer to **bundle everything for the AI**.

## The AI bundle (`[7] EXPORT LOGS FOR AI`)

Creates `data\exports\gta6-ai-report-<date>.zip` containing:

| File | What an AI reads in it |
|---|---|
| `system.txt` | host inventory and environment settings; GPU counters and selected adapter may be unavailable or incomplete |
| `preflight.txt` | health checks at export time |
| `run-*.log` / `run-*.err.log` | the full harness output (adapter name, `DXGI_ERROR_*`, `0x887A*`) |
| `telemetry-*.csv` | CPU/RAM/commit/GPU/VRAM timeline, 2 s samples |
| `settings-*.txt` | engine, executable/source path, best-effort source revision, run profile, and the `VICTORY_*` environment values |
| `config.json` | paths and launcher settings; review for identifying local paths and custom environment values before sharing |

The zip provides useful evidence, not a guarantee that a root cause can be identified. Review it for local file paths before sharing.

## Automated setup (with caveats)

```
 1. DOWNLOAD   github.com/csrudra/utility -> Code -> Download ZIP -> unzip
 2. DOUBLE-CLICK  harness\START.cmd      (say YES to the auto setup and wait)
 3. PICK YOUR GAME FILE   (one file-picker window)
 4. PLAY
```

Step 2 is the long part (several GB of downloads; a first build can take many minutes). The launcher attempts the following steps, but does not make the build reproducible or guarantee success:

| What | How it gets it | Why |
|---|---|---|
| Harness source code | downloads the current CCS03 `ccs03` branch archive from GitHub | source snapshot used for the build; the branch archive is mutable and the installer does not verify a source checksum |
| "Rust" build tool | downloads `rustup-init.exe` from rust-lang.org and installs it | needed to compile the harness |
| Microsoft build tools | downloads `vs_BuildTools.exe` from Microsoft (only if missing) | the compiler Rust needs |
| The harness itself | compiles it (`cargo build`, 10–40 min may be normal) | a local build is not automatically reproducible or audited: dependencies/toolchain are not pinned by this launcher and artifact hashes/signatures are not recorded |
| Windows 10 D3D12 compatibility files | downloads Microsoft's Direct3D 12 Agility SDK and places the 2 files | one documented CCS03 pipeline-start requirement; not a universal black-screen fix |

Notes for the very first run:
- Before running any downloaded installer, verify its publisher/signature and source. SmartScreen warnings are not proof of safety; stop if a file's origin or signature is unexpected.
- If security software blocks an installer, do not disable protection globally; verify the publisher signature and source first.
- **This project does not distribute game files.** Only use software/content you are authorized to access; the launcher asks you to select an existing executable.
- If setup is interrupted, rerun it. Cargo may reuse completed build artifacts; downloads or installer steps can repeat, so this is not guaranteed to resume every operation.

## Before all this (manual route, if you prefer)

```powershell
git clone https://github.com/JozefDeTremmerie/CCS03
cd CCS03; git checkout ccs03
cargo build --release -p victory        # -> target\release\victory.exe
```

- **Windows 10 / CCS03-specific:** that branch documents Microsoft's *Direct3D 12 Agility SDK 1.614* (NuGet `Microsoft.Direct3D.D3D12`), with `D3D12Core.dll` + `d3d12SDKLayers.dll` in a `D3D12` folder next to `victory.exe`. Verify both files and the selected fork's instructions; this check addresses one possible pipeline-creation failure, not every black screen.
- The game data is **not** and will never be part of this project (leaked, copyrighted build — buy the official release). The launcher only points at files you already have.

## Why this harness (CCS03) and not another

This launcher defaults to CCS03 because the original installer builds that branch and the code includes a CCS03-specific profile. Its public laptop/Series S/slow-motion reports are from particular machines and scenes. Settings are fork-specific: a variable present in the environment is not proof that a binary consumed it. Each run records selected engine, executable, a best-effort source revision, profile, and `VICTORY_*` values; inspect the exact source/build provenance before treating a switch as active.

## Performance expectations

FPS, memory use, and stability vary sharply by fork, scene, GPU, and driver. The ranges elsewhere in this repo are third-party results from named machines, not estimates of your system. The `SMOOTH` profile applies only to the launcher profiles that implement it; foxhound/unified use separate defaults. Slow-motion timing is a separate prompt where supported. Frame generation/interpolation may make displayed motion look smoother, but it does not increase the game's underlying simulation/render rate. See `../PORTWATCH_20FPS_WORKAROUND.md` for why this repo makes no performance forecast.

## Staying up to date — `pull.bat`

Whenever I say "there's a fix", double-click **`pull.bat`** (in the same folder as `START.cmd`). Or use menu **[9] UPDATE FROM GITHUB** inside the launcher.

- For a Download-ZIP folder, it downloads the current `main` archive and copies changed program files while protecting `harness\setup`, `config.json`, and `harness\data`. Other local program-file edits are not preserved.
- For a Git checkout, it updates only a clean `main` branch with a fast-forward; it refuses dirty trees and other branches rather than pulling `main` into them.
- Neither path verifies publisher signatures for the downloaded source archive or provides a reproducible-build guarantee.
- If nothing changed it says "You already have the latest version".
- After an update: close the launcher and double-click `START.cmd` again.

## Try foxhound (the NVIDIA-tuned engine) — optional

[`readmet3xt-lab/foxhound`](https://github.com/readmet3xt-lab/foxhound) is a **VIctory fork tuned for NVIDIA RTX**: DLSS Super Resolution / Frame Generation, the 64→32-lane shader fixes, fewer stalls at scene cuts, and pipeline pre-warming (`warm --used` works there). The fork may share the same save path, but save compatibility has not been tested here; back up saves before switching.

**Install/switch:** `TRY-FOXHOUND.cmd` clones the default branch and builds it when no executable exists. The branch is not pinned; an existing executable is reused without verifying it matches the current source. Keep a known-good backup.
- builds foxhound into `harness\setup\foxhound`; it does not automatically fetch updates for an existing clone or binary
- flips `config.json` to the new engine and saves your old config to `config.json.backup`
- for **DLSS**: install NVIDIA's [Streamline SDK](https://github.com/NVIDIA-RTX/Streamline), then run `TRY-FOXHOUND.cmd -StreamlineDir "D:\sdk\streamline\bin\x64"`
- **switch back any time:** `TRY-FOXHOUND.cmd -Restore`

Play afterwards: `START.cmd` → `[1] PLAY`. The launcher supplies a fork-specific environment bundle, including 768/512 MB settings; confirm in foxhound source that each value is supported and do not treat these as a hard VRAM limit.

**What to expect (maintainer/community reports, not measured by us):** the figures shown elsewhere are tied to named systems and scenes. On a 6 GB RTX 3060, the result is unknown. The fork reports that below 30 fps world simulation slows and recommends 32 GB system RAM; verify the current source and requirements before switching. DLSS Super Resolution is intended for RTX cards; DLSS Frame Generation officially needs RTX 40+ hardware.

## If something goes wrong

### If the picture is black or badly lit

First separate the symptoms; they do **not** share one fix:

| Symptom | Likely layer | What to do |
|---|---|---|
| The whole game window is black | D3D12 pipeline creation, present/upscale/compose path, wrong adapter, unsupported fork switch, or device loss | Run `[3] DIAGNOSE BLACK SCREEN`; attach the latest `run-*.log`, `run-*.err.log`, `settings-*.txt`, and a screenshot. Do not tune ambient for this. |
| Only shadowed rooms/surfaces are black | Missing/incomplete indirect-light path in the selected build | On CCS03, the ambient fallback is a constant approximation, not full global illumination. `[4] TUNE AMBIENT LIGHT` is exposed only for CCS03; start at `0.9`, then A/B `1.2` if needed. Higher values can flatten contrast. For other forks, use only their documented controls. |
| Faces, objects, or textures are black/blotchy | Texture residency/streaming, descriptors, shader translation, or a specific asset path | Do not treat this as an ambient problem. Use the logs and an image from the same scene; changing global light can hide a symptom while leaving the rendering bug. |
| All monitors briefly go black or the driver resets | GPU device removal / TDR / driver issue | Check Windows Event Viewer and DRED/error details. `0x887A0005`/`0x887A0006` alone do not prove VRAM or pagefile exhaustion. |

The current CCS03 source describes its no-ray fallback as a **constant** indirect-diffuse value; its `ccs03/play.ps1` uses `VICTORY_AMBIENT=0.9`, while the implementation's default is `0.6`. That is why a scene can render yet still have poor, flat, or unnaturally dark indirect lighting. It does not recreate bounced light, room adaptation, or the title's full lighting pipeline. “`off`” disables the replacement and leaves the title's output in place; it is an A/B diagnostic, not a guaranteed better picture.

A live check of [`fxceless/victory-fork`](https://github.com/fxceless/victory-fork) on 2026-11-27 found that its ray-tracing builder can produce the title's traced shadows/light after scene streaming, but its own README reports **0.2–3 world fps**, roughly **23–27 GB system memory** and **9.2–9.6 GB VRAM** on one RTX 4070/32 GB test machine; black faces can still occur during the first minutes, and device-loss cases remain unresolved. That is not a practical “lighting fix” for a 6 GB / 16 GB laptop.

The current `victory-unified` README documents an ambient value of `1.25`, but its `scripts/play.ps1` sets `0.8`; the fork's ray-tracing note describes a scene-dependent screen-probe estimate when its BVH builder is off, and says the ambient path is disabled while the builder runs. This repo defaults the unified profile to `0.8`; the CCS03 tuning menu does not transfer its values to another fork. Treat these as fork-specific behavior, not universal brightness settings. Third-party forks and their environment variables are not interchangeable.

For a useful diagnosis, export the exact run log/settings and include: (1) whether the *window* or only parts of the scene are black, (2) whether faces/textures or only shadows are affected, (3) engine name and commit, (4) GPU/VRAM, RAM, Windows version, (5) a screenshot from the same scene. See [the detailed review](LIGHTING_AND_BLACKSCREEN_REVIEW.md).

| What you see | What it means | What to do |
|---|---|---|
| `TRY-FXCELESS.cmd` reports that `try-fxce.ps1` is missing | The engine switcher is not implemented in this checkout; it did not install or change engines. | Do not create a placeholder script. Current upstream ray-tracing results are far beyond a 6 GB / 16 GB budget; see the lighting review. |
| `NativeCommandError ... Compiling ...` during setup | The current code redirects build output separately, but the reported fix has not been run on Windows in this review. | Capture `setup\build-err.log`, `setup\build-out.log`, and the process exit code; don't assume the build can never fail. |
| "BUILD FAILED" | The log/exit code is the evidence; a download, toolchain, disk, source, or compile error may be responsible | Preserve `setup\build-err.log` and `setup\build-out.log`; rerunning may reuse Cargo artifacts but is not guaranteed to resume every setup step. Export via menu `[7]`. |
| "is it rebuilding everything?" | If `victory.exe` exists, setup reuses it by path alone; it does not verify source revision, build options, or provenance before reuse. | Check the binary's source/commit and build logs; don't treat file existence as proof it matches current source. |
| Setup seems stuck at "still building" | First builds can take a long time; elapsed time alone is not a reliable health check. | Inspect recent build output and CPU/disk activity; preserve logs before retrying. |

## Files

| File | Role |
|---|---|
| `START.cmd` | double-click entry point |
| `..\pull.bat` / `..\pull.ps1` | double-click updater — gets new fixes from GitHub (see "Staying up to date") |
| `launcher.ps1` | the one launcher (wizard, menu, live stats, AI export) |
| `preflight.ps1` | full PC check (also callable from the menu) |
| `fix-blackscreen.ps1` | read-only black-screen diagnosis (also callable from the menu; changes nothing) |
| `config.json` | created on first run — your remembered answers |
| `data\` | logs, telemetry, settings, exports (your AI bundle) |
| `setup\` | created by FULL AUTO SETUP: downloaded installers, harness source, build log |

Scripts target Windows PowerShell 5.1. This checkout's scripts have not been executed on Windows in the current review; treat them as unverified until parsing, setup, profile switching, logs, and diagnostics are tested on Windows 10/11. The installer downloads mutable branch archives and third-party tools without a complete reproducible-build or supply-chain verification process. The `VICTORY_*` values are drawn from reports in public GPL-3.0 VIctory-family repos, but support and results remain fork-specific; the harness does not contain the renderer changes themselves.
