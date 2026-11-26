# VM runbook — reproducible startup (frozen 2026-11-21)

Known-good state, host-side. The guest disk is **ephemeral**: never treat a VM snapshot as the record.
Everything needed to rebuild the guest is here plus `<LAB>/vm/e2e/e2e.zip`.

## 0. Host prerequisites

| Item | Value |
|---|---|
| Host | Windows 11 Home (build omitted), RTX 4070 Ti SUPER, driver `32.0.x` |
| App Sandbox | `0.1.13`, `<LAB>/tools\appsandbox\extracted` |
| API | `<APPSANDBOX>\host.json` (endpoint, token, port, pid) |
| Guest ISO | `<LAB>/iso\Windows.iso` |
| Payload zip | `<LAB>/vm\e2e\e2e.zip` (static-CRT xcl + test title + test game data) |

Start the host (elevated): `AppSandbox.exe --headless`. The GUI also starts the API.

## 1. Create / start the VM

`tools/appsandbox/create_vm.py` — Win11, 8 GB, 8 cores, 128 GB, **networkMode=0**, gpuMode=0.
If the VM already exists, start it with the GPU attached:

```python
import asb
c = asb.connect()
c.start("<VM>")            # boots the current disk
c.wait_online(vm_id=<id>, timeout=420)
```

Assign the GPU only on a **stopped** VM (`tools/appsandbox/assign_gpu.py`):
`c.shutdown` → `c.wait(target_states=["stopped"])` → `c.edit(gpuMode=1, gpuId=host()["gpus"][0]["id"])` → `c.start`.

Do not service Windows with GPU-PV attached (App Sandbox #180). Guest build already equals the host.

## 2. File transfer

The API has no upload and no SSH stdin. Use the loopback SCP port:

```powershell
$info = ssh_info("<VM>")          # host 127.0.0.1, port e.g. 55675
scp -P <port> -i <APPSANDBOX>\ssh\id_appsandbox `
    -oStrictHostKeyChecking=no -oUserKnownHostsFile=NUL -oBatchMode=yes `
    e2e.zip <GUESTUSER>@127.0.0.1:C:/lab/e2e.zip
```

Expand in-guest with an encoded PowerShell command (the agent splits `&&` into separate shells —
never use `set VAR=x && app`):

```powershell
Expand-Archive -Path C:\lab\e2e.zip -DestinationPath C:\lab\e2e -Force
```

Command helper: `tools/appsandbox/vm_exec.py "<command>" [timeout]`. Fallback for small files:
`push_file_cmd.py` (cmd `echo` + `certutil`, 3 KB chunks).

## 3. Build rules

- Rust MSVC **static CRT**: `RUSTFLAGS="-C target-feature=+crt-static" cargo build --workspace`.
  A debug build needs `VCRUNTIME140.dll`; if that DLL is inside the game folder, xcl loads it as a
  game DLL and the title dies silently (exit 101). Never put system runtime DLLs in the game folder.
- Compile probes with `/MT` (e.g. `gpu_probe_mt.exe`, `present_probe.exe`).

## 4. Run on the interactive desktop

SSH runs in session 0: no desktop, so `CreateSwapChainForHwnd` returns `0x887A0022`. Presentation
must run in the logged-on session:

1. `desktop_title.bat` (on the guest):
   `C:\lab\e2e\game\xcl.exe run C:\lab\e2e\game -- --hello > C:\lab\title_desk_out.txt 2>&1`
2. Register an Interactive task and run it:
   `New-ScheduledTaskAction -Execute cmd.exe -Argument "/c C:\lab\desktop_title.bat"`
   `New-ScheduledTaskPrincipal -UserId "$env:COMPUTERNAME\<GUESTUSER>" -LogonType Interactive`
3. `Start-ScheduledTask`, wait ~15 s, read `C:\lab\title_desk_out.txt`.

Do **not** wrap it in `wscript` hidden mode — it hung in a modal WSH state on this guest.
Screenshot the desktop with `asb.screenshot("<VM>")` while the title runs (the window is short-lived;
repeat the title in a loop and sample frames if a capture is needed).

## 5. Expected results

| Check | Expected |
|---|---|
| `gpu_probe_mt.exe` | RTX 4070 Ti SUPER, `0x10de:0x2705`, 16063 MB, FL 12_2, wave 32..32, DXR 1.2, `software=no` |
| `uma_probe.exe` | `OpenExistingHeapFromAddress` 0, 2 GB heap (needs 4 GiB-aligned `VirtualAlloc2`) |
| `present_probe.exe` | swapchain 0, frames presented > 0, visible colour |
| test title (desktop) | `done, failures: 0`, exit 0, `presents: 1` |

Artifacts to pull after every run (host is the record):

```
archive/reports/vm/report-desktop.json
archive/reports/vm/xcl-desktop.log
archive/reports/vm-present.png
archive/reports/vm-title-06.png
```

## 6. Snapshot caveat

`snap_take` + restart reverted the guest to the pre-payload disk even when started by the new
snapshot index. Snapshots `gpu-ok`, `title-e2e`, `desktop-pass` exist, but **verify guest contents**
after any snapshot/start, and re-push `e2e.zip` if needed.

## Artifact checksums (SHA-256, first 16)

| File | Hash |
|---|---|
| `vm/report-desktop.json` | `C5DF9CD8B9EBD653` |
| `vm/xcl-desktop.log` | `649177E914DFF2B4` |
| `vm-present.png` | `A9190410D43151B5` |
| `vm-title-06.png` | `0CD8F3BDF01D6258` |

## 7. First executable run — frozen procedure

> Superseded: the first executable run has been performed; see [FIRST-RUN.md](FIRST-RUN.md) for the measured progression.

**Runtime version is frozen: `lab/nvidia-wave32-v2 @ 217ac85`.** This is the exact build that produced
the 30/30 guest baseline and carried runs 1–3. Run 4 moved to upstream `484dd57`; see
[FIRST-RUN.md](FIRST-RUN.md). Record `git rev-parse HEAD` in the run artifacts, and do not rebase
further before a failure is written up.

Order, no deviations:

1. **Hash** the executable (SHA-256) and record it with size and PE metadata.
2. **`xcl inspect <exe> --json`** — and every shipped DLL — before any launch. Save the JSON.
3. **Launch inside the VM only** (`networkMode=0`, GPU attached, `C:\lab\e2e` re-pushed, static-CRT
   build). Use `log_level = "trace"`, `XCL_DATA_ROOT` under the lab data root.
4. **Capture `report.json`** and stop at the **first** failure. Read `crash`, `called_stubs`,
   `unknown_iids`, `failed_pipelines`, `vfs.unmapped_paths`, `translation_errors`.
5. **Do not retry** before the evidence is written up, and do not patch, rebase or add translators
   from a single failure.

Artifacts for that run go in `archive/reports/first-run/` (binary hash, inspect JSON, report, log,
screenshot if any), with a one-paragraph finding labelled verified / inferred.

The exe never runs on the host.
