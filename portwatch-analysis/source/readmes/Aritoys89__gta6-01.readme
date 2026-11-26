# Port Solano: Sunset Takeover

[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/Aritoys89/gta6-01/rank.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/Aritoys89/gta6-01/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

An original top-down 2D open-world crime game that runs entirely in a desktop
browser from static files — no build step, no assets, no network. The city,
characters, vehicles, story, art and music are all original and generated in
code: every sprite is drawn on a canvas and every sound is synthesized with
WebAudio.

The `main.ts` at the repository root is the make.fun hand-in program: run it
and it copies `game/` and `screenshots/` into the output directory and writes
the entry's `dossier.json` there.

**Port Solano** is a sunset coastal city — 7×7 blocks of streets, a casino
strip in the north, working docks in the south, and a beach and sea along the
east edge. You are **Rio Vane**, a broke wheelman. Fixer **Sol Vega** has five
jobs that will either make you rich or get you busted.

## The story — five missions

1. **FIRST WHEELS** ($150) — Meet Sol at her garage, steal any car, and bring it back.
2. **PACKAGE RUN** ($300) — Pick up a package at Pier 9 Freight and deliver it behind the Solano Grand Casino against the clock.
3. **HOT PURSUIT** ($450) — Grab the stash at the safehouse (the alarm trips two wanted stars) and get it to the garage.
4. **DOCKSIDE CRATES** ($600) — Recover three crates scattered around the docks, then meet the contact at the end of the pier.
5. **THE SUNSET TAKEOVER** ($1,500) — Steal Vega's golden Comet from the casino, escape at three stars, and reach the old airstrip.

Finishing the story unlocks the story-complete screen, free roam, and endless
paid errands across the city.

## Features

- **On foot and behind the wheel** — enter or exit any parked or traffic car with `E`; stealing in front of witnesses raises your wanted level.
- **Living traffic** — cars hold their lanes, brake for obstacles, and turn at intersections; drivers bail out and flee when their car is taken or hit.
- **Pedestrians with attitudes** — they wander, flee from danger, and some fight back when punched; downed pedestrians drop cash.
- **Wanted system, 1–5 stars** — police cruisers chase, ram, and pin you; a bust meter fills while a cruiser holds you slow. Break line of sight to cool the heat, star by star.
- **Punch combat** with `F`, car damage with smoke and fire, busted/wasted respawns at Solano Clinic with a fine.
- **Full HUD** — cash, health and car-condition bars, wanted stars, objective text with live distance, mission timer, and a live minimap with roads, sea, police blips, the objective blip, and a player arrow.
- **Title screen with New Game / Continue**, pause, and automatic `localStorage` saves.
- **Generated audio** — engine hum, police siren, punches, crashes, pickups, and mission jingles, all synthesized live. `M` mutes.
- Deterministic seeded city generation: the same seed always builds the same Port Solano.

## Controls

| Keys | Action |
| --- | --- |
| `W A S D` / arrow keys | Move on foot / drive |
| `E` | Enter or exit a car |
| `F` | Punch |
| `Shift` | Sprint (on foot) |
| `P` / `Esc` | Pause |
| `M` | Mute / unmute |

## Run it

Requires Node.js 22 or later. From this repository:

```sh
node serve.ts
```

Then open <http://localhost:8080> in a desktop browser. (Any static file
server pointed at `game/` works just as well — `game/index.html` is the entry
point, and the game plays fully offline.)

The make.fun entry program is `main.ts`: it copies `game/` and
`screenshots/` to the output directory and writes the `dossier.json` summary
with the vendored `vendor/makefun-game.ts` library.

## Screenshots

- `screenshots/1-start.jpg` — the title screen over the city.
- `screenshots/2-play.jpg` — the Sunset Takeover chase: the golden Comet, three wanted stars, cruisers closing in.
- `screenshots/3-end.jpg` — the story-complete screen with run stats.

Each view can be reproduced in the browser with `?shot=start|play|end&seed=1`.

## License

MIT — see `LICENSE`.
