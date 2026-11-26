# tools/vm — App Sandbox VM automation

Thin scripts over **App Sandbox**'s local HTTP API (via its `asb` SDK module). They create an isolated
Windows guest, attach a real GPU through GPU-PV, run commands over the guest SSH channel, and push
files into it without SCP or shared folders.

## Requirements

1. **App Sandbox installed and its local API running.** Start the host elevated
   (`AppSandbox.exe --headless`, or the GUI, which also starts the API). The API endpoint, token, port
   and pid live in the host's own `host.json` under `<APPSANDBOX>` — that file is **not** part of this
   repository and must never be committed.
2. **An elevated host.** Creating VMs and assigning PCI devices requires administrator rights.
3. **The `asb` SDK on `sys.path`.** Each script prepends
   `$LAB\tools\appsandbox\extracted\headless-api`; point it at wherever you unpacked App Sandbox.
4. **A Windows ISO.** `create_vm.py` expects `$LAB\iso\Windows.iso`.

`LAB` is an environment variable naming your local lab root (`$env:LAB = "C:\lab"`). With `LAB`
unset it defaults to the current directory, so no constant needs editing.

## Scripts

| Script | What it does |
|---|---|
| `create_vm.py` | creates the guest (Win11, 8 GB / 8 cores / 128 GB, **`networkMode=0`**, `gpuMode=0`), generates a random admin password at runtime, writes the connection record to `$LAB\vm\appsandbox-vm.json`, then waits up to 40 min for the guest to come online |
| `assign_gpu.py` | takes a snapshot of the clean guest, shuts it down, sets `gpuMode=1` with the first host GPU, boots again and waits for SSH. GPU assignment only works on a **stopped** VM |
| `vm_exec.py` | runs one command in the guest over SSH and prints stdout/stderr/exit code. Reads until the session closes rather than stopping at the exit code, so buffered output is not lost |
| `push_file_cmd.py` | pushes a file with in-guest `cmd echo` + `certutil -decode` in 3 KB base64 chunks, then joins them. Use when the API's SCP path is unavailable |

## Credentials and state

- No password, token or key is stored in this repository. `create_vm.py` generates the admin password
  with `secrets.token_urlsafe(18)` and writes it to `$LAB\vm\appsandbox-vm.json`, which is outside the
  repo and git-ignored.
- The VM name is a constant in each script; change it consistently.
- **The guest disk is ephemeral.** In the App Sandbox build we used, `snap_take` + restart could revert
  the guest to an earlier image and lose the pushed payload. Keep reports, logs and screenshots on the
  host, and re-push the payload after any restart.

## Gotchas

- The SSH agent splits `&&` into separate shells, so `set VAR=value && tool` never passes the variable.
  Use a `.bat`, or one command per session.
- SSH runs in **session 0**: no desktop, so presentation fails there (`0x887A0022`). Anything that
  presents must run from an interactive logon.
- Do not service Windows with GPU-PV attached, and do not install a vendor GPU driver inside the guest;
  the paravirtualised driver is supplied by the host.
