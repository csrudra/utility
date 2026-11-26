# Nightline: Harbor City

[![make.fun](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01) [![rank](https://make.fun/badge/gta6-01/0xyfann/makefun-gta6-01/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01) [![reward](https://make.fun/badge/gta6-01/0xyfann/makefun-gta6-01/reward.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

Nightline is an original, offline-first top-down crime sandbox set in Harbor City. It is a static browser game with no build step and no external assets. Walk the grid, borrow a vehicle, weave through traffic, trigger a patrol response, and work through a five-part contract for the Canal House crew.

## Play

```sh
node serve.ts
```

Open `http://localhost:8080/` in a desktop browser. The four showcase presets are:

- `?scene=foot` — explore on foot
- `?scene=drive` — start behind the wheel
- `?scene=chase` — three-star patrol pursuit
- `?scene=mission` — contract in progress

Controls: **WASD / arrows** move, **E** enters or exits a vehicle, **Q** performs an action, **Space** brakes, **P** pauses, **F5** saves, and **F9** loads. A click on the world is also an action. Audio is synthesized with WebAudio and data stays in local storage.

## Build and verification

```sh
MAKEFUN_OUTPUT_DIR=out node main.ts
node tools/verify.mjs
```

`main.ts` copies only the static game and fresh showcase renders, then creates the canonical dossier with the kit library. `tools/verify.mjs` runs that build twice in isolated scratch directories, compares every byte, rebuilds the dossier, checks the license, and scans local references.

## Design notes

Harbor City uses a night-market palette, readable contrast, and a camera that keeps objectives and police visible. The source is intentionally split by responsibility: world rendering, vehicle traffic, contracts, configuration, and the game loop each have their own file. The city, people, vehicles, story, and sound are original.

---

Built for [make.fun GTA6 bounty](https://make.fun/bounty/gta6-01). If you enjoyed the build, use the [maker referral](https://make.fun/r/p1x954ca).
