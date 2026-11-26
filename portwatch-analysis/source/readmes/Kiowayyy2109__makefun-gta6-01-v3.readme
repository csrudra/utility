# Port Aurelia

[![make.fun gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01)
[![rank](https://make.fun/badge/gta6-01/Kiowayyy2109/makefun-gta6-01-v3/rank.svg)](https://make.fun/bounty/gta6-01)
[![reward](https://make.fun/badge/gta6-01/Kiowayyy2109/makefun-gta6-01-v3/reward.svg)](https://make.fun/bounty/gta6-01)

**Port Aurelia** is an original open-world crime game for the browser, built
from scratch in plain JavaScript and WebGL — no engine, no build step, no
network at runtime, and every sound synthesized live with WebAudio.

You are Mara Venn, a courier in a golden-hour coastal city of palm avenues,
a boardwalk, a marina and a pier. Seven story jobs — pickups, timed
deliveries, a checkpoint sprint, crate collection, a police escape and a
final lighthouse score — stand between her and a clean way out. In between:
steal and drive anything with wheels, dodge or face the Aurelia PD's
five-star wanted system, brawl and shoot it out, and hunt 20 hidden gold
packages tucked around the city.

## Features

- **A full 3D city** rendered by a hand-written WebGL engine: a street grid
  with ~190 window-lit buildings, the Aurelia Tower, a casino, palms, street
  lamps, a beach with umbrellas, a marina with boats, a wooden pier, a
  striped lighthouse and a turning ferris wheel — all under warm
  golden-hour light and distance fog.
- **On foot and behind the wheel**: enter and exit any parked or driven car
  (carjacking included), with arcade driving physics, collisions, vehicle
  damage and a speedometer.
- **Living traffic and pedestrians**: AI cars drive the grid, turn at
  intersections, brake for obstacles and each other; pedestrians stroll the
  sidewalks, flee from danger and can be knocked down.
- **Wanted system, 0–5 stars**: crimes raise your heat; police cars hunt,
  chase and ram you, and at four stars and above foot officers join in and
  shoot. Heat decays when you stay out of sight — lie low at the hideout to
  cool off. Get caught and you're **Busted**; hit zero health and you're
  **Wasted**; either way you respawn at Aurelia General, fined, job restarted.
- **Seven-mission story chain** with cash rewards and mixed objectives
  (go-to, timed delivery, checkpoint race, collection, escape), plus side
  content: 20 hidden packages at $250 each, ammo and health pickups.
- **Combat**: fists (E) and a pistol with limited ammo (mouse click),
  auto-aim, muzzle flash, and synthesized gunshot/punch/crash sounds.
- **HUD**: health bar, cash, wanted stars, mission objective with timer,
  ammo and package counters, a Busted meter, and a live circular minimap
  showing streets, traffic, police, checkpoints and packages.
- **Synthesized audio**: engine hum that follows your speed, two-tone
  sirens, gunshots, pickups and mission jingles — zero audio files.
- **Saving**: cash, mission progress, story completion and found packages
  persist in `localStorage`; pause any time with P.

## Controls

| Input | Action |
| --- | --- |
| W A S D / arrow keys | Move on foot / drive |
| Shift | Sprint on foot |
| Space | Handbrake in a car |
| F | Enter / exit a car |
| E | Punch |
| Mouse click (hold) | Fire the pistol |
| P or Esc | Pause |
| M | Mute |
| Enter | Start / continue / respawn |
| N (on title) | New game (clears the save) |

## How to run

The game is static files under `game/` — serve that folder with any static
HTTP server and open it in a desktop browser:

```sh
node serve.ts        # then open http://localhost:8080
```

To hand the entry in the way the make.fun gate expects:

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

That copies `game/` and `screenshots/` to `out/` and writes
`out/dossier.json` using `vendor/makefun-game.ts`.

Screenshot scenes are deterministic: `?shot=start|play|end&seed=1` stages
the title, a mid-chase delivery, and the story-complete scene.

## Layout

- `game/index.html` — page, HUD and menus
- `game/src/main.js` — boot, game loop, camera, screens, saving
- `game/src/world.js` — simulation: player, traffic, police, wanted, combat, missions
- `game/src/city.js` — city layout, landmarks, collisions
- `game/src/missions.js` — the seven-mission story chain
- `game/src/render3d.js` — the hand-written WebGL renderer
- `game/src/hud.js` — HUD and circular minimap
- `game/src/audio.js` — WebAudio-synthesized sound
- `game/src/input.js`, `game/src/rng.js`, `game/src/shots.js` — input, seeded RNG, screenshot staging
- `main.ts` — the hand-in program; `vendor/makefun-game.ts` — the kit library, unchanged
