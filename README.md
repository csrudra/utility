# Utility: VIctory launcher and PortWatch research

This checkout currently contains two related pieces:

- **`harness/`** — a Windows PowerShell launcher and diagnostics wrapper. It downloads/builds a separate community VIctory compatibility layer; it does **not** contain the game's renderer or game data.
- **`PORTWATCH_*.md` and `portwatch-analysis/`** — a dated research snapshot of public repositories, reported fixes, and limitations. Treat reported performance/results as source claims unless independently reproduced.

## Start here

- [Harness setup and usage](harness/README.md)
- [Black-screen and lighting review](harness/LIGHTING_AND_BLACKSCREEN_REVIEW.md)
- [Black-screen diagnosis runbook](PORTWATCH_720P_BLACKSCREEN.md)
- [Public-fix audit](PORTWATCH_FIX_REPORT.md)
- [Archived performance/frame-generation claims (unvalidated; not a recommendation)](PORTWATCH_20FPS_WORKAROUND.md)

## Important limits

The compatibility layer is experimental, incomplete, and build-specific. A fully black game window, dark indirect-lit areas, black character textures, and a Windows display-driver reset are different failures with different causes. The ambient-light setting is only a fallback approximation; it cannot repair a broken present path, missing shaders, or missing textures. No game files, keys, or executables are included. Third-party source/build scripts are not official game software; inspect them and follow applicable law before use.

The research bundle was assembled from public READMEs, commits, and selected source files; reported results are not necessarily independently reproduced. It is not a substitute for a screenshot, the exact run log, or a reproducible test on your hardware.
