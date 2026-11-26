# Lucy × Nazir — GTA 6 Research Lab

**Independent Xbox Scarlett → Windows compatibility research and reproducible GPU diagnostics.**

[Research progress](docs/PROGRESS.md) · [Source release plan](docs/SOURCE-RELEASE-V0.1.md) · [Reproducibility](docs/REPRODUCIBILITY.md) · [First-frame research](docs/LEONIDA-CB-DIAGNOSTIC-SPEC.md) · [Roadmap](docs/ROADMAP.md) · [Upstream projects](docs/UPSTREAM.md) · [Contributing](CONTRIBUTING.md) · [Publication policy](SECURITY.md)

> [!IMPORTANT]
> This is an independent, unofficial research project. We are **not affiliated with Rockstar Games, Take-Two, Microsoft, or Leonida**.
> **No GTA VI gameplay, recognizable game frame, or execution of an authentic Scarlett title is claimed here.** The locally reported results below come from **self-authored synthetic programs**.
> We do not provide game files, proprietary assets, leaked executables, keys, decryption tools, or instructions to obtain or bypass protected content.

## Why this exists

We are investigating what must be translated between Xbox Scarlett and Windows: PE startup and GDK, XMem virtual/physical memory, D3D12.X interfaces, descriptors, shader-visible resources, CPU/GPU synchronization, and frame presentation. Our workflow is **observe → isolate one incompatibility → make a synthetic test → verify → document limitations**.

We follow public work by [Leonida](https://github.com/ProjectLeonida/Leonida), [AnyXboxX](https://github.com/LooperSalty/AnyXboxX), [Xbox2Windows](https://github.com/R0Y00/Xbox2Windows), and [TomBox](https://github.com/omonkeyz/xbox-emulator). Their reports are used as research references, **not proof** that our own code implements a real console ABI.

## Current status — 24 November 2026

| Area | Locally reported result | Important limit |
| --- | --- | --- |
| RPF9 / PSIN read-only investigation | 1,012 PSIN entries checked in `script.rpf`; 2,281 PSIN entries reconstructed in `data.rpf` | Does not authenticate the provenance of the files |
| D3D12 / Vulkan texture tests | RGBA8, multiple mip levels and BC1 copies matched independent CPU references on an RTX 3060 | No game renderer tested |
| XMem CPU prototype | 64 KiB shared-page aliases, scatter mappings and placeholder splits tested | Scarlett flags/semantics partly unknown |
| Scarlett VA Bridge | Synthetic device-slot-133 → slot-70 → SRV → compute readback; direct and shadow routes tested | Modelled interface; not a verified retail ABI |
| DescriptorBridge v0.1.0 | Multiple queues, multiple CPU threads, resource lifetime, generations and fence tracking | Synthetic guest handle model |
| Integrated Runtime M1–M3 | CPU memory → D3D12 readback, typed/raw/structured SRVs, synthetic PE/DLL package | M3 delegates PE mapping, relocations and TLS to the Windows loader |
| Boot diagnostics M4.1–M4.5 | Synthetic guest reached GDK, TitleID, `XMemVirtualAlloc`, and `XMemAllocatePhysicalPages` | Next synthetic stop: missing `XMemMapPhysicalPages` export; **not** a retail title boot |
| CB pipeline investigation | 42 synthetic frames distinguished missing CB publication from wrong CBV binding | Does not establish why a retail frame is black |

**Evidence level:** These figures are taken from local Codex-produced reports relayed by the project owner. We have not yet uploaded and independently audited the complete build trees and logs in this public repository. They are presented as *reported local measurements*, **not third-party-verified reproducibility claims**.

## A concrete contribution to the community

Our first published research artifact is [a proposed trace for the 16 zero bytes observed in a Leonida offscreen draw](docs/LEONIDA-CB-DIAGNOSTIC-SPEC.md), with a [synthetic-control summary](docs/CB-PIPELINE-SUMMARY.md).

The aim is to identify, within **one run and one draw**, the last CPU writer, actual descriptor and resource generation, GPU-visible bytes, shader operand, offscreen target, and final presented buffer. A black multiplier may be intentional; the trace must not assume a defect.

## Repository structure

- `docs/PROGRESS.md` — research milestones, provenance and limitations.
- `docs/LEONIDA-CB-DIAGNOSTIC-SPEC.md` — complete community diagnostic proposal.
- `docs/CB-PIPELINE-SUMMARY.md` — measured synthetic outcomes reported by Codex.
- `docs/UPSTREAM.md` — public project references.
- `docs/ROADMAP.md` — next reproducible milestones.
- `SECURITY.md` — rules for safe publication and contributions.

## Active integration milestone

[**M5: Synthetic PE → GDK → XMem → VABridge → DescriptorBridge → D3D12 → first deterministic frame**](https://github.com/Naz1r/lucy-nazir-gta6-research/issues/2) is tracked separately from the [public source audit](https://github.com/Naz1r/lucy-nazir-gta6-research/issues/1). **M5 hardware acceptance is now reported locally, not independently reproduced.** Two RTX 3060 runs reportedly passed 768/768 compute words, 192/192 colored offscreen and backbuffer pixels, 4/4 Present calls, 8 negative checks, and 0 D3D12 Debug Layer/GPU validation errors. The output was a **self-authored synthetic frame captured before Present in a hidden window**. The actual source, logs and 67-file manifest are not published or audited here; a clean second-system reproduction remains outstanding. [Reported M5 measurements](https://github.com/Naz1r/lucy-nazir-gta6-research/issues/2#issuecomment-7117173968). This does not demonstrate retail GTA VI startup.

## Reproducibility and source availability

The local runtime prototypes and measured outputs remain on the researcher's Windows machine. We will publish **reviewed, self-authored, non-proprietary code and sanitized test evidence** separately once verified for provenance, secrets, licence compatibility and data exposure. Do not infer that a referenced local report or working binary is available in this repository.

## Collaboration

Feedback on the diagnostic methodology, independent synthetic reproductions, and corrections to documented assumptions are welcome. Please link exact upstream revisions and report hardware/driver/API versions, source-build commands, acceptance criteria, and negative controls. **Do not post any game binaries, asset bytes, memory dumps or proprietary logs.**

## Licence status

No repository-wide licence is selected yet. Do not assume permission to reuse this repository's original text or code beyond what applicable law allows. Third-party projects retain their own licences.

*Research coordination: Lucy × Nazir. Measurements credited to the local Codex agents that produced their reports.*
