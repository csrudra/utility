# Nullifier

Runs an Xbox Series title natively on your PC — **AMD or NVIDIA, Linux or
Windows**. Not an emulator: the title's x86-64 code runs in our process and we
supply the console platform underneath it, including a D3D12 back end that
recompiles its GPU programs.

**No game files.** You need your own copy. Not affiliated with the title's
developer or publisher.

## Status

The world renders correctly and is stable — it is **not yet playable**.

| | |
|---|---|
| Menus, cutscene, prologue | work: characters, buildings, HUD, audio, input, saves |
| Frame rate (world) | **1.1–1.3 fps** on RX 9070 XT / Linux (median of 3 runs); 3–5 fps reported on Windows |
| Light in shadow | missing — the title's ray-traced light does not run, so shadowed areas are black |
| Stability | minutes-long runs, no crashes, no device loss |

The GPU is idle 93–97 % of the time: the frame is bound by per-call overhead in
the emulation layer, not by the card. Two changes carry most of the current
speed, both on by default: a 4 GB texture budget (`VICTORY_TEXTURE_BUDGET_MB`)
and one whole-section view under Wine instead of a map/unmap per page. What is
still slow, with evidence, is in [`docs/FINDINGS.md`](docs/FINDINGS.md).

## Get started

```bash
git clone git@github.com:iNiKKo/victory-universal.git
cd victory-universal          # the repo keeps its old name; the project is Nullifier
./tools/setup.sh --game /path/to/game
```

`setup.sh` installs a private Rust toolchain if needed, builds, detects your
hardware and starts the title. To run it later, or to see what it selected:

```bash
./launcher/victory-launch.sh --detect
./launcher/victory-launch.sh --game /path/to/game
./tools/bench_scene.sh "label"        # measure a change, with a picture check
```

Windows: `cargo build --release -p victory`, then
`.\launcher\victory-launch.ps1 -Game "D:\path\to\game"`.

Hardware support is a profile, not a fork: add one object to
[`launcher/profiles.json`](launcher/profiles.json).

## Contributing

One idea per PR, with a benchmark row — medians of world frames, never peaks.
Three runs per configuration, and a captured frame over 50 KB: a number without
that picture is unverified.

| Read | For |
|---|---|
| [`docs/ONBOARD.md`](docs/ONBOARD.md) | start here: fresh setup, or bringing an existing fork across |
| [`AGENTS.md`](AGENTS.md) | the rules, the merge protocol, every known landmine |
| [`docs/FINDINGS.md`](docs/FINDINGS.md) | what is slow and why, with evidence |
| [`docs/PIPELINE.md`](docs/PIPELINE.md) | how a frame is assembled and what it costs |
| [`docs/AI-PROMPT.md`](docs/AI-PROMPT.md) | paste-ready prompt for your AI assistant |

House rules: no game files; no code from XCL (GPL-2.0, incompatible); vendor
fixes must be runtime-gated; a PR without a bench row is closed.

## Credits

A rebrand and consolidation, not a rewrite. Built on
[VIctory](https://github.com/Marvisak/VIctory) by Marvisak and contributors,
[fxceless/victory-fork](https://github.com/fxceless/victory-fork) and
[myokex/victory-amd](https://github.com/myokex/victory-amd), with PRs #127,
#154 and #270 carried. GPL-3.0-or-later; upstream history and notices are kept —
see [`LICENSE`](LICENSE).

Formerly `victory-universal`.
