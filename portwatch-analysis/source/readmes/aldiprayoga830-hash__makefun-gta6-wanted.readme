# WANTED: Port Meridian

[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/aldiprayoga830-hash/makefun-gta6-wanted/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/aldiprayoga830-hash/makefun-gta6-wanted/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

An original top-down 2D open-world crime game in plain static files — no libraries, no build
step, no network requests. You arrive in Port Meridian broke and good behind a wheel; the
fixer Vex has work, the Port Meridian PD has opinions, and the harbour has a boat with your
name on it. Steal cars, run packages, dodge five stars of attention, and make the city yours.

## Features

- A 2400×2400 explorable harbour city: road grid with lanes and crosswalks, sidewalks,
  dozens of named buildings, parks, car parks, a dock district and piers over the water
- On-foot movement with collision, plus stealable parked and traffic cars with arcade
  driving physics (accelerate, brake, reverse, steer, crashes)
- Traffic AI that follows the road network and pedestrians who wander, panic and flee
- A 0–5 star wanted system: witnessed crimes raise the heat, police chase on foot and in
  police cars, breaking line of sight lets it decay; get WASTED or BUSTED and you are back
  on the street
- Combat: melee punches and a pistol fed by ammo pickups; cash and health pickups too
- A three-mission story chain from Vex (steal the coupe, lift the package, run for the
  pier) with on-screen dialogue, then free roam with repeatable delivery jobs
- HUD with health, cash, wanted stars, weapon/ammo and the current objective, plus a live
  minimap with police and mission markers
- Synthesized WebAudio sound effects (shots, punches, pickups, sirens, engine) — no audio files
- localStorage save of cash, story progress and position, with Continue on the title screen
- Pause with P or Esc

## Controls

- **WASD / arrows** — move on foot, drive in a car
- **Shift** — run
- **E** — talk, steal/enter a car, get out
- **J** or **mouse click** — punch (aim with the mouse)
- **K** — fire the pistol (needs ammo)
- **P / Esc** — pause
- **Enter** — confirm, advance dialogue, restart

## Run it

```sh
node serve.ts --port 8080
```

Then open http://localhost:8080 in a desktop browser. Everything runs offline from the
`game/` folder; `main.ts` packages the entry (`game/`, `screenshots/`, `dossier.json`) for
the make.fun grader.

## Development

This game was built by an AI agent in a single recorded session for the make.fun gta6-01
bounty. The whole mission chain was play-tested end to end — from the opening dialogue
through all three of Vex's missions and the repeatable delivery jobs — before the entry
was packaged. The four screenshots in `screenshots/` are real renders of the game:

- `1-start.jpg` — the title screen over the living city
- `2-play.jpg` — driving in traffic, with the HUD and minimap up
- `3-chase.jpg` — a police chase at three wanted stars
- `4-end.jpg` — the mission-complete panel at Vex's Garage
