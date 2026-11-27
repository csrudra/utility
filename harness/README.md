# GTA VI compat-layer harness for a 6 GB / 16 GB laptop — start here

**Short answer to "which harness?":** the game needs a *compatibility layer* ("harness") to run, and the best one to start with is **CCS03's `ccs03` branch — its `victory.exe` is the harness**. This folder is the custom part around it: preflight checks, a tuned launcher for your RTX 3060 6 GB / 16 GB laptop, and a black-screen fixer.

Why CCS03 and not the others:

| Harness (all `victory.exe`-family) | Verdict for this laptop |
|---|---|
| **CCS03 `ccs03`** | ✅ **START HERE.** Only tree with measured *laptop* runs (prison yard, 5.5–7.6 fps on an 8 GB laptop), auto-selects the laptop dGPU and logs it, Win10 Agility path, built-in 720p (`-Low`), slow-mo clock (`-Steady`), per-PC caches |
| VKarameloVI | Switch donor (20–22 fps stack) — tuned for 12 GB cards, don't run it as-is on 6 GB |
| zsy-miao/victory-perf | Second reference (fastest measured profile); port its switches into CCS03 later |
| Marvisak/VIctory (upstream) | Clean base but ~1 fps and 33 GB commit — research, not play |
| Beaver/ztrx-lowvram | Fallback if VRAM budgets still explode (only 4 GB evidence) |
| XCL | Different stack (GPL-2.0-only), GTA VI dies to a GPU watchdog in 3–14 min — not a starter |
| Random forks / "GTA VI installer" exes / private launchers | ❌ malware vector. Build from source only |

## 0. What you need before anything (legally and technically)

- Windows 10/11 x64 laptop, AVX2 CPU (your i7-12th gen ✅), D3D12 GPU with SM 6.6 + mesh shaders (RTX 3060 ✅), Rust (pinned by the repo's `rust-toolchain.toml`), Git, ~30 GB free disk.
- The game data itself is **not** provided here and never will be (it is a leaked, copyrighted build; buy the official release when it lands). This harness assumes you already have a legally obtained dump — no downloads, no installers from this project.
- Expectation management: 6–9 real fps in interiors / 4–6 in the world, 20+ *displayed* with frame generation (see §4). Not "playing GTA VI".

## 1. From zero to first picture

```powershell
# 1. Get and build the harness (CCS03, branch ccs03)
git clone https://github.com/JozefDeTremmerie/CCS03
cd CCS03; git checkout ccs03
cargo build --release -p victory        # produces target\release\victory.exe

# 2. Windows 10 only: Agility SDK (WITHOUT THIS THE SCREEN STAYS BLACK on Win10)
#    Download Microsoft.Direct3D.D3D12 1.614 (NuGet), extract, copy
#    D3D12Core.dll + d3d12SDKLayers.dll into a "D3D12" folder BESIDE victory.exe
#    Windows 11: skip this step.

# 3. Preflight — checks GPU/driver/RAM/pagefile/disk/HDR and prints fixes
powershell -ExecutionPolicy Bypass -File harness\preflight.ps1 `
    -VictoryExe target\release\victory.exe

# 4. Play (720p + slow-mo clock + smooth textures is the recommended profile)
powershell -ExecutionPolicy Bypass -File harness\play.ps1 `
    -Title "D:\games\GTA6\game_scarlett_master.exe" `
    -VictoryExe "C:\src\CCS03\target\release\victory.exe" `
    -Prewarm
```

First run (or any run after a driver/update): let `-Prewarm` finish — it translates shaders and builds the per-PC pipeline cache (several GB, that is why you kept 30 GB free). A cold run compiles ~5 GB of pipelines live and the title's watchdog kills the run to a black screen.

## 2. The scripts

| File | What it does |
|---|---|
| `preflight.ps1` | Hardware/OS gate: OS version + Win10 Agility check, GPU + driver, RAM + committed headroom, pagefile size, disk space, HDR state, AVX2. PASS/FAIL with the exact fix per failure |
| `play.ps1` | The launcher: sets the measured CCS03 bundle + 6 GB overrides + all black-screen fixes, then runs `victory.exe run <title> --execute --console series-s`. Profiles: `-Low` (720p), `-Steady` (game clock 33 ms → controllable slow motion), `-Smooth` (bounded texture pass), `-Fast`, `-Diag` (logs why draws drop), `-NoWatchdog`. Logs every run |
| `fix-blackscreen.ps1` | The diagnosis ladder from `PORTWATCH_720P_BLACKSCREEN.md`, automated: adapter check, upscaler/compose env, Win10 Agility, pipeline cache, pagefile, HDR, and the `VICTORY_PRESENT_PLANE` isolation trick |

Unknown `VICTORY_*` variables are ignored by builds that don't implement them, so the launcher's union bundle (CCS03 + VKarameloVI + Belobug + zsy-miao switches) is safe on any VIctory-family tree.

## 3. If the screen is black

Run `harness\fix-blackscreen.ps1`. The four causes that cover ~all reports, in order: wrong tree → FSR path without `VICTORY_OWN_UPSCALER=1` → missing compose (`VICTORY_COMPOSE=1`) → Win10 without the Agility `D3D12\` folder. Laptop extra: the run must be on the **NVIDIA** GPU — `play.ps1` tells you how to confirm the adapter line in the log and force it.

## 4. Reaching 20+ (displayed)

`PORTWATCH_20FPS_WORKAROUND.md` has the full math. The short version, after the base is stable:

1. **Lossless Scaling (Steam) → run LSFG on the Intel iGPU** while the 3060 renders: LSFG 3, Fixed ×3, borderless 720p, Performance Mode, flow scale 50–75% → 6–9 real → **21–27 displayed** at ~zero base cost.
2. Alternative: NVIDIA Smooth Motion ported to 30-series (`NVSmooth30`, MIT — demonstrated on an RTX 3050 Laptop) with the `victory_sm.exe` rename pattern. ×2 unless you use the MFG variant.

## 5. Provenance

- The launcher bundles switches measured in: JozefDeTremmerie/CCS03 (GPL-3.0-or-later), lucas-TagDev/VKarameloVI, Belobug/VIctory-Belobug-AMD, zsy-miao/victory-perf, fxceless/victory-fork, Pavl3000/victory-speed, Ryanabcraft/scarlett-victory-bench, Linox-IDK/LNX-victory, wardevsa/victory-pc-layer, Beaver6513/ztrx-lowvram — all GPL-3.0-or-later. Switch names only; no upstream code is copied here.
- These scripts are provided as-is; they were written for Windows and reviewed statically (this workspace is Linux, so they are untested on a live machine — run `preflight.ps1` first and read what it prints before the first launch).
