# Black/blank output at Series S or 720p — cautious triage

**Status:** updated 2026-11-27 UTC. This is a source-review checklist, not a diagnosis of a particular user's frame. No game screenshot, matching run log, hardware report, or runtime repro was supplied. Earlier versions of this document treated several fork-specific reports as universal fixes; those copy-paste recommendations are withdrawn here.

> **The checkout does not contain the renderer.** It contains a launcher for a separate VIctory-family compatibility layer. A black window, dark indirect-lit rooms, black faces/textures, and a display-driver reset are different failure classes. Do not infer one from another or apply a lighting value to fix a presentation failure.

## Bottom line

The available evidence does **not** identify a single root cause for an unspecified black screen. Start by classifying the symptom and collecting a same-scene screenshot plus matching `run-*.log`, `run-*.err.log`, `settings-*.txt`, engine name/commit, Windows build, GPU/VRAM, and RAM. The detailed current review is [`harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md`](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md).

The most useful distinction is:

| What is black? | Plausible layer | First evidence to collect |
|---|---|---|
| Entire game window | Pipeline/device initialization, adapter selection, present/upscale/compose, swapchain/window mode, or device loss | First error in stdout/stderr logs, selected adapter, DRED/Windows Event Viewer, exact fork and commit |
| Only shadowed interiors or surfaces | Missing/incomplete indirect-light or ray-traversal path; ambient fallback behavior | Same-scene image, selected build's lighting source, exact `VICTORY_*` values |
| Individual faces/textures/objects | Texture residency/streaming, descriptors, shader translation, asset-specific path | Close-up plus matching log and settings after streaming settles |
| All displays flash black and recover | Driver reset / TDR / device removal | Event Viewer, DRED, driver version, `0x887A*` context and preceding log lines |

An HRESULT such as `0x887A0005` or `0x887A0006` is not, by itself, proof of VRAM exhaustion, a pagefile problem, or a lighting defect.

## What public source reviews establish — and what they do not

These observations come from public repositories checked on 2026-11-27. They describe those source snapshots and maintainer reports; they are not independently reproduced here and do not establish what a user's binary is doing.

- **CCS03:** the checked `ccs03` source describes a constant ambient fallback when its indirect-light path is unavailable. Its play script sets `VICTORY_AMBIENT=0.9`, while the implementation default is `0.6`. This may lift or flatten shadowed areas; it is not a display-brightness control and cannot restore full bounced light. See the [checked CCS03 source](https://github.com/JozefDeTremmerie/CCS03/tree/a00b2f79bf3f20abc4aec3de1f957c82fc0bd4cf).
- **victory-unified:** its checked ray-tracing note describes a scene-dependent screen-probe estimate when BVH structures are unavailable, and says this ambient path is off while the optional BVH builder runs. Its current play script and README disagree about the ambient value. See the [ray-tracing note](https://github.com/Itsbatt/victory-unified/blob/92dc8785eb4e5244aea85e41652d428ebd1e663a/docs/fork-ray-tracing.md) and [play script](https://github.com/Itsbatt/victory-unified/blob/92dc8785eb4e5244aea85e41652d428ebd1e663a/scripts/play.ps1).
- **Experimental ray-tracing forks:** maintainer reports describe substantial performance, memory, streaming, and device-loss tradeoffs. These are not practical or validated as a universal lighting fix. The harness does not enable the builder by default.
- **Series S / 720p paths:** public forks report differences in upscale, multiple presentation planes, target formats, and composition. A switch such as `VICTORY_OWN_UPSCALER`, `VICTORY_COMPOSE`, `VICTORY_PRESENT_PLANE`, or a console profile is meaningful only if the exact selected source commit implements it. Presence in the parent PowerShell environment is not proof that a binary consumes it.
- **Windows 10 D3D12 files:** CCS03 documents an Agility SDK path. The harness checks those files only for its CCS03 profile on Windows 10. That does not prove missing files are the cause of a given black window, nor does it apply automatically to all forks or Windows versions.

## Safe investigation sequence

1. **Record the symptom before changing anything.** Capture a full-window screenshot and, if only a character or surface is affected, a close-up from the same frame. Note whether the image changes after scene streaming settles.
2. **Preserve the run identity.** Keep the latest `run-*.log`, `run-*.err.log`, and matching `settings-*.txt`. The settings file records engine/profile and a best-effort source revision where available. An archive download or an existing binary may have no reliable build provenance.
3. **Record the machine and exact software.** GPU model and VRAM, driver, system RAM, Windows build, harness path, repository/fork, source commit (if known), and which `--console` profile was used.
4. **Read the earliest relevant failure, not just the last HRESULT.** Look for pipeline creation/compile errors, adapter choice, swapchain/present failures, device removal, and DRED/Event Viewer evidence. A final error can be a consequence rather than the first fault.
5. **Change one thing at a time and only when supported by that build.** Keep the save, camera, scene, display mode, and driver state fixed. Use ambient A/B only when the world renders and the problem is specifically shadowed areas. On CCS03, the harness's ambient menu is CCS03-only; `off` is diagnostic, not guaranteed to improve the image.
6. **Do not apply unrelated system changes from a generic checklist.** A fixed 48–64 GB pagefile, disabling HDR, forcing a particular GPU, or setting a `VICTORY_*` switch is not a universal repair. Check actual commit exhaustion, display state, adapter log, and fork documentation before changing anything.

## Withdrawn claims from the previous runbook

The earlier version ranked a universal “fix order,” predicted black screens from particular switches, called a specific tree “most likely,” recommended fixed pagefile/HDR changes, and forecast FPS for a 6 GB laptop by scaling results from unrelated hardware/scenes. Those conclusions exceeded the evidence and should not be used as instructions. The historical source catalog remains in `PORTWATCH_FIX_REPORT.md` and `portwatch-analysis/`; its numbers are author-reported unless explicitly stated otherwise.

## References

- [`harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md`](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md) — current code review, fork-specific lighting findings, A/B procedure, and requested evidence.
- [`harness/README.md`](harness/README.md) — harness behavior and current caveats.
- [`PORTWATCH_FIX_REPORT.md`](PORTWATCH_FIX_REPORT.md) — dated research survey; not a patch to the renderer.
