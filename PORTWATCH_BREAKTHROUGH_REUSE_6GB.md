# Historical PortWatch research notes — no 6 GB / 16 GB plan

**Status:** rewritten 2026-11-27 UTC. This file previously presented a composite “survival plan” for an RTX 3060 6 GB / 16 GB laptop. That plan is withdrawn: it combined author-reported results from unrelated forks, commits, machines, scenes, drivers, and settings, then turned them into unsupported predictions and hardware/system recommendations. **Do not use the old recipes, FPS targets, pagefile advice, or “mandatory/recommended” labels as instructions.**

## What can be retained

The underlying public-fork survey is a research index, not a reproducible benchmark. It noted source-specific work in areas such as upload/present ordering, texture residency and streaming, indirect-command processing, cache warm-up, and bounded memory pools. Those are possible topics for investigation in the exact renderer source; this checkout contains only a launcher and does not implement or test them.

All quoted FPS, memory, stability, and regression numbers are maintainer/community reports unless an individual source says otherwise. They have not been independently reproduced in this review. A switch being listed by one fork does not show that another fork or executable supports it. No result here establishes whether a particular 6 GB machine can run the renderer, what FPS it will reach, or whether a pagefile, RAM/GPU purchase, HDR change, frame-generation tool, or specific environment variable is appropriate.

For a useful performance comparison, match the exact fork/commit, executable, save, scene, camera, driver, display mode, settings, and cache state; change one supported variable at a time. Report base render/simulation rate separately from interpolated/displayed rate. Do not extrapolate from unlike machines or use these historical notes to buy hardware.

## Current black/dark-output guidance

- [`PORTWATCH_720P_BLACKSCREEN.md`](PORTWATCH_720P_BLACKSCREEN.md) — symptom classification and evidence-first triage.
- [`harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md`](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md) — what the current launcher and checked upstream snapshots establish, limitations, and evidence needed for a specific diagnosis.
- [`harness/README.md`](harness/README.md) — launcher behavior and fork-specific caveats.
- [`PORTWATCH_FIX_REPORT.md`](PORTWATCH_FIX_REPORT.md) and [`portwatch-analysis/`](portwatch-analysis/README.md) — dated source survey and research catalogs. Their measurements remain source claims, not a validated plan for one machine.

The active question of a particular black frame cannot be answered from this repo alone. It needs the symptom type, same-scene screenshot, matching logs/settings, selected fork and commit, and hardware/driver details.
