# Port Azura

[![Competition](https://make.fun/badge/gta6-01.svg)](https://make.fun/c/gta6-01)
[![Rank](https://make.fun/badge/gta6-01/bijiunta573/port-azura-v2/rank.svg)](https://make.fun/c/gta6-01)
[![Reward](https://make.fun/badge/gta6-01/bijiunta573/port-azura-v2/reward.svg)](https://make.fun/c/gta6-01)

**Port Azura** is an original open-world crime game that runs entirely offline
in a desktop browser. You are **Rico Vale**, a wheelman fresh off the ferry in
the neon coastal city of Port Azura. Run a seven-job story for the Marisol
crew — meet the boss, steal wheels, run a marina pickup, make a hot delivery,
cool down the heat, pull the big score, and catch the ferry out — while the
Azura PD does everything it can to stop you.

Built for the [make.fun "Make GTA 6" bounty](https://make.fun/c/gta6-01).
Everything is original: the city, characters, vehicles, names, story and art
are made for this game, and every asset is procedural (three.js geometry,
canvas textures, WebAudio-synthesised sound). No network requests at runtime.

## What's in the city

- **A drivable, walkable city** — a 5×5 street grid with lane markings and
  crosswalks, ~150 buildings with lit windows and neon signs (Hotel Sol,
  Club Vela, Cafe Luna, Pier 9…), palm trees, a beach and an animated sea.
- **Traffic and pedestrians** — AI cars follow the street grid, brake for
  each other and turn at intersections; pedestrians stroll the sidewalks
  and flee from danger.
- **Steal and drive anything** — walk up to any car (parked or rolling) and
  press **E**. Arcade driving with handbrake, engine hum and horn.
- **Wanted system and police** — witnessed crimes (shooting, hitting
  pedestrians, ramming, grand theft) raise your stars up to 5. Police
  cruisers with flashing light bars spawn, chase and ram; break line of
  sight to cool down. Get pinned and you're **busted**; get flattened and
  you're **wasted** — both cost you cash and respawn you.
- **Combat** — a pistol (click or **F**) with tracers that downs
  pedestrians, damages cars and can disable cruisers — if anyone sees it.
- **Missions and story** — seven jobs with intros, outros, cash rewards and
  a win state, then endless paid courier runs in free roam.
- **HUD** — a live round **minimap** (roads, beach, traffic, flashing
  police blips, mission beacon), wanted stars, health bar, money, speedo
  and the current objective with distance.
- **Screens and save** — title, pause, busted/wasted and story-complete
  screens; progress (money, mission, health) auto-saves to localStorage.

## Controls

| Key | Action |
| --- | --- |
| W A S D / arrows | Walk / drive |
| Shift | Sprint |
| E | Enter / exit vehicle |
| Mouse drag | Orbit camera |
| Click or F | Shoot pistol |
| Space | Handbrake |
| H | Horn |
| P / Esc | Pause |
| M | Mute |

Touch note: the game is designed for keyboard + mouse on desktop, per the
bounty brief.

## Run it

Serve the `game/` folder with any static file server and open `index.html`:

```sh
node serve.ts        # then open http://localhost:8080
```

Or hand the entry in the way the scorer does (Node 22):

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
# writes out/game, out/screenshots and out/dossier.json
```

## Source layout

- `game/src/city.js` — the city: ground plan, buildings, neon, palms, sea, objective beacon
- `game/src/vehicles.js` — car meshes, driving physics, traffic AI, police AI
- `game/src/people.js` — Rico and the pedestrians (walk cycles, fleeing, knockdowns)
- `game/src/missions.js` — the seven-job story and free-roam courier jobs
- `game/src/game.js` — state machine, wanted system, combat, stealing, camera, save
- `game/src/hud.js` — HUD and the canvas minimap
- `game/src/audio.js` — WebAudio-synthesised engine, siren, shots and jingles
- `game/src/input.js`, `game/src/config.js`, `game/src/shots.js`, `game/src/main.js`
- `game/vendor/three.min.js` — three.js, vendored (MIT, see `game/vendor/THREE-LICENSE.txt`)

Screenshots in `screenshots/` are real renders of the game, staged with the
`?shot=cover|foot|chase|mission` scenes described in `shots.json`.

## License

MIT — see `LICENSE`.
