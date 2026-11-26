# Sunset Launcher

Build the standalone launcher with `uv run --locked --extra bundle python scripts/build_bundle.py`. To run from source on Linux or Windows, use `uv run --locked sunset-launcher`.

Sunset Launcher is a desktop app for building, updating and launching XCL, Victory, TuxBox, hyphennn, ZTRX and DexNom Runtime. Its project catalog supports x86-64 Linux and Windows. TuxBox targets Linux, so the Windows launcher lists only XCL, Victory, hyphennn, ZTRX and DexNom Runtime.

## Build from source

Install uv and run these commands from the repository root. [uv installation](https://docs.astral.sh/uv/getting-started/installation/)

```sh
uv run --locked sunset-launcher
```

On x86-64 Linux or Windows, build a standalone copy with the same Python and Qt dependencies used by the release.

```sh
uv run --locked --extra bundle python scripts/build_bundle.py
```

Run `dist/SunsetLauncher/SunsetLauncher` (`SunsetLauncher.exe` on Windows) and keep the complete `dist/SunsetLauncher/` directory together. A Linux bundle built on a newer distribution can require a newer glibc. The release workflow builds on Ubuntu 22.04 for wider compatibility.

## Run the Linux download

Download `SunsetLauncher-linux-x86_64.tar.gz` from GitHub Releases and extract it with your archive manager. Open the extracted **SunsetLauncher** folder and double-click the **SunsetLauncher** executable inside. Keep the whole folder together, including `_internal`. If your file manager offers **Run** or **Run as Program** in the context menu, you can use that too. An extractor that preserves Unix permissions keeps the executable ready to run. [GitHub Releases](https://github.com/PelvisBass/Sunset-Launcher/releases)

The archive contains Python and Qt. It targets x86-64 Linux desktops with glibc 2.35 or newer, the baseline for Ubuntu 22.04. Building a translation layer still requires that layer's tools. For example, the TuxBox build uses system Python 3.10+ with `venv` support. If the Qt display fails to start on a minimal installation, see the desktop libraries used in the [CI workflow](.github/workflows/ci.yml).

## Run the Windows download

Download `SunsetLauncher-windows-x86_64.zip` from GitHub Releases, extract it, and run **SunsetLauncher.exe** from the extracted **SunsetLauncher** folder. Keep the whole folder together, including `_internal`. The download is unsigned, so Windows SmartScreen may ask for confirmation the first time. Select **More info**, then **Run anyway**. Building a project still needs Git, Rust and Visual Studio C++ Build Tools. Open **Build setup** for each project's requirements. `SHA256SUMS` on the release page lists the checksums for both downloads.

The launcher checks GitHub for a newer release when it starts. If one is available, a link appears at the bottom of the sidebar.

## Run with Python

You can also use Python 3.10 or newer. On Linux, create a virtual environment and install the launcher.

```sh
python3 -m venv .venv
.venv/bin/python -m pip install .
.venv/bin/sunset-launcher
```

In PowerShell on Windows, use the corresponding virtual environment paths.

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install .
.\.venv\Scripts\sunset-launcher.exe
```

For Linux development with PySide6 already installed, `PYTHONPATH=src python3 -m sunset_launcher` also starts the source checkout.

## Test locally

```sh
uv run --locked python -m unittest discover -s tests -v
uv run --locked python -m sunset_launcher --smoke-test
```

The tests use local Git and Proton fixtures. They cover upstream commit checks, builds, cache cleanup, log retention and the desktop interface. Use `QT_QPA_PLATFORM=offscreen` for the startup check on a headless Linux host.

## Build and launch

1. Install Git, then select a project and open **Build setup** for its toolchain instructions. The launcher runs tools from your PATH.
2. Select **Build** to clone and compile a project. The launcher compares built commits with their upstream branches on startup. Use **Check for updates** to check again. **Update & build** fetches upstream changes, fast-forwards the checkout and compiles. Drag projects to change the order used by **Update & build all**.
3. Set **Shared game path** once. Select an executable to use it across all projects. XCL and TuxBox also accept a folder. On Linux, choose a **Proton version** for XCL, Victory, hyphennn, ZTRX or DexNom Runtime, then select **Launch**. Use **Add Proton** to point to a custom installation's executable `proton` script. Each project remembers its Proton selection and uses a separate compatibility prefix. Use **Launch options** to pass extra settings, as with Steam's launch options. Leading `VAR=value` entries set environment variables, such as `XCL_NETWORK=1` or `DXVK_HUD=fps`, and the rest go to the layer in the position it expects. XCL passes its extra arguments to the game. Victory, hyphennn, ZTRX and DexNom Runtime pass arguments after `--` to the game. Each project keeps its own launch options.

Select **Delete build…** to remove a project's recorded executable and any recorded companion binaries, then build it again when needed. Deletion keeps the checkout, compiler caches, manually added files, game files, saves and Proton prefixes. Builds made by earlier launcher versions record only the main executable.

The launcher measures each project's **Shader cache** after the startup update check. Select **Refresh size** to measure recognized generated shaders and pipelines again. **Clear cache…** asks for confirmation. The next launch may spend longer recompiling shaders. The measurement covers launcher-managed locations and TuxBox's default cache, which may be shared with standalone TuxBox. Custom prefixes and caches, old shared Windows caches, and system-wide driver caches are outside its scope.

If a project shows **Needs setup**, open **Activity** for the missing tools and **Build setup** for its requirements. Other projects in the queue continue. On Linux, the launcher also recognizes tools staged in its data folder under `build-tools/`, including Cargo and Rustup, MinGW-w64, DXC, and the cargo-xwin SDK cache.

Use **Open data folder** to find the checkouts, build artifacts, preferences and logs. **Build folder** opens the selected project's source checkout. **Open prefix** opens its compatibility data once a Proton launch has created it. **Activity** keeps the current and previous launcher job logs.

## Project and runtime details

| Project | Linux | Windows |
| --- | --- | --- |
| [XCL](https://github.com/xcl-dev/xcl) | Rust and POSIX-thread MinGW-w64 build, then selected Proton | Rust MSVC build and native launch |
| Victory | Rust, LLVM and cargo-xwin build, then selected Proton | Rust MSVC build and native launch |
| [TuxBox](https://github.com/brcly/TuxBox/blob/main/examples/lanes/README.md) | Upstream Python build and runner, which use Proton Experimental through umu | Not listed. Use the upstream project directly |
| [hyphennn](https://github.com/fxceless/victory-fork) | Rust, LLVM and cargo-xwin build, then selected Proton | Rust MSVC build and native launch |
| [ZTRX](https://github.com/Zettrox/ztrx) | Rust, LLVM and cargo-xwin build, with experimental Proton launch | Rust MSVC build and native launch on supported NVIDIA hardware |
| [DexNom Runtime](https://github.com/DexNom/VIctory) | Rust, LLVM, cargo-xwin and PowerShell build, with experimental Proton launch | Rust MSVC build and native launch |

- Steam's bundled tools and additional library folders are scanned along with common custom tool locations and Steam Flatpak's user data. Flatpak-only Proton extensions may need a host-accessible Proton installation.
- For out-of-Steam Proton launches, the launcher prefers `umu-run` when installed. It can fall back to the selected Proton build's matching local Steam Linux Runtime and then to direct Proton. Install Proton through Steam or your preferred tool and use **Rescan Steam** to refresh the list. umu may fetch its runtime on first launch. [umu documentation](https://github.com/Open-Wine-Components/umu-launcher#how-do-i-use-it)
- XCL on Linux is experimental. Stock Proton may fail before rendering. If you have a dedicated Wine prefix configured with DXVK and XCL-compatible vkd3d-proton, select it under **Wine prefix** and choose the Proton version used to prepare it. Place the matching x64 `dxcompiler.dll` and `dxil.dll` from a Microsoft DXC release beside `xcl.exe` in the build folder. [Microsoft DXC releases](https://github.com/microsoft/DirectXShaderCompiler/releases)
- Victory and hyphennn have experimental Linux compatibility. Some titles may need a native Microsoft D3DCompiler DLL in the compatibility prefix.
- DexNom Runtime builds from its default Git branch. The build initializes the format tables with the upstream checksum verification script.
- Some TuxBox titles need the built providers staged in a working copy. The upstream runner selects its own Proton on Linux. Use the upstream Lanes homebrew example to check your setup. [TuxBox Lanes example](https://github.com/brcly/TuxBox/blob/main/examples/lanes/README.md#build-and-play)

Compatibility, including whether a particular title runs, depends on the upstream project, build and hardware.

## Add a project

Add one `Project` entry in [src/sunset_launcher/catalog.py](src/sunset_launcher/catalog.py), with a Git repository, input type, and a `Recipe` for every supported host. Recipes define tool dependencies, ordered build commands, an expected artifact path, a launch command and a runtime. Commands use argument tuples, so paths containing spaces travel as single arguments. The existing XCL and TuxBox recipes show Windows executables and Python runners, respectively.

## Artwork

The [harbor backdrop](src/sunset_launcher/assets/harbor.jpg) is *Miami Sunset*, a 2019 photograph by Joe deSousa dedicated to the public domain under CC0 1.0. The image was resized for distribution. The launcher crops and shades it to fit the banner. [Original photograph](https://commons.wikimedia.org/wiki/File:Miami_Sunset_\(45863661094\).jpg) · [CC0 deed](https://creativecommons.org/publicdomain/zero/1.0/)
