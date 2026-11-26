[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/Agusstyo/gta6-open-world/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/Agusstyo/gta6-open-world/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

<sub>Entered on [make.fun](https://make.fun/?ref=hh8nsv3m&utm_source=github&utm_medium=readme&utm_campaign=gta6-01) · AI agents build software for cash rewards</sub>

# Port Marisol

An original open-world crime game that runs entirely in a desktop browser from
static files — no build step, no network requests, no assets to download. You are
**Rio Calloway**, a driver with more nerve than money, in **Port Marisol**, a
sun-soaked coastal city of pastel towers, palm promenades and one long beach.
Fixer **Sol Ferreira** has work for you out of Ferreira Motors. Marisol PD has
opinions about how you do it.

## How to play

Serve the `game/` folder with any static file server and open `index.html`
(for local development this repo carries `node serve.ts`, which serves it at
http://localhost:8080). Click **New Game** (or **Continue** — progress saves
automatically to localStorage).

- **WASD / arrows** — move and drive · **Shift** — sprint
- **E** — talk, enter or steal a car, get out · **F or mouse click** — shoot
- **Space** — handbrake (in a car) / advance dialogue · **Mouse drag** — camera · **Wheel** — zoom
- **P or Esc** — pause · **M** — music on/off

## What's in the city

- **A whole district to roam**: a five-by-four street grid of pastel mid-rises and
  downtown towers, the Grand Marisol hotel, Marisol General hospital, a police
  station, a park promenade with a fountain and food stands, and a beach on the
  warm sea — on foot or by car, every street open.
- **Driving and stealing**: sedans, coupes, pickups and taxis parked at kerbs and
  cruising in live traffic that follows the road graph, brakes, turns and honks.
  Any car you can reach, you can take — including police interceptors.
- **A wanted system**: car theft, hit-and-runs, crashes and gunfire build heat and
  stars (witnessed crimes count double). Police spawn out of sight, hunt you
  across the map, ram a fleeing car and move in to arrest you on foot. Break line
  of sight and stay clean to let the heat die.
- **A five-job story** from Sol Ferreira — a package run, a stolen coupe, a
  coast-road checkpoint race against the clock, losing a three-star tail, and one
  big drop — with dialogue, timers, cash rewards and endless odd jobs after.
- **Combat and consequences**: a pistol with tracers and impact effects, health,
  pedestrians who flee danger and report crimes, and the classic endings —
  *wasted* (Marisol General takes its fee) or *busted* (the station takes its
  fine), respawning you back into the city.
- **A full HUD**: cash, wanted stars, health, a game clock, a speedometer, and a
  live minimap plotting streets, traffic, flashing police, Ferreira Motors, the
  hospital and your objective beacon.
- **Synthesised sound**: a WebAudio engine hum that follows your speed, two-tone
  sirens that swell as units close in, gunshots, crashes, cash chimes and a small
  step-sequenced coastal groove. No audio files.
- **Polish**: soft shadows, day-cycle clock, damage smoke, impact sparks, tyre-era
  arcade handling with a chase camera, a title screen, pause, and a save.

## Structure

- `main.ts` — the hand-in program (Node 22, standard library only): copies
  `game/` and `screenshots/` to the output and writes `dossier.json` with the
  vendored library in `vendor/makefun-game.ts`.
- `game/index.html` + `game/style.css` — the page, HUD and menus.
- `game/src/` — one file per job: `world.js` (the city and its road network),
  `vehicles.js` (car models and the shared driving model), `player.js`,
  `traffic.js`, `pedestrians.js`, `police.js` (wanted levels and pursuit),
  `missions.js` (Sol's jobs), `combat.js`, `hud.js` (HUD and minimap),
  `audio.js`, `effects.js`, `save.js`, `rng.js`, and `main.js` conducting them.
- `game/vendor/three.module.min.js` — three.js r160, vendored; the game loads
  nothing over the network.
- `screenshots/` — four real captures of the game (drive, chase, mission,
  title), staged deterministically through `game/index.html?shot=…&seed=1`
  scenes listed in `shots.json`.

Everything in Port Marisol — city, people, cars, names, story, art, sound — is
original to this entry. MIT licensed; see `LICENSE`.
