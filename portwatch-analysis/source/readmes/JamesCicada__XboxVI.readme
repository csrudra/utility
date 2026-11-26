# XboxVI

[![Discord](https://img.shields.io/badge/Discord-join-5865F2?logo=discord&logoColor=white)](https://discord.gg/RTwXeccCqD)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-support-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/jcicada)
[![CI](https://github.com/JamesCicada/XboxVI/actions/workflows/ci.yml/badge.svg)](https://github.com/JamesCicada/XboxVI/actions/workflows/ci.yml)

**XboxVI** runs the Xbox Series build of the game natively on Windows PCs with
NVIDIA graphics cards, from game files you supply yourself. It is a fork of
[ztrx](https://github.com/Zettrox/ztrx), and the successor of GTAVI-Recomp.

**This repository contains no game files or assets.** You need your own copy
of the game. Not affiliated with or endorsed by its developer or publisher.

## Status (2026-11-25)

As reported by ztrx on Windows 11 with an **NVIDIA GeForce RTX 3050** (8 GB):

| | |
|---|---|
| Boot, first-boot screens, intro, opening credits | works |
| Prologue | playable from the cell to the boat chase: cell, cafeteria, robbery, police chase (wanted level, minimap), boat, binoculars |
| Stability | 1 h 30 min+ in one session without a crash |
| Frame rate | 1-3 fps in the world (the first run is slower while shaders translate; they are cached after that) |
| Known problems | anything in shadow is black and bright scenes overexpose (the game's ray-traced lighting does not run yet); some blocky artifacts; boats sit low in the water |

Here on an RTX 4060 (8 GB), i5-13400F and 16 GB RAM: menus at about 30 fps,
about 1.4 fps in the world with the faster settings below. Most of the CPU
time goes to the driver's shader compiler while pipelines are built, and to
copying memory every frame.

## Progress

Work in progress is tracked in the open:

- [Commits](https://github.com/JamesCicada/XboxVI/commits/main) and
  [releases](https://github.com/JamesCicada/XboxVI/releases): every push to
  `main` and every release is posted to the Discord automatically
- [Issues](https://github.com/JamesCicada/XboxVI/issues) and
  [pull requests](https://github.com/JamesCicada/XboxVI/pulls): what is open
  and who is on it

Current focus: CPU overhead (pipeline compiles, per-frame copies) and draws
lost to pipelines the host refuses or has not built yet.

## Requirements

- Windows 10/11 x64, a CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20 series or newer)
- Rust (the version in `rust-toolchain.toml`)
- Several GB of free Windows commit memory (raise the paging file if `crashes.log` reports error 1455)

## Build

```powershell
cargo build --release -p victory
```

## Play

```powershell
powershell -ExecutionPolicy Bypass -File scripts\play.ps1 -Game "<your game folder>\<the game's exe>"
```

`scripts\play.ps1` keeps the shader cache and saves in folders you choose
(`-Cache`, `-Data`) and presses no buttons for you. Controller: XInput pads
(a DualShock/DualSense through DS4Windows works). With no pad connected the
keyboard acts as one while the game window has focus.

## Faster settings (optional, off by default)

`VICTORY_RELAY=2`, or `VICTORY_LATE_WAIT=3 VICTORY_WIDE_BACK=1` cut frame
time on the test machines. Set them in PowerShell before running the script.

## Debugging switches

| Switch | Effect |
|---|---|
| `VICTORY_CAPTURE=<dir>` + `VICTORY_CAPTURE_FRAMES=<list>` | save those frames as PNG (diagnostics build) |
| `VICTORY_KEYS=30:Enter,35:X` | press keys at those seconds (diagnostics build) |
| `VICTORY_D3D12_DRED=1` | on a GPU failure, report the commands in flight |
| `VICTORY_PIPELINE_WAIT_MS=24` | shorter per-frame wait for pipelines still being built |

Diagnostics build: `cargo build --profile diag -p victory --features diagnostics`

## Contributing

Pull requests are welcome; say in yours what you tested and on which GPU and
driver, and whether it was AI-assisted. Never commit game files, shaders in any
form, or logs that quote them. No keys, no decryption, nothing online.

## Community & Updates

**Discord:** [Join the community](https://discord.gg/RTwXeccCqD) for
development updates, testing reports and questions. New commits to `main` and
releases are posted there automatically
([`.github/workflows/discord.yml`](.github/workflows/discord.yml)).

## Support Development

If you find this project interesting and want to support its development,
consider supporting me on Ko-fi: [ko-fi.com/jcicada](https://ko-fi.com/jcicada)

## Star History

<a href="https://www.star-history.com/?type=date&repos=JamesCicada%2FXboxVI">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=JamesCicada/XboxVI&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=JamesCicada/XboxVI&type=date&legend=top-left" />
   <img alt="Star history chart" src="https://api.star-history.com/chart?repos=JamesCicada/XboxVI&type=date&legend=top-left" />
 </picture>
</a>

## License

GPL-3.0-or-later (see `LICENSE`). Based on VIctory (Marvisak), victory-fork
(fxceless) and ztrx (Zettrox).
