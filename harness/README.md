# GTA VI harness — the ONE launcher (6 GB / 16 GB laptop)

**Double-click `START.cmd`. That's it.** Everything else is automatic: one menu, plain language, your answers are remembered, and all logs live in **one folder** you can zip and send to an AI.

```
  [1] PLAY               recommended settings + live stats (RAM / GPU / VRAM)
  [2] CHECK MY PC        is everything ready?
  [3] FIX BLACK SCREEN   automatic doctor
  [4] CHANGE SETTINGS    game file, folders, start over
  [5] EXPORT LOGS FOR AI makes ONE .zip to send
  [6] OPEN LOG FOLDER
  [7] Quit
```

## First time (4 questions, asked once)

1. **Where is the game file?** — a file picker opens; choose your `game_scarlett_master.exe`.
2. **Where is the harness?** — choose `victory.exe` (built from CCS03, see below).
3. **Where should logs go?** — pick any folder (default: `harness\data\`). This folder is your "send to AI" bundle.
4. **Windows 10?** — detected automatically; if you need the one extra Microsoft file, the launcher checks it before every start and tells you exactly what to do.

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
```

Every sample is saved to `telemetry-*.csv`. When you close the game you get a summary (peaks, averages) and an offer to **bundle everything for the AI**.

## The AI bundle (`[5] EXPORT LOGS FOR AI`)

Creates `data\exports\gta6-ai-report-<date>.zip` containing:

| File | What an AI reads in it |
|---|---|
| `system.txt` | your CPU/RAM/GPUs/drivers/OS/pagefile + the exact settings used |
| `preflight.txt` | health checks at export time |
| `run-*.log` / `run-*.err.log` | the full harness output (adapter name, `DXGI_ERROR_*`, `0x887A*`) |
| `telemetry-*.csv` | CPU/RAM/commit/GPU/VRAM timeline, 2 s samples |
| `settings-*.txt` | every `VICTORY_*` switch used for that run |
| `config.json` | your paths (game/harness/data folder) |

Send that one zip and the AI can debug anything.

## Before all this: get the harness itself (one-time)

```powershell
git clone https://github.com/JozefDeTremmerie/CCS03
cd CCS03; git checkout ccs03
cargo build --release -p victory        # -> target\release\victory.exe
```

- **Windows 10 only:** download Microsoft's *Direct3D 12 Agility SDK 1.614* (NuGet `Microsoft.Direct3D.D3D12`), copy `D3D12Core.dll` + `d3d12SDKLayers.dll` into a `D3D12` folder next to `victory.exe`. Without this the screen stays black — the launcher checks for it and will not let you miss it.
- The game data is **not** and will never be part of this project (leaked, copyrighted build — buy the official release). The launcher only points at files you already have.

## Why this harness (CCS03) and not another

CCS03's `victory.exe` is the only harness with measured **laptop** runs (prison yard, 5.5–7.6 fps on an 8 GB laptop); it auto-selects the laptop's NVIDIA GPU and logs the adapter; it carries the Win10 fix, the Series S black-screen fixes (own upscaler + compose) and the slow-motion clock. VKarameloVI/zsy-miao are switch donors for later; XCL dies to a GPU watchdog in minutes; random forks and "installer" exes are malware traps. Unknown `VICTORY_*` switches are ignored by builds that don't implement them, so the launcher's tuned bundle is safe on any VIctory-family build.

## Honest expectations on this laptop

- **SMOOTH mode (default):** 720p, slow-motion game clock → 6–9 real fps in interiors/prison, 4–6 in the open world, 30 fps menus. Controllable and stable-ish.
- **20+ fps:** not real — displayed. Run Lossless Scaling on the Intel iGPU (LSFG ×3) after the base is stable; see `../PORTWATCH_20FPS_WORKAROUND.md` for the full math.

## Files

| File | Role |
|---|---|
| `START.cmd` | double-click entry point |
| `launcher.ps1` | the one launcher (wizard, menu, live stats, AI export) |
| `preflight.ps1` | full PC check (also callable from the menu) |
| `fix-blackscreen.ps1` | black-screen doctor (also callable from the menu) |
| `config.json` | created on first run — your remembered answers |
| `data\` | logs, telemetry, settings, exports (your AI bundle) |

Scripts are Windows PowerShell 5.1 compatible and were statically reviewed; run `[2] CHECK MY PC` first and read what it prints. Switch values are compiled from measured work in GPL-3.0 VIctory-family repos (CCS03, VKarameloVI, Belobug, zsy-miao, fxceless, Pavl3000, Ryanabcraft, Linox, wardevsa, Dolberthi, Beaver) — no upstream code is copied.
