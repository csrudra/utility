<p align="center">
  <strong><a href="https://t.me/projectleonidal">Telegram — Leonida Legacy</a></strong>
</p>

<h1 align="center">
  <br>
  <a>
  <img src="https://raw.githubusercontent.com/ShinniUwU/leonida/89b95f3e2215cc7b078618c2878ded1567a3be18/assets/logo.png" alt="Leonida Legacy" width="200">
</a>

  <br>
  <b>Leonida Legacy</b>
  <br>
</h1>

<h4 align="center">Grand Theft Auto VI (Xbox Series) running natively on Windows, from your own copy.
</h4>

<p align="center"><i>Continued by <a href="https://github.com/orkan1k">orkan1k</a>.</i></p>

> *ItsNotRexed just wanted to play on the PC.*

<p align="center">
  <a href="#status">Status</a> |
  <a href="#getting-started">Getting started</a> |
  <a href="docs/fork-notes.md">Fork notes</a> |
  <a href="#contact">Contact</a> |
  <a href="#credits">Credits</a> |
  <a href="#license">License</a>
</p>

Leonida Legacy is a compatibility layer. The game's x86-64 code runs unchanged inside our process, and Leonida
Legacy supplies the console platform underneath it: the loader, the runtime services, a Direct3D 12 back end and a
shader recompiler that turns the console's GPU code into DXIL on first use. See
[docs/architecture.md](docs/architecture.md).

It is a fork of [victory-gta6](https://github.com/fxceless/victory-gta6), itself a fork of
[VIctory](https://github.com/Marvisak/VIctory).

> [!IMPORTANT]
> This repository **does not contain the game, keys or an executable**. You need your own copy of the game.
> Everything the tools make from your files (translated shaders, caches, saves, logs) stays outside the repository
> and on your PC. Never share those files.

## Status

**Not playable yet: 2 to 4 frames per second by default, and shadowed areas are black.** Tested on Windows 11 Pro,
AMD Ryzen 7 7800X3D, NVIDIA RTX 3080 12 GB, 32 GB RAM, Series X profile. The world frame rates below were measured
by victory-gta6 on an RTX 4070 and have not been measured again on this machine yet.

| Stage | State |
|-------|-------|
| Boot, menus, start screen | works, 30 fps |
| Opening cutscene | plays from start to finish, lit |
| Saves | the game autosaves a checkpoint and loads it again |
| First gameplay scene | renders characters, textures, sky and the sunlit exterior; HUD, pause menu and pad input work |
| Light in shadow | missing: ray-traced bounce light and shadows don't run yet, so anything out of direct sun is black |
| Frame rate in the world | 2-4 fps by default; about 10 fps in the first rooms with the newer switches, all off by default |

Known problems:

- The first gameplay room is sometimes not drawn after the cutscene hands over to gameplay.
- Around 24 GB of memory is in use during play.
- Many changes are specific to this game and this GPU; some are marked `shortcut:` in the code.

The full measurement log, what each switch does and the debugging options are in
[docs/fork-notes.md](docs/fork-notes.md).

## Getting started

Requirements: Windows 10/11 x64, a CPU with AVX2, a Direct3D 12 GPU with shader model 6.6 and mesh shaders, Rust
(pinned in `rust-toolchain.toml`), and several GiB of free Windows commit at startup (if `crashes.log` reports
Windows error 1455, close other applications or make the paging file bigger).

```powershell
cargo xtask install-hooks                # asset-policy check on every commit
cargo test --workspace                   # needs no game data

cargo build --release -p leonida
target\release\leonida.exe run --execute # asks for your game folder the first time
```

The first run asks for the folder of your copy of the game (the one with `MicrosoftGame.config` in it) and saves it to
`leonida.toml`, which git ignores. `leonida config` shows what is set, and `leonida.example.toml` lists the other
settings.

`run-gta6.ps1` does the build and the run in one step, with the frame-rate switches that measured faster (they are
off by default). It asks for the game folder too, and whether to remember it:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-gta6.ps1
```

`measure-gta6.ps1` does the same with the diagnostics build, the frame log and the card meter on, and saves
everything the game prints to `%LOCALAPPDATA%\leonida\logs`.

`shot-run.ps1` runs the game unattended and takes frame shots (`-ShotAt`, with `-Keys` to get through the menus) into
`%LOCALAPPDATA%\leonida\shots`. Shots come from your game: keep them on your PC.

If the GPU driver crashes while building one shader's pipeline, `LEONIDA_SKIP_PIPELINES=<16-digit shader hash>` keeps
that pipeline from ever reaching the driver (its draws are dropped).

Saves, settings and `crashes.log` are kept in `%LOCALAPPDATA%\leonida\data`, derived data in
`%LOCALAPPDATA%\leonida\cache`.

Input: XInput pads. With none connected, the keyboard acts as a pad while the game's window has focus:

| Keys | Pad |
|------|-----|
| W A S D / I J K L | left / right stick |
| arrows | D-pad |
| Enter, Backspace, X, Y | A, B, X, Y |
| Q / E, Z / C | shoulders, triggers |
| F / H | stick clicks |
| Esc, Tab | Menu, View |

## Contact

- **Discord:** [discord.gg/dxMD2XqyEJ](https://discord.gg/dxMD2XqyEJ)
- **Telegram:** [@wouldscams](https://t.me/wouldscams)
- **News & updates:** [Leonida Legacy on Telegram](https://t.me/projectleonidal)

## Credits

- **[victory-gta6](https://github.com/fxceless/victory-gta6)** by fxceless is the fork this repository continues
  under the name Leonida Legacy, with its history kept.
- **[VIctory](https://github.com/Marvisak/VIctory)** by Marvisak and its contributors is the base of everything
  here: the loader, the runtime services, the Direct3D 12 back end and the shader recompiler.
- **[XCL](https://github.com/ivall/xcl)** by ivall and its contributors (GPL-2.0-only) was used as a reference for
  how the same game behaves under another layer. Fixes inspired by it were written anew in VIctory's code.
- The guard over every view of a memory page is code by **myokex**
  ([victory-amd](https://github.com/myokex/victory-amd), commit `c6dc4d8`), which adapts pull request #115 by
  Spexivus, its correction by joroyt and a part of VIctory #1122 by tightfall. The read-beside fix for kernel reads
  into title memory is by **Joshua Odom** (commit `10ea38e` of the same fork family).
- Logo: ["Grand Theft Auto VI" icon by SlyDevil](https://www.steamgriddb.com/icon/122618) on SteamGridDB.
- The victory-gta6 changes were developed with [Claude Code](https://claude.com/claude-code).

Grand Theft Auto and all related names are trademarks of their owners. This project is not affiliated with or
endorsed by them.

## License

GPL-3.0-or-later, like victory-gta6 and VIctory. See [LICENSE](LICENSE).
