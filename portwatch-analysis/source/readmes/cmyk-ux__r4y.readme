# R4Y — Technical Research Record

**Snapshot date:** 2026-11-25 (America/Sao_Paulo)  
**Repository:** https://github.com/cmyk-ux/r4y  
**Purpose:** a dated, evidence-oriented handoff for developers or AI agents investigating a related Xbox Series / Scarlett D3D12 runtime. This is a research record, not a claim of playable compatibility.

> **Read the branch distinction first.** The default branch and the active research branch do not contain the same state. The main snapshot inspected for this report was **b460f7700ad95e3ba1db245233740cd642c4ceb0**. The active Wave64 research is in **PR #16**, branch **feature/wave64-host-target**, inspected at **0c2e3ec638be0c113011222b3acc6c6454384ca9**. PR #16 is open and its changes are not merged into main.

## Start here — the most substantial unmerged work

The most important experimental implementation is **[PR #16 — Add host-aware Wave64 split and console-flow translation](https://github.com/cmyk-ux/r4y/pull/16)**. It is intentionally **not merged into `main`**; open the PR to inspect the full implementation, its commit history, review context, and validation notes.

In particular, PR #16 contains the partial Wave64-to-Wave32 translation path, including the bounded cross-half console-flow fallback. Its synthetic D3D12 dispatch tests were run successfully on a physical RTX 3070, and two previously refused title compute pipelines were later observed being created and bound. This is partial support, not general Wave64 compatibility or a claim that the title is playable. The PR also contains related diagnostics and other experimental GPU/runtime fixes.

**For a quick handoff:** read this research record for the findings and limitations, then inspect [PR #16](https://github.com/cmyk-ux/r4y/pull/16) for the code. No merge is required to review or reuse that branch.


## Executive status

R4Y is a Rust-based experimental Windows compatibility runtime for Xbox Series X|S / Scarlett software. It combines native x64 title execution, selected KernelX and XGameRuntime HLE, a D3D12.X-to-host-D3D12 backend, and GFX10/RDNA2 shader translation to DXIL.

The investigation produced several concrete engineering results, including a Wave64-to-Wave32 shader path exercised on a physical RTX 3070, real title pipelines that were previously rejected and later successfully created, D3D12 descriptor/command-list fixes, and a safer indirect-argument clamp design.

It did **not** produce a playable or generally compatible runtime. The investigated title still encounters GPU-progress failure / D3D12 device-hung behavior. The exact dispatch or synchronization condition responsible has not been isolated, descriptor virtualization is incomplete, and some shader patterns remain intentionally unsupported.

**Project recommendation as of this snapshot:** preserve the repository and its findings, finish validating the active PR, and pause broad expansion into a general-purpose competitor. The work has research value even though the end-to-end objective remains unmet.

## Evidence labels

Use these labels when reusing the findings:

- **Hardware-validated:** the named test actually dispatched on the physical RTX 3070.
- **CI-validated:** the exact cited commit completed the named hosted checks. A GPU test that says “skipped” is not a hardware pass.
- **Observed:** present in a user-provided runtime log or crash report, without a proven causal explanation.
- **Implemented, awaiting validation:** code exists on the feature branch, but the exact latest branch head has not passed the required checks or hardware run.
- **Hypothesis / lead:** a plausible explanation or a reference-project clue, not an established root cause.

Dates and commit references are included because later code, cache state, title builds, drivers, or host adapters can change the result.

## Findings

### 1. Wave64 shaders can be translated for a Wave32 D3D12 host — partial, hardware-validated

**Host:** NVIDIA GeForce RTX 3070, reporting a 32-lane wave range through D3D12 OPTIONS1.  
**Primary implementation:** PR [#16](https://github.com/cmyk-ux/r4y/pull/16), branch feature/wave64-host-target.  
**Hardware test:** wave64_split_matches_console_on_d3d12_hardware, run on 2026-11-25 at branch commit 071dce461afe7be82e87a5b3c18277193b4391b4.

The implementation queries the host's supported wave-lane range, passes it into shader translation, refuses fixed wave sizes that the adapter cannot execute, and includes the host wave range in the shader-cache fingerprint. This avoids reusing a shader translation produced for a different wave capability.

Two translation strategies were implemented:

1. **In-half split:** operations whose results can be derived independently from each lane's original console index can be split across the two host Wave32 halves. Tested operations include DPP, ds_swizzle, and ordinary v_mbcnt_lo/hi cases. Console lane numbering and DPP row-mask behavior must be preserved; simply substituting the host lane ID is incorrect.
2. **Bounded console-flow fallback:** for eligible programs containing cross-half operations, the translator can retry with console-wave control flow for exactly one console Wave64 group per thread group (at most 64 threads). It preserves per-instruction EXEC guards, makes both host halves follow the same console-wave branch decisions, and exchanges selected cross-half values/masks through two group-shared dwords with barriers.

The RTX 3070 test completed with **1 passed, 0 failed** and explicitly reported that the split path was active. The successful test covered lane order for 32/64/128-thread cases, DPP row masks, VCC ballot/count, MBCNT, cross-half v_readlane and v_writelane, v_readfirstlane, SAVEEXEC/SCC behavior, a branch with one half inactive, and a divergent loop that reads a lane in the other half. Earlier failed assertions were traced to incorrect VOP1 source encodings in the test fixtures; those fixture words were corrected. Those failures were not evidence of a production lowering bug.

**Real-title evidence:** on a correctly rebuilt Diagnostics runtime, the RTX 3070 reported lanes_min=32 lanes_max=32. Two compute shaders previously rejected for requiring Wave64 — 88994c3496045f51 and 13dfdd3b1136e407 — were freshly translated, had host pipelines created, and later reached first bind. The corresponding earlier run had logged 136 host-pipeline refusals and 168 “Shader wants wave lane count of 64” messages. This is meaningful progress for those two pipelines, not proof that all title Wave64 shaders work.

**Boundaries:** the fallback is not general Wave64 emulation. It does not implement general LDS semantics, ds_bpermute and other arbitrary permutes, whole-wave reductions, groups spanning multiple console waves, or every SCC/VCC/EXEC branch form. Some shaders still fail explicitly, including examples 2cc4c197ee29e291 and 7168dd781ca7efb9. Unsupported programs should remain refused rather than being emitted with incorrect semantics.

GitHub-hosted CI runners used during this work often had neither a 32- nor 64-lane D3D12 adapter. Their test process could pass while printing that the hardware body was skipped. The physical RTX 3070 run above is the relevant GPU evidence.

### 2. The title's later failure is a GPU-progress / device-hung problem — observed, not yet attributed

A later RTX 3070 Diagnostics run used per-command-list GPU timing and DRED breadcrumbs. The log reported:

- Host wave target: 32 lanes; successfully translated compute DXIL generally declared WaveSize 32.
- One individually timed dispatch: **3,089.8 ms**, dispatch 128x64x1, compute hash 42683eebec081520.
- A later command list reported approximately **8,155 ms** for 26 commands; the associated submission was approximately **8.199 seconds across 33 lists**.
- D3D12 reported DXGI_ERROR_DEVICE_HUNG (0x887A0006), describing a TDR after commands took an unreasonable time to execute.
- DRED breadcrumbs stopped around a dispatch, but the old output did not conclusively identify whether the relevant list belonged to a main command list or an internal prelude.

The 3.09-second dispatch is a strong lead, but it has **not** been proven to be the dispatch that caused the later device removal. Most per-command values in the later slow list were displayed as 0.0 ms; this is not evidence that those commands consumed no GPU time.

A separate title-side report showed an access violation (0xc0000005) writing to address zero at title-image offset +0x23cf683. Research in [XCL issue #505](https://github.com/xcl-dev/xcl/issues/505) identifies the same offset in the target title as an intentional GPU-progress watchdog path: when the title does not observe expected GPU progress, it deliberately writes to null. This supports interpreting the title exception as a watchdog symptom, not automatically as a random R4Y null-pointer defect. It still does not identify the GPU command that stopped progress.

Memory/pool counters were high in the same general period, so memory pressure remains a secondary lead. The evidence does not establish OOM as the cause. Keep the title watchdog, D3D12 TDR, and any actual allocator failure as distinct failure classes.

PR #16 adds instrumentation to associate DRED breadcrumbs with both the main command list and R4Y's internal prelude lists, and adds depth-twin converter dispatch markers. These changes are diagnostic instrumentation; a post-change RTX 3070 run is still needed.

### 3. NVIDIA's logical descriptor heap exceeds the physical host limit — confirmed limitation, not solved

In the captured RTX 3070 run, the title requested **1,245,184** shader-visible view descriptors while the host D3D12 adapter accepted **1,000,000**. One observed fallback layout partitioned the host heap into:

| Region | Slots |
|---|---:|
| Mirrored title prefix | 721,469 |
| Dynamic/transient descriptors | 262,144 |
| Persistent copy pairs | 16,384 |
| Null/sentinel slots | 3 |
| **Host total** | **1,000,000** |

The current capped-heap fallback prevents out-of-bounds host writes and avoids some transient/persistent aliasing. It is **not complete descriptor virtualization**. Title descriptors above the mirrored prefix are not preserved as ordinary title descriptors; some shader-side indices are clamped to safe null entries. Logs showed accesses/touches to high logical indices, often with for_draw=false, which does not prove that every such descriptor was consumed by a draw.

A correct solution must consistently map logical title indices to physical host slots, preserve high descriptors, keep dynamic root-view and fresh-table allocations valid, handle raw descriptor copies into title heaps, and make generated shader indexing use the same mapping. Simply increasing the mirrored count would exceed the physical host limit or collide with internal allocations. Suppressing the warning is not a fix.

Tracking issue: [R4Y #4 — Virtualize title descriptor indices](https://github.com/cmyk-ux/r4y/issues/4), still open at this snapshot.

A separate GPU-Based Validation report found pixel shaders expecting a Texture2D SRV while host view-heap slot zero contained a Texture1D SRV. Source tracing showed that one fallback path preserves the source descriptor's declared dimension when resource creation fails. That confirms part of the reproduction path, but not the original logical cause: the title descriptor, heap index mapping, stale slot, or shader expectation may be wrong. Do not “fix” this by changing every null descriptor to Texture2D.

### 4. D3D12 state and memory edge cases were fixed in focused changes

The following pull requests were merged into main before this snapshot:

- [PR #5](https://github.com/cmyk-ux/r4y/pull/5): rate-limits repetitive high-water descriptor warnings. This reduces log noise; it does not solve high-index descriptor mapping.
- [PR #6](https://github.com/cmyk-ux/r4y/pull/6): fixes dynamic descriptor allocation when a free contiguous range crosses the search cursor. Includes exhaustive small-heap comparison tests.
- [PR #8](https://github.com/cmyk-ux/r4y/pull/8): adds a safety-oriented fallback for NVIDIA-capped view heaps. It is not full virtualization.
- [PR #9](https://github.com/cmyk-ux/r4y/pull/9): makes zero-length title-memory writes/remaps true no-ops, avoiding accidental page dirtiness or alias-link removal from unaligned empty ranges.
- [PR #12](https://github.com/cmyk-ux/r4y/pull/12): adds opt-in handling for group barriers identified as divergent or potentially cut short. It retains memory/UAV fences and changes only the group wait. It is an experiment, not proof that barriers caused the observed TDR; the default behavior remains unchanged.
- [PR #13](https://github.com/cmyk-ux/r4y/pull/13) and [PR #14](https://github.com/cmyk-ux/r4y/pull/14): restore/rebind descriptor heaps and the appropriate root signature after internal depth-twin work and root-signature switches.
- [PR #15](https://github.com/cmyk-ux/r4y/pull/15): adds bounded diagnostics for concrete descriptor-heap pointers and root-signature bindings.

These are targeted fixes. A previous sampler-heap/root-signature warning should be checked against a new runtime log rather than assumed fixed solely from merged changes.

### 5. Additional feature-branch work: indirect arguments and structured-buffer addressing

The active PR #16 branch contains a non-destructive indirect-argument clamp redesign. The earlier helper modified the title's argument shadow in place and did not use the optional count buffer when deciding which records to process. The branch implementation instead reads source arguments and count as SRVs, processes at most min(max, count), writes active records into reusable device-local scratch, and has ExecuteIndirect consume that scratch. It also uses bounded/saturating work-budget accounting and explicitly tracks resource states/lifetimes for command-list reuse.

Tests cover source immutability, count-limited output, untouched tail sentinels, scratch/budget state across command-list replay, and GPU/WARP paths where available. Do not start clamp-hoisting or aggressive batching until this scratch/count behavior is stable and measured on the real target workload.

A separate structured-buffer issue was reproduced by WARP: dynamic resource-heap accesses used a runtime view stride but emitted the wrong DXIL coordinate form, causing repeated values rather than the expected sequential elements. Commit 4117c0c3695560f94e57a455d907d38e1bee78ca switched that dynamic case to byte-addressed RawBuffer coordinates while retaining the statically known StructuredBuffer path. CI run [#186](https://github.com/cmyk-ux/r4y/actions/runs/45616192308) passed on that exact commit: Clippy (normal and all-features), release build, workspace tests (**214 passed, 0 failed, 2 ignored**) and the relevant WARP regressions. This validates that code revision, not later commits automatically.

The feature branch also ports two upstream robustness ideas:
- Query resource-allocation information from the live host texture description rather than the guest/title description, following [VIctory PR #2286](https://github.com/Marvisak/VIctory/pull/2286).
- Give pipeline compiler worker threads a larger stack (64 MiB), following the NVIDIA driver stack-overflow investigation in [VIctory issue #966](https://github.com/Marvisak/VIctory/issues/966).

These branch changes need exact-head CI and real-title validation before being treated as finished fixes.

## External repository research

The project maintains a dated reference audit in [REFERENCE_REPOS.md](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/REFERENCE_REPOS.md). The requested review priority is:

1. [Zettrox/ztrx](https://github.com/Zettrox/ztrx)
2. [Marvisak/VIctory](https://github.com/Marvisak/VIctory)
3. [fxceless/victory-fork](https://github.com/fxceless/victory-fork)
4. [xcl-dev/xcl](https://github.com/xcl-dev/xcl)

The 2026-11-25 audit sampled recent commits and recently updated issues/PRs, then followed relevant reports and patches. It was a focused audit, not an exhaustive review of every historical issue.

Selected takeaways:

- **ztrx:** pipeline-wait controls and Wave64/group-barrier changes are useful comparison points, but reported frame-time and memory results are workload-specific. One lane-mask optimization was later reverted; do not port an intermediate revision without understanding its regression.
- **VIctory:** the live-host-texture allocation-info fix and larger pipeline-worker stack address concrete D3D12/NVIDIA failure classes. R4Y's feature branch ports the underlying ideas, not the entire fork.
- **victory-fork:** descriptor-state invalidation, view lookup, memory tracking, copy-back, and texture-streaming changes are relevant leads. A broad multi-subsystem PR should not be copied as one patch.
- **XCL:** its reports around the exact title watchdog offset and Wave64/TDR behavior are the closest external diagnostic comparison. Its reports suggest that more than one split-Wave64 compute shader may matter; disabling a single shader can stop one observed hang without resolving all hangs. Its translator and runtime differ from R4Y's, so hashes and fixes are not directly interchangeable.

A supplemental audit of [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) is recorded in [VICTORY_AMD_FORK_AUDIT.md](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/VICTORY_AMD_FORK_AUDIT.md). The fork's README reports world rendering on one RX 9070 XT but not playability; its FPS, workarounds, and AMD-specific shader behavior are self-reported and were not independently reproduced on R4Y's RTX 3070. The most transferable research candidates are count-aware scratch output for indirect arguments and narrowly tested pixel helper-lane semantics. Do not transplant its visual workarounds or merge the fork wholesale.

## Branch and validation state at 2026-11-25

| Ref | State | What it means |
|---|---|---|
| main at b460f770... | Current default-branch snapshot | Contains the merged PRs listed above and the general runtime. |
| PR [#16](https://github.com/cmyk-ux/r4y/pull/16), head 0c2e3ec... | Open | Contains the Wave64 work, later diagnostics, indirect-clamp and other research changes. Not merged. |
| CI run [#45631950469](https://github.com/cmyk-ux/r4y/actions/runs/45631950469) | Failed on the latest inspected PR head | The failing job stopped at “Clippy, diagnostics build”. Do not describe the current PR head as green. Inspect the exact job log before attributing the failure. |
| CI run [#186](https://github.com/cmyk-ux/r4y/actions/runs/45616192308) | Passed on 4117c0c... | Validates that exact earlier branch revision and its WARP/structured-stride changes, not all later commits. |
| RTX 3070 Wave64 dispatch test | Passed on 071dce4... | Physical GPU evidence for the listed synthetic operations, not for the latest branch head or the whole game. |

The active branch's history contains many rapid research iterations. Always fetch the current PR head and compare it with the last tested SHA before using an old green CI result. The session handoff records several earlier CI failures and their repairs; its final section is more current than older status snapshots elsewhere in the file.

## Suggested starting procedure for another investigator or AI

1. Record the exact repository URL, branch, HEAD SHA, OS, adapter/driver, title build, runtime profile, cache state, and timestamp. Do not combine logs from different builds or runs.
2. Read the [current branch session handoff](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/SESSION_HANDOFF.md), then the [reference watchlist](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/REFERENCE_REPOS.md) and [AMD fork audit](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/VICTORY_AMD_FORK_AUDIT.md).
3. Verify PR #16's current head and CI before building or running it. A successful test process that explicitly skips the hardware body is not a GPU validation.
4. Keep the following failure categories separate: unsupported Wave64 translation, pipeline creation failure, long GPU dispatch, D3D12 device removal/TDR, descriptor type/index mismatch, title watchdog exception, and memory/allocator failure.
5. Prefer narrow reproductions and R4Y-native regression tests. Do not cherry-pick a large upstream branch or copy a fix because the symptom looks similar.
6. When inspecting a title crash, treat T: as a virtual title filesystem mount, not necessarily a host drive. With the default data root, title temp data is under %LOCALAPPDATA%\R4Y\data\7952987A\temp and R4Y's own exception log is a sibling crashes.log; honor any R4Y_DATA_DIR or configured data path override.
7. For the next focused GPU-progress run, use a Diagnostics build and collect only the relevant DRED breadcrumb, list-owner/prelude, converter-marker, slow-list, slow-command, and exception/unwind blocks. R4Y_GPU_TIMING=1 isolates command lists; R4Y_D3D12_DRED=1 enables the diagnostic command markers/timestamps. GPU-Based Validation is controlled separately and should not be enabled during a representative timing run.

For a Diagnostics profile, the installer may launch target\diag\r4y.exe based on %LOCALAPPDATA%\R4Y\install-state.json. Rebuild the profile actually selected by that file; a release build alone does not refresh a Diagnostics executable.

Focused commands (run on Windows with the pinned Rust toolchain and D3D12 environment):

    cargo test -p r4y-shader --locked
    cargo test -p r4y-gpu --locked
    cargo test --workspace --locked
    cargo clippy --workspace --all-targets --locked -- -D warnings
    cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
    cargo build --profile diag --locked -p r4y --features diagnostics

For the RTX 3070 lane-by-lane dispatch test:

    cargo test -p r4y-shader --locked wave64_split_matches_console_on_d3d12_hardware -- --show-output

A hosted runner without suitable wave support may skip the GPU body. Confirm the explicit test output.

## Current recommendation

R4Y has uncovered and implemented several non-trivial pieces of D3D12 and RDNA2/Wave64 behavior. That is real engineering output, even though the target title does not yet run reliably and this work has not become a general compatibility product.

The rational stopping point is to preserve the repository, complete the exact-head review/CI for PR #16, retain the RTX 3070 test evidence and diagnostic artifacts, and stop expanding general features until the GPU-progress failure and descriptor mapping limitations have a defensible explanation or a narrow reproducible fix. Keep the project available for future research; do not confuse pausing product expansion with discarding the findings.

## Primary project records

- [Open R4Y repository](https://github.com/cmyk-ux/r4y)
- [Active Wave64 / diagnostics PR #16](https://github.com/cmyk-ux/r4y/pull/16)
- [Open descriptor virtualization issue #4](https://github.com/cmyk-ux/r4y/issues/4)
- [Session handoff — active research branch](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/SESSION_HANDOFF.md)
- [External repository watchlist and findings](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/REFERENCE_REPOS.md)
- [Supplemental AMD fork audit](https://github.com/cmyk-ux/r4y/blob/feature/wave64-host-target/.agent/VICTORY_AMD_FORK_AUDIT.md)
