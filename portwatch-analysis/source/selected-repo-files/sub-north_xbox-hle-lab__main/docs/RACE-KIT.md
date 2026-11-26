# RACE KIT — first executable intake

Goal: be first to a **credible first-failure report**, not first to download. Every claim must carry
a hash, a size, a PE header and a log.

## 1. Pre-staged state (must be true before the day)

> Superseded: the first executable run has been performed; see [FIRST-RUN.md](FIRST-RUN.md) for the measured progression.

- VM `<VM>` online, GPU-PV attached, `networkMode=0`; snapshot taken after a clean boot.
- `C:\lab\e2e.zip` re-pushed and expanded (the guest disk is ephemeral across snapshot/start).
- **Two runtimes, staged at `<LAB>/tools\race\`:**
  1. `xcl-baseline-217ac85.exe` — frozen baseline, release + static CRT (4,487,168 B, SHA-256 `61C2355F…`).
  2. `xcl-upstream-484dd57.exe` — current upstream, detached worktree at `484dd57`, release + static CRT
     (6,231,040 B, SHA-256 `5131C5DC…`). Both verified with `--version`; neither links VCRUNTIME/MSVCP.
- Probes available: `gpu_probe_mt.exe`, `uma_probe.exe`, `present_probe.exe`, `rootsig_check.exe`.
- Intake script on the host (see §3). One command, one output folder.

**Guest staging (done 2026-11-23):**

```
C:\lab\race\xcl-baseline-217ac85.exe
C:\lab\race\xcl-upstream-484dd57.exe
C:\lab\e2e\game\...          (expanded from e2e.zip)
```

Both run in the guest (`--version` = 0.1.0). Do **not** take a snapshot after staging: in this App
Sandbox build, snapshot/start has reverted the guest disk to an earlier image and lost the payload.
Keep the kit on the live disk and re-push after any restart.

## 2. Acceptance before touching the binary

Reject and stop if any of these fail:

1. SHA-256 is recorded and matches the publisher's (if any).
2. Size is recorded in bytes.
3. PE header parses: machine `0x8664`, subsystem, section table, entry point, timestamp.
4. `xcl inspect <exe> --json` completes and imports classify as HLE / Windows / game DLL / stub.

No hash, no run. No PE header, no run. A ZIP without an exe is not a candidate.

## 3. Intake sequence

```
1. sha256sum <file> ; stat size
2. pe_header <file>            # machine, sections, entry, subsystem
3. xcl inspect <file> --json > inspect.json
4. copy exe + shipped DLLs into the VM (scp over the loopback port)
5. ONE run:
     set XCL_DATA_ROOT=<lab>\run
     log_level = "trace", log_to_stderr = false
     XCL_D3D12_TRACE=1  XCL_CONSOLE_LISTS=1  XCL_FORCE_WAVE32=1
     xcl run <folder> --
6. capture report.json + xcl.log + screenshot if any; copy to host
7. STOP at first failure. Do not retry, patch or rebase.
```

## 4. Report template (one page, publishable)

```
Title: first run — <sha256[:12]>
UTC:
Binary: SHA-256, size, PE machine/subsystem, entry RVA
Runtime: xcl <commit>, build profile, env vars
VM: GPU (name/VRAM/feature level/wave lanes), network none, snapshot name
Result: exit code, first failure (taxonomy item), evidence lines
Imports: resolved / stubbed / called stubs
D3D12: backend, adapter, unknown IIDs, failed/fallback pipelines, presents
Next hypothesis: one sentence, with the log line that supports it
```

## 5. Rules

- The exe never runs on the host.
- One run per binary version. Evidence before iteration.
- Commit subjects and "playable" claims are not evidence.
- If the binary is not hash-verified, it does not enter the lab.
- Publish hash + first failure immediately if the goal is priority; otherwise keep it private.

## 6. Known expected failures (from prior work)

| Symptom | Likely cause |
|---|---|
| No crash, no progress, thread parked | `gamecoreclient` / `DisplayMode` MQ wait with no timeout (`gamecoreclient.dll` is **unrouted** at 217ac85, so calls auto-stub and "succeed") |
| `E_NOTIMPL` at startup | `xgameruntime` class not implemented; check `report.json` and `no System32\xgameruntime.dll` |
| Draws silently skipped | UMA 2 GB window exhaustion (per-draw 64 KiB); read `d3d12.uma_used_kb` |
| Wrong pixels, no error | wave64 mask truncation / cross-half op on 32-lane hardware |
| Pipeline creation fails | missing root signature `RTS0`, or flags not masked |
| Compile fails | no `dxcompiler.dll` in the guest, or giant-program OOM |
| No window / black window | session 0 vs interactive desktop; `CreateWindowExW` routing |

## 7. Checklist

> Superseded: the first executable run has been performed; see [FIRST-RUN.md](FIRST-RUN.md) for the measured progression.

- [ ] hash recorded
- [ ] size recorded
- [ ] PE parsed
- [ ] inspect saved
- [ ] VM online, payload pushed
- [ ] one run executed
- [ ] report + log captured to host
- [ ] stopped at first failure
