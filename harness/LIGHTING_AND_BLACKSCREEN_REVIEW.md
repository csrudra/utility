# Black-screen and lighting review

**Reviewed:** 2026-11-27 UTC  
**Scope:** this checkout's launcher/diagnostics plus the current public upstream source. There is no renderer source, game executable, screenshot, or run log in this checkout, so this review can explain the known architecture and likely causes, but cannot identify which failure your particular frame has.

## Short answer

The repo is a **launcher and research bundle**, not the game's renderer. The default CCS03 profile is designed to get a frame on a constrained laptop; it is not a high-fidelity lighting configuration. It sets `VICTORY_BVH_MISS=1` to make ray tests miss rather than walk stale structures, then uses a constant tinted ambient fallback instead of the title's full indirect-light path. CCS03's current `ambient.rs` documents that approximation; its play script chooses `VICTORY_AMBIENT=0.9` while the implementation default is `0.6`. This is the strongest code-level explanation for shadowed rooms looking dark/flat or unlike the intended scene. Raising ambient can lift shadows, but cannot restore ray-traced bounce, local light transport, exposure adaptation, missing textures, or failed draw calls. It does **not** explain an entirely black window by itself.

**Do not treat “the game looks black” as one bug:**

1. **Entire game window is black:** investigate pipeline creation, adapter selection, present/upscale/compose path, HDR/swapchain state, or device loss. `VICTORY_AMBIENT` is the wrong control.
2. **Only indirect-lit rooms/shadows are black:** the selected build may not have usable ray-traced indirect light; the ambient stand-in is a compromise.
3. **Faces, objects, or individual surfaces are black/blotchy:** investigate texture streaming/residency, descriptor lifetime, shader translation, or a scene-specific render path. Ambient light can mask this, not repair it.
4. **The whole display flashes black / recovers:** that is a driver reset/device-removal symptom, not “dark lighting.” Capture DRED and Windows Event Viewer evidence.

## Live upstream check

I checked the public branch heads via GitHub on 2026-11-27. These are source claims and one-machine results, not independent reproductions:

- **CCS03** `ccs03`, commit [`a00b2f79`](https://github.com/JozefDeTremmerie/CCS03/commit/a00b2f79bf3f20abc4aec3de1f957c82fc0bd4cf): [`ambient.rs`](https://github.com/JozefDeTremmerie/CCS03/blob/a00b2f79bf3f20abc4aec3de1f957c82fc0bd4cf/crates/victory-gpu/src/ambient.rs) describes the fallback as a constant indirect-diffuse level; [`ccs03/play.ps1`](https://github.com/JozefDeTremmerie/CCS03/blob/a00b2f79bf3f20abc4aec3de1f957c82fc0bd4cf/ccs03/play.ps1) sets `VICTORY_AMBIENT=0.9`. The fallback is not an exposure/brightness slider.
- **victory-unified** `main`, commit [`92dc8785`](https://github.com/Itsbatt/victory-unified/commit/92dc8785eb4e5244aea85e41652d428ebd1e663a): the checked [`docs/fork-ray-tracing.md`](https://github.com/Itsbatt/victory-unified/blob/92dc8785eb4e5244aea85e41652d428ebd1e663a/docs/fork-ray-tracing.md) describes a screen-probe-based directional estimate with scene tint and crease shading when ray structures are unavailable; it is a stand-in, not the title's full ray-traced result. Its README documents `VICTORY_AMBIENT=1.25`, while the current [`scripts/play.ps1`](https://github.com/Itsbatt/victory-unified/blob/92dc8785eb4e5244aea85e41652d428ebd1e663a/scripts/play.ps1) sets `0.8`. That note says this ambient path is off while the optional BVH builder runs; the engine's documented builder-on result is about 40 ms additional GPU time per frame in the cited scene. Don't assume the README's scalar is the value used by its launcher or that these settings apply to another fork.
- **fxceless/victory-fork** `main`, commit [`9a9091d1`](https://github.com/fxceless/victory-fork/commit/9a9091d180f044726463d3db819808086daeebae): its [2026-11-27 README status](https://github.com/fxceless/victory-fork/blob/9a9091d180f044726463d3db819808086daeebae/README.md) reports that the builder can now produce the title's traced shadows/light after scene streaming. The same report says that mode falls to **0.2–3 world fps**, consumes about **23–27 GB system memory** and **9.2–9.6 GB VRAM** on its one RTX 4070 / 32 GB test PC; black faces can still appear during initial streaming, and later device-loss cases remain unresolved. With the builder off, the README says shadowed areas are black. This is not a sensible fix for a 6 GB / 16 GB laptop.

The most important distinction: the experimental ray-tracing route exists in a current public fork, but it is a severe performance/memory tradeoff and is not the default CCS03 runtime path. There is no safe one-switch fix that makes a 6 GB / 16 GB setup look like the original console rendering.

## Code review findings

### Fixed in this branch

1. **`fxce` profile was unreachable.** In `Set-GameEnv`, the `fxce` engine check was nested inside the `foxhound` block, after its unconditional `return`. The fxce-specific variables could never be applied. The branch is now correctly separated; ambient overrides are stored/read per engine, and the interactive ambient menu is restricted to CCS03 because the forks' semantics differ.
2. **The unified profile inherited a ray-tracing kill switch.** It previously fell through the CCS03 environment bundle, which set `VICTORY_BVH_MISS=1` (the title's ray tests are forced to miss to avoid walking stale structures). That is specific to the CCS03 laptop profile, but contradicts unified's optional builder-based ray-tracing path. Unified now gets its own upstream-matched profile and does not set `BVH_MISS`.
3. **Profile variables leaked between play sessions.** The launcher remains open while a user can move from DEBUG to SMOOTH or slow-motion to real-time. Previously, variables absent from the next profile (for example `VICTORY_NO_WATCHDOG` or `VICTORY_GAME_STEP_MS`) stayed in the parent PowerShell environment and contaminated the next child. Launch now rebuilds the environment from the selected profile, preserving path/adapter selectors; deliberate extra switches must be placed in `config.json` under `extraEnv`.
4. **Ambient control was oversold and started too bright.** The old menu called `1.2` “recommended,” said it brightened everything not reached by lamps/sun, and asserted ray tracing could not run anywhere. The CCS03 upstream launcher uses `0.9`; menu copy now describes this as a fallback approximation, labels `1.2`/`1.5` experiments, and warns that `off` leaves the title's possibly invalid output in place. The default CCS03 fallback is now `0.9`.
5. **The “black-screen fixer” was only a read-only checklist.** It did not make changes, and several messages stated uncertain causes as facts (for example mapping all `0x887A0005/6` to memory pressure). The launcher and script now call this a diagnosis, both SDK files are checked, and the error text asks for evidence rather than prescribing pagefile/VRAM changes from an HRESULT alone.
6. **The setup wizard discarded settings and could mismatch a newly selected binary.** Re-running it used to recreate `config.json` with only path fields. It now preserves non-path settings, detects the known install paths, and asks for a profile when the executable changes or is not recognized. Custom `extraEnv` values are retained with a warning because they may be wrong for the new fork.
7. **The resource tracker invented per-switch numbers.** Its component table was hard-coded but presented as measured VRAM/GPU usage and could automatically disable options on that basis. It now reports only the system totals actually in the CSV and never changes settings.
8. **README drift.** The root README described an Android utilities project while the checkout contains a Windows game harness and PortWatch research. It now describes the actual contents. This does not add renderer code.
9. **Updater could apply `main` to the wrong Git branch.** The Git path previously ran `git pull --ff-only origin main` without checking the current branch or dirty working tree. It now refuses non-`main`, dirty, or Git-unavailable checkouts rather than mixing branches; the ZIP path still overwrites unprotected program-file edits.
10. **Black-screen/performance docs overstated evidence.** The old 720p runbook treated fork-specific reports as universal fixes, and the 20-FPS note extrapolated incompatible benchmarks. The runbook now asks for diagnostic evidence; the performance note retracts its forecasts and does not recommend unofficial driver proxies.
11. **Texture-remap A/B choice is now per launch.** For CCS03 and fxceless, PLAY offers the profile baseline or the opposite `VICTORY_TEXTURE_NO_WAIT` value, with CCS03 baseline `1` and fxceless baseline `0`. The exact environment is captured with the run settings. This is an experiment only: support in source does not prove the selected executable honors the setting, and the renderer outcome must be compared in the same scene.

### Still open / important risks

- **No image/log means no exact root-cause diagnosis.** Nothing in this repo captures the user's displayed frame. A screenshot plus `run-*.log`, `run-*.err.log`, and matching `settings-*.txt` is needed to distinguish presentation failure from expected missing GI or a texture bug.
- **`TRY-FXCELESS.cmd` now has a guarded switcher, but remains unvalidated.** `try-fxce.ps1` warns about the upstream's single-machine resource report, requires confirmation by default, reuses existing source/builds only with explicit provenance caveats, and saves a per-fork config restore point. It has not been run on Windows here; it does not apply renderer patches or promise to fix the reported image. The live upstream still reports temporary black faces and a large memory footprint.
- **Third-party settings are mixed across forks.** Environment variables are not a stable shared API. A value from one fork can be ignored or behave differently in another; a successful `Set-Item` is not evidence the engine consumed it. The launcher now records effective values, but source-level support still needs verification.
- **Installation is not reproducible or supply-chain verified.** `Full-Auto-Setup` downloads a mutable GitHub branch and several installers/packages without pinning source commits or verifying checksums/signatures. It reuses `victory.exe` by file existence alone, without checking source revision, build options, or artifact provenance. The run settings record a best-effort source revision when Git metadata is available; the default ZIP source has no `.git`, so the built binary's exact source is still unknown. “Built from source” is not equivalent to a reproducible or audited build. Pin revisions, record build provenance, and verify vendor signatures/hashes before promoting this as a one-click installer.
- **Telemetry is NVIDIA-specific.** `nvidia-smi` supplies GPU/VRAM; on AMD/Intel, zeros can be misread as real values. The `phys_0` GPU-engine estimate is not necessarily the iGPU or process-only utilization. A future fix should detect vendor/adapter IDs, label unknown values as unavailable, and sample the game process specifically.
- **Preflight remains advisory.** OS version alone does not prove the GPU supports the needed D3D features. The 48 GB pagefile value is shown only as a reference from some laptop tests, not a universal requirement; judge actual committed-memory headroom and OOM evidence. The scripts do not use a low pagefile number to diagnose a black screen.
- **Windows runtime test/CI is still missing.** This sandbox has no PowerShell runtime, so the PowerShell edits were statically reviewed only; they were not executed on Windows 10/11 or a D3D12 GPU. Add a parser/linter check plus mocked tests for profile environment construction, config preservation, and diagnostic output on Windows CI.

## Safe, useful A/B test

If the world renders and only shadowed areas are too dark:

1. Use one save, one camera position, the same display/driver settings, and let streaming settle before each capture.
2. Start with `[4] TUNE AMBIENT LIGHT` → `0.9` (the CCS03 script's documented setting).
3. Repeat once at `1.2`; compare **only the same screenshot/scene**. If shadows lift but faces/textures remain black or the whole picture stays black, this is not an ambient-level problem.
4. Avoid `off` except as an A/B diagnostic; the raw title output may be stale/invalid. Avoid forcing the ray-tracing builder on a 6 GB / 16 GB system; current public results are far outside that memory budget and can run below 3 fps.
5. Don't apply several performance switches together. Change one thing, record the setting file, and preserve the previous known-good config.

For a **texture-remap A/B** on CCS03 or fxceless, PLAY offers `VICTORY_TEXTURE_NO_WAIT` at launch. Keep the save, camera, and scene the same; let streaming settle and capture once with each choice. The setting file records the requested value, not proof that the binary consumed it. `1` requests nonblocking refresh; `0` requests the wait path and may trade stalls for a different remap result. Compare the images and logs, not just the environment variable.

If the **entire window** is black, skip the ambient test. Check the error log for pipeline/adapter/present/swapchain/device-loss signals and confirm the console profile and fork/commit. Verify the two Agility SDK DLLs only for the CCS03 Windows 10 path; otherwise follow the selected fork's exact instructions. Compare the run log with that source snapshot.

## What to send for a precise diagnosis

- A full-window screenshot and (if only a character/area is affected) a close-up from the same moment.
- Latest `run-*.log`, `run-*.err.log`, and matching `settings-*.txt` from `harness/data/logs/`.
- Engine/repository + commit, Windows version/build, GPU model/VRAM, driver, system RAM, and whether the **game window** or every monitor is black.
- Whether it is the whole frame, only shadows/interiors, only characters/textures, or a brief display-driver reset.

Review the logs for user names/paths before sharing them; the config and error logs may include local file paths.
