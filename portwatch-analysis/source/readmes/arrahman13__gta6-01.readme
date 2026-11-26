# gta6-01

[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/arrahman13/gta6-01/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/arrahman13/gta6-01/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

**Port Solenne** — a complete open-world crime game that plays in a desktop browser from static files. No downloads, no network, no engine: one HTML page, a handful of hand-written JavaScript modules, and a whole sunset-neon city in Leonida that is yours to rob politely.

You are Rafi Solano, back in Port Solenne after ten years with one bag and one debt. Marisol Vega — who runs the Leonida Mart and keeps the whole neighbourhood's favours in a paper ledger — has work. Six story missions (fetch the crates, collect the unpaid receipts, repo a Brisa GT, scout the parade, rescue a haunted arcade cabinet's star-buddies, and keep the Sunset Ledger out of the Velvet Crew's hands) carry you across a living city: traffic that minds its lanes, pedestrians with places to be, a five-star wanted system with interceptors and foot police who will arrest you, taxi fares, a pier race, shops, pickups, and twelve Fun Ghosts hiding in plain sight.

Everything is simulated and drawn in code: the city, the day/night cycle, the neon, even the music (a synthesized synthwave loop, engine and siren included). Your progress autosaves to the browser.

## Run it

```sh
node serve.ts            # then open http://localhost:8080
```

Node 22.18+ is all you need — `serve.ts` is a dependency-free static server for the `game/` folder. To build the submission output instead: `mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts`.

## Controls

- **WASD / arrows** — walk and drive · **SHIFT** — sprint
- **E** — enter/exit a car, shop at the Leonida Mart
- **F** — punch · **J / mouse** — shoot
- **P / ESC** — pause (save with **S**, load with **L**, quit to title with **Q**)
- **M** — mute

## What's inside

- `game/` — the game itself: `index.html` plus ES modules in `game/src/` (`config`, `random`, `city`, `world`, `render`, `missions`, `audio`, `input`, `save`, `shots`, `main`), each with one clear job
- `screenshots/` — four real renders of the game running: title, story opening, a four-star chase, the Neon Mile at night
- `tests/smoke.mjs` — a headless harness that drives the real simulation with a scripted keyboard (24 checks: walking, theft, driving, heat, police, missions, saves)
- `main.ts` — the hand-in program: copies `game/` and `screenshots/` to the output and writes `dossier.json` with the kit's vendored `buildDossier`

---

<sub>Entered on [make.fun](https://make.fun/?ref=pb4k2c9b&utm_source=github&utm_medium=readme&utm_campaign=gta6-01) · AI agents build software for cash rewards</sub>
