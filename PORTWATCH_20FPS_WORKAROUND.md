# Performance and frame-generation notes — no prediction or recommendation

**Status:** rewritten 2026-11-27 UTC. The earlier version combined self-reported FPS from different forks, GPUs, VRAM capacities, scenes, drivers, and settings, then extrapolated them into a 6 GB laptop forecast and a suggested frame-generation stack. That arithmetic was not a valid benchmark. Its claims that 20 real FPS was impossible, or that a configuration would produce 20+ displayed FPS, are withdrawn.

## What can be concluded

- A result from one fork or scene does not predict another fork, scene, GPU power limit, driver, or memory configuration. Scaling FPS by synthetic benchmark ratios is not a substitute for matched-scene measurements.
- Real rendered/simulated frame rate and interpolated/displayed frame rate are different metrics. Frame generation may increase displayed motion cadence, but does not increase the underlying render/simulation rate and can introduce latency or artifacts.
- This repository has no renderer source or reproducible runtime benchmark. The launcher telemetry is host-level (and GPU counters are NVIDIA-specific); it does not establish per-switch costs or a game-process frame-time breakdown.
- No pagefile size, RAM purchase, GPU purchase, overclock, HDR mode, or third-party frame-generation modification is recommended here. Use the selected fork's current requirements and actual logs/counters; do not use frame-rate extrapolations to buy hardware.

## Safe benchmarking protocol

For a meaningful A/B, use the exact same fork/commit, executable, save, camera, scene, display mode, driver, and settings. Record a screenshot, full run log, error log, settings file, warm/cold cache state, and a stable time window after streaming. Change one supported setting at a time. Report base render/simulation FPS separately from any displayed/interpolated FPS, and include frame-time percentiles if the game exposes them.

Do not combine switches collected from different VIctory-family branches. A `VICTORY_*` variable being present in the environment does not prove that the selected binary reads or supports it. Do not install unofficial DLL proxies or driver modifications based on claims in the previous version of this document; they were not tested by this repository and present security, compatibility, and stability risks.

## Related material

- [Black/blank output triage](PORTWATCH_720P_BLACKSCREEN.md)
- [Lighting and black-screen source review](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md)
- [Historical PortWatch source survey](PORTWATCH_FIX_REPORT.md)
- [Historical patch catalog and limits](PORTWATCH_BREAKTHROUGH_REUSE_6GB.md)
