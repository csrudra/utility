# xcl-proton-env

> [!WARNING]
> This project was 100% vibe-coded within an hour, with a human **barely** in the loop.
> Do not expect a high-quality product.

Scripts to build and run [XCL](https://github.com/ivall/xcl) (an Xbox Series X|S → Windows
compatibility layer) on Linux with Proton, optionally inside a bubblewrap sandbox.

XCL itself does not officially support Wine yet. See "Known problems" below.

## Requirements

- GE-Proton or Proton-CachyOS. Both ship DXVK and vkd3d-proton, which XCL needs.
- Rust with the `x86_64-pc-windows-msvc` target (`rustup target add x86_64-pc-windows-msvc`),
  plus [cargo-xwin](https://github.com/rust-cross/cargo-xwin) with `clang-cl` and `lld-link`
  (clang/lld).
- `bwrap` (bubblewrap ≥ 0.10), `python3`, `rsync`, `curl`, `unzip`.
- A Vulkan GPU driver with mesh shaders (for example Mesa RADV on RDNA2+, or NVIDIA).
- The XCL submodule: `git submodule update --init --remote --recursive`. Note that the version tracked by the submodule is likely outdated, which is why you should use `--remote`.

## Usage

```sh
./prefix-init.sh                       # pick a Proton, create ./pfx, build + install XCL
./xcl-run.sh /path/to/GameFolder       # run a game (sandboxed)
./xcl-run-unsandboxed.sh /path/to/GameFolder   # run without the sandbox
```

- `GameFolder` is an unpacked game you own: the folder with `MicrosoftGame.config`.
- Game arguments go after `--`.
- Use `-e DIR` to work with an environment other than `./pfx`.
- Run `prefix-init.sh` again to rebuild after updating the `xcl` submodule.
- Smoke test without game files, using XCL's own test title:

  ```sh
  ./xcl-run.sh pfx/pfx/drive_c/xcl/testgame -- --hello
  ```

### Where things are

| Path | What |
|---|---|
| `pfx/xcl-env.conf` | the chosen Proton |
| `pfx/pfx/` | the wineprefix, managed by Proton |
| `pfx/pfx/drive_c/xcl/` | `xcl.exe`, DXC, `testgame/` |
| `pfx/pfx/drive_c/users/steamuser/AppData/Local/XCL/<title>/` | XCL title data: saves, overlay, `logs/xcl.log`, `logs/report.json` |
| `pfx/build/` | XCL source copy and cargo target dir |
| `pfx/cache/` | vkd3d-proton / DXVK / Mesa shader caches |

## The sandbox (`xcl-run.sh`)

- **Network:** none. Only a private loopback interface exists.
- **Files:**
  - Visible: `/usr` (plus the `/bin`, `/lib*` links), a few files from `/etc`, the
    Proton directory, the environment directory, the game folder, and the scripts.
  - Read-only: everything visible, except the persistent data below.
  - Not visible: `/home` or any other user data.
- **Prefix changes are discarded:** the environment directory gets a throwaway overlay,
  so changes the game makes to the wineprefix (DLLs, registry, autostart entries) are
  dropped on exit.
- **Persistent data:** only XCL's title data and the shader caches persist.
- **Devices:** the GPU (`/dev/dri`, `/dev/nvidia*`), `/dev/ntsync`, the X11 socket, the
  PulseAudio/PipeWire socket, and gamepads (`/dev/input`, `/dev/hidraw*`, `/run/udev`).
  - `--no-audio` and `--no-gamepad` remove audio and gamepads.
  - `--wayland` adds the Wayland socket.
  - Gamepad hotplug does not work inside the sandbox: connect the controller first.
- **Other hardening:** private PID, IPC and UTS namespaces, no nested user namespaces,
  all capabilities dropped, a new terminal session, and a cleared environment. Only
  tuning variables are passed through (`XCL_*`, `PROTON_*`, `DXVK_*`, `VKD3D_*`, `MESA_*`,
  `RADV_*`, `WINEDEBUG`, ...).
- `--shell` opens a shell inside the sandbox, for debugging.

Data written by a sandboxed run is still read by later unsandboxed runs (title data,
shader caches). Keep that in mind if you mix the two.

## Known problems (outside these scripts)

- **XCL and vkd3d-proton:** XCL replaces the vtables of D3D12 objects, and vkd3d-proton
  rejects such objects (assertions in some builds, failing calls in others). See
  [ivall/xcl#175](https://github.com/ivall/xcl/issues/175). With GE-Proton11-3, the test title
  gets 36 PASS / 14 FAIL, with the D3D12.X rendering checks failing. The scripts set
  `VKD3D_CONFIG=ignore_shared_fence` by default, the workaround for shared fences from that
  issue; `XCLENV_SHARED_FENCES=1` turns it off.
- **System XGameRuntime:** `System32\xgameruntime.dll` comes from Microsoft's Gaming
  Services and is not available. XCL warns and uses its own partial implementation.
- **userfaultfd:** some XCL features rely on Wine's write watches, which use `userfaultfd`.
  See the issue above.
- **Test title on repeated runs:** its "delete hides the file" check fails on every run
  after the first, because XCL's overlay remembers the earlier run's deletion.

## License

The scripts and documentation in this repository are released into the public domain under
the [Unlicense](LICENSE).

That covers only this repository's own files. The software the scripts use or download keeps
its own license:

- XCL (the `xcl` submodule, not included in this repository): GPL-2.0-only.
- Proton, DXVK and vkd3d-proton: provided by your Proton installation.
- Microsoft's DirectX Shader Compiler, and the MSVC CRT / Windows SDK fetched by cargo-xwin:
  Microsoft's terms.

An environment directory made by `prefix-init.sh` (`pfx/`) contains files covered by those
licenses. It is not part of this project and is not covered by the Unlicense.
