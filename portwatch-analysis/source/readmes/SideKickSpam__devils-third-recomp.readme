# dt-port: Devil's Third for PC

dt-port is a native PC port of **Devil's Third** (Wii U, 2015) made by **static recompilation**, as a game
preservation project. The game's Wii U program was translated ahead of time into C++, and it runs on our own
implementation of the Wii U's system libraries, with graphics on Vulkan. It is not an emulator: the game's code runs
directly on your CPU.

**No game files are included.** You need your own copy of the game (see [Quick start](#quick-start)). The setup tool
builds the game for your PC from that copy, on your PC.

> dt-port is not affiliated with, endorsed by or sponsored by Nintendo or Valhalla Game Studios. See
> [NOTICE.md](NOTICE.md).

## Quick start

**You need:**

- Windows 10 or 11 (64-bit).
- A graphics card with Vulkan 1.3 drivers (any NVIDIA GTX 900 series or AMD RX 400 series or newer, or a recent Intel
  GPU).
- A CPU from 2013 or later (Intel Haswell, AMD Ryzen or newer).
- About 2 GB of free disk space, plus 14 GB if the game has to be extracted from a `.wua` file.
- **Your own copy of Devil's Third: the North American release with its last update (version 16).** Either:
  - a `.wua` file. Cemu can make one from an installed game: *Tools > Title Manager*, right-click the game,
    *Convert to compressed Wii U archive (.wua)*;
  - or a folder with the extracted title folders (`code`, `content`, `meta`), dumped from your own Wii U (for example
    with the Dumpling homebrew app). It must contain the update too.

**Then:**

1. Download the latest `dt-port-…-windows-x64.zip` from [Releases](../../releases) and unzip it anywhere.
2. Run `DevilsThirdSetup.exe` and choose your `.wua` file or game folder. You can also drop it on the window.
3. The setup checks your copy (title, region, version and a checksum of the game's program), then builds the game.
   Building takes a few minutes and needs no internet connection.
4. You can import your progress from Cemu, which the setup finds by itself, or from any save folder.
5. Press **Play**. Next time, start the game from the shortcut, or run `dt_port.exe`.

When you install a new version of dt-port, the game rebuilds itself the first time you start it (usually within
seconds). Your settings, saves and shader cache are kept.

**Where things are kept:** settings and saves in `%APPDATA%\dt-port`; the built game and the shader cache in
`%LOCALAPPDATA%\dt-port`.

## Features

- **Frame rate:** 50 fps (the original's cap), 60, 120, 144, 240 or unlimited. The game was made for a fixed 50 fps;
  dt-port corrects the parts of it that counted frames instead of time, so movement, combat, enemies, physics and
  cutscenes run at the same speed at any frame rate.
- **Resolution:** the game renders at 720p, 1080p, 1440p, 4K or a custom scale, letterboxed to 16:9. Higher-quality
  shadows are available.
- **Display:** windowed, borderless or exclusive fullscreen (Alt+Enter or F11); vsync off, on or mailbox.
- **Keyboard and mouse:** a raw mouse camera with adjustable sensitivity, rebindable keys, and a mouse pointer in the
  menus.
- **Controllers:** Xbox, PlayStation and Nintendo-style pads, each with its own button prompts in the game. Bindings
  can be changed.
- **PC settings page** (F1 or the Guide button), in the game's own style. It holds the display, graphics, controls,
  audio and camera options, along with all of the game's own options.
- **Sharp subtitles,** drawn at your screen's resolution and resizable.
- **Score Attack:** every weapon in the game can be picked in the loadout, from a weapon menu with pictures, including
  X-gear.
- **Saves:** compatible with Cemu's, and importable from it.

## Known issues

- Only the **North American** release, **version 16**, is supported. Other regions and versions are not.
- **No online multiplayer.** The game's servers are gone, and online modes behave as if there is no connection.
- The Wii U GamePad's **second screen** is not shown.
- The first time a new effect or area appears, the game may stutter briefly while its shaders are prepared. This is
  remembered for next time.
- Very busy areas may drop below the frame rate you chose on slower CPUs. The game's own rendering thread is the
  limit there.
- Button names in the game's text are rewritten for your controller or keyboard in **English only**.
- A rare crash at the start of a movie has been seen once. If it happens to you, please report it with the session
  log (see below).

**Reporting a problem:** please open an issue and attach the newest log from `%APPDATA%\dt-port\sessions\`.
F12 saves a screenshot (to `%APPDATA%\dt-port\screenshots\`) and records where you are standing, which helps a lot.

## Roadmap

These are ideas, not promises.

- **Online multiplayer through a community server.** This means re-creating the game's online services from scratch.
  It is a large project, and nothing has been started yet.
- **A DirectX 11/12 renderer.** Vulkan runs well on every GPU that can run the game. A second renderer would only be
  worth its considerable cost if Vulkan drivers turn out to be a problem for many players.
- **DLSS, or other upscalers.** DLSS needs motion vectors and camera jitter from the game's renderer, which this
  2015 Unreal Engine 3 game doesn't produce. Adding them is research, not a setting. A simpler spatial upscaler (such
  as FSR 1) is more realistic.
- A Linux release (today Linux needs a build from source, see [BUILDING.md](BUILDING.md)).

## Building from source

See [BUILDING.md](BUILDING.md).

## Credits

dt-port's recompiler is based on [XenonRecomp](https://github.com/hedge-dev/XenonRecomp) by hedge-dev and
contributors. The Wii U's behaviour was studied with [Cemu](https://github.com/cemu-project/Cemu),
[decaf-emu](https://github.com/decaf-emu/decaf-emu) and [Dolphin](https://github.com/dolphin-emu/dolphin), whose
authors made this possible. Third-party components and their licenses are listed in [NOTICE.md](NOTICE.md).

## License

dt-port's own code is under the [MIT License](LICENSE). The license covers dt-port only, not Devil's Third or any of
its code, data or assets.

## Disclaimer

dt-port is an independent, non-commercial fan project. It is not affiliated with, endorsed by or sponsored by Nintendo
or Valhalla Game Studios. *Devil's Third* is a trademark of its owners, and Wii U is a trademark of Nintendo. No game
files are included. You must provide your own legally obtained copy of the game, for example dumped from a disc or
console you own.
