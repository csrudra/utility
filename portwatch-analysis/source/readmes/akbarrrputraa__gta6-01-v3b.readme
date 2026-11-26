# VERANO HEAT

[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/akbarrrputraa/gta6-01-v3b/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/akbarrrputraa/gta6-01-v3b/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

**VERANO HEAT** is an original 2D top-down open-world crime game set in the
fictional sun-soaked city of **Port Verano**. You play Dario Cruz, a former
mechanic pulled back into the streets by fixer Mara Solis. Explore 9
districts on foot or behind the wheel, steal cars, dodge a 5-star police
response (patrol cars, roadblocks and a helicopter), fight with 4 weapons,
run 12 story missions, race the streets, buy gear, upgrade your ride and
build your standing district by district.

## Features

- **Open world** — 9 districts (Marina Bay, Old Town, Calle Sol, Downtown,
  Harbor, University, North Hills, Industrial, Beachfront), traffic,
  pedestrians, day-time sun-soaked look, minimap and waypoint arrow.
- **12 story missions** — from "First Shift" to the finale "Verano Nights",
  with cash rewards and district standing.
- **Driving** — 7 original vehicles to steal and drive (sedan, hatchback,
  pickup, taxi, van, sports car, motorcycle), with garage upgrades.
- **Police** — 5-star wanted level, patrol cars that chase and ram,
  roadblocks at 4 stars, helicopter spotlight at 3 stars, busted/wasted
  respawns.
- **Combat** — fists, pistol, SMG, shotgun and rifle, with a weapon wheel
  (hold Q), muzzle flashes, shell casings and wanted heat for violence.
- **Shops & life** — gun shop, garage, safehouses (heal + save), food
  stands, 4 procedural radio stations, street races and side jobs.
- **Save/load** — progress autosaves after missions and at safehouses
  (localStorage), or with F5 / F9.
- **Sound** — fully synthesized WebAudio effects and radio music; no
  audio files, no network requests, everything runs offline.

## How to run

No build step, no dependencies. Serve the `game/` folder with any static
server and open `index.html` in desktop Chrome:

```sh
node serve.ts
# then open http://localhost:8080
```

Or serve it directly, e.g. `python3 -m http.server` inside `game/`.

## Controls

| Key | Action |
| --- | --- |
| WASD / arrows | Move / drive |
| Mouse | Aim (on foot) |
| Click | Shoot |
| E | Enter / exit vehicle, interact |
| Q (hold) | Weapon wheel |
| 1–4 | Select weapon |
| R | Change radio station |
| Space | Handbrake / sprint |
| Shift | Sprint |
| P / Esc | Pause |
| M | Mute |
| F5 / F9 | Save / load |

## Entry

This repository is an entry for the make.fun **gta6-01 "Make GTA 6"**
competition. `main.ts` (Node 22, standard library only) copies `game/` and
`screenshots/` to `/output` (or `$MAKEFUN_OUTPUT_DIR`) and writes
`/output/dossier.json` with `buildDossier` from `vendor/makefun-game.ts`.

Everything in this game — city, characters, vehicles, names, story, art,
sounds and music — is original. Nothing is taken from any commercial game.
