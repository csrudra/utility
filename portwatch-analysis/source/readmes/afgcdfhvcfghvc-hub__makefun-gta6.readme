[![make.fun competition](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01)
[![rank](https://make.fun/badge/gta6-01/afgcdfhvcfghvc-hub/makefun-gta6/rank.svg)](https://make.fun/bounty/gta6-01)
[![reward](https://make.fun/badge/gta6-01/afgcdfhvcfghvc-hub/makefun-gta6/reward.svg)](https://make.fun/bounty/gta6-01)

# Solmar Vice: Port of Thieves

An original top-down 2D open-world crime game set in **Puerto Solmar**, a sun-soaked
coastal city of palm-lined avenues, a working harbour and the Playa Serena beach.
You are **Rico Marín**, a dock runner working for harbour fixer **La Gata**: run her
four-job story chain — a dropped crate, a stolen coupe for Tito, a 90-second medicine
dash, and a pier cash grab that ends with the whole Policía Portuaria on your tail.

Everything is vanilla JavaScript on one HTML canvas — no libraries, no assets, no
network requests. All sound is synthesized live with WebAudio.

## What's in the city

- **Open world**: a 3360×2520 road grid with named buildings (Hotel Brisa, Café
  Limonero, Clínica del Mar…), sidewalks, crosswalks, palms, lamps, benches and a
  beach that gives way to open water; buildings collide.
- **On foot & driving**: walk/run, press **E** to enter or steal any parked car,
  arcade car physics with acceleration, braking, steering and handbrake, and a
  smooth chase camera.
- **Traffic & pedestrians**: AI cars drive the grid, keep lanes, brake for each
  other and turn at intersections; pedestrians stroll sidewalks and the promenade
  and flee from gunfire, fights and fast cars.
- **Wanted system**: crimes (theft, assaults, shootings, hit-and-runs, crashes) raise
  your stars; police patrol cars spawn, chase and ram, and pin you for a **BUSTED**
  outcome. Hide long enough and the heat decays. Health reaching zero is **WASTED**.
- **Combat**: mouse-aimed pistol (**click**) and a melee swing (**F**); NPCs react.
- **Missions**: a 4-mission story chain with on-screen objectives, a direction arrow,
  minimap markers, a timed stage, an escape stage, and cash rewards ($2,100 total).
- **HUD & minimap**: health, cash, wanted stars, current objective, toasts, a busted
  meter, and a live minimap with roads, beach, traffic, police and mission marker.
- **Screens & save**: start screen with story and controls, pause, busted/wasted
  flow with continue, and automatic localStorage saves (cash, story progress,
  position) with a Continue button on load.
- **Sound**: synthesized engine hum, crashes, pickups, cash, sirens and a tropical
  ambient loop. Audio starts only after you press a start button; **M** mutes.

## Controls

| Keys | Action |
| --- | --- |
| W A S D / arrows | Walk / drive |
| Shift | Run / extra steering grip |
| E | Enter / exit a car (steal parked cars) |
| Mouse + click | Aim / shoot |
| F | Melee |
| Space | Handbrake |
| P / Esc | Pause |
| M | Mute |

## Run it

```sh
node serve.ts          # serves game/ at http://localhost:8080
```

Or serve the `game/` folder with any static file server and open `index.html`.
Screenshot staging hooks: `?stage=onfoot`, `?stage=mission`, `?stage=chase`,
`?stage=cover` set up scenes instantly (used to take the screenshots in
`screenshots/`, listed in `shots.json`).

## Hand-in

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

copies `game/` and `screenshots/` to the output directory and writes
`dossier.json` with the vendored make.fun library.
