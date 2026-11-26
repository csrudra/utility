# gta6-01-v4
[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/Steveales-1122/gta6-01-v4/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/Steveales-1122/gta6-01-v4/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

**SUNSET KEYS v4 — Port Alba** is a complete open-world crime game in the browser: a sun-soaked coastal city you explore on foot, by car, by plane and by boat, with traffic, pedestrians, police chases, gang turf war, planned heists, an economy, properties and a 14-mission story with three endings. Every name, character, vehicle and place is original — nothing from any commercial game.

## How to play
Open `game/index.html` from any static server (`node serve.ts`, then http://localhost:8080). Keyboard + mouse, no network needed.

- **WASD / Arrows** — walk, drive, fly, sail. **Shift** — sprint.
- **Mouse** — aim. **Click** — shoot. **V** — melee.
- **E** — interact (rest/buy at safehouses and businesses, board planes and boats).
- **F** — enter / exit the nearest car. Steal any parked car and drive it.
- **Q** — cycle weapon. **R** — radio station. **M** — mute.
- **H** — heist planning board. **G** — garage. **B** — Ironworks gun shop.
- **1 / 2 / 3** — taxi, vigilante, paramedic side jobs. **4** — start a turf war.
- **P / Esc** — pause. Save at any owned safehouse, or Ctrl+S.

## What's in v4
- **Story — 14 missions, 3 endings.** Work for fixer Mara Voss, wheelman Dario Kell and hacker Ivy Chen against Rex Marlowe's Vipers, King Solomon's Kings and Sofia Marina's Marina Boys. Your heist approach and turf decide the ending: Kingpin, Clean Getaway, or Truce.
- **Economy + progression.** Cash from missions and side jobs, XP and levels, three skill tracks (Driving, Shooting, Stamina) that grow as you use them and unlock gear, missions and heists.
- **Properties + businesses.** 3 safehouses (save, heal, garage) and 3 businesses (auto works, cab firm, arcade) paying passive income every game hour.
- **Garage.** Buy cars, repaint them, tune them in 3 stages, have any car delivered to you.
- **Ironworks gun shop.** Pistol, SMG, shotgun and rifle, plus ammo and body armor. Combat with building cover and gang AI that flanks you.
- **Turf war.** Six districts, three rival crews. Capture a district for +$150/hour and more police heat.
- **Heist planning.** Three heists (Airport Cargo, Portside Vault, Kasino Alba) with a planning board: pick a crew (they take a cut), an approach (LOUD / QUIET / SNEAK), and finish two prep missions each before the launch.
- **Airport + planes.** Alba International with three flyable planes; boats at the Marina, including a yacht.
- **Living city.** Traffic, pedestrians who panic, dynamic events (street robberies, APD chases), stunt jumps, 24 hidden packages, day/night cycle, rain / fog / storm weather, three procedural radio stations (WebAudio).
- **HUD + minimap.** Health, armor, cash, XP bar, wanted stars 0–5, mission tracker, turf-colored minimap, and a police helicopter with a searchlight at wanted 4–5.
- **Save.** Three localStorage slots.

## Structure
`game/src/` splits the game into one clear job per file: `state.js` (shared state), `city.js`, `districts.js`, `vehicles.js`, `planes.js`, `boats.js`, `pedestrians.js`, `traffic.js`, `police.js`, `combat.js`, `weapons.js`, `missions.js`, `heists.js`, `turf.js`, `economy.js`, `properties.js`, `garage.js`, `progression.js`, `sidejobs.js`, `events.js`, `daynight.js`, `weather.js`, `water.js`, `audio.js`, `radio.js`, `hud.js`, `minimap.js`, `save.js`, `story.js`, `effects.js`, `input.js`, `shots.js`, `render.js`, `ui.js`, `main.js`. `main.ts` (Node 22, stdlib only) copies `game/` + `screenshots/` to `/output` and writes `dossier.json` via the kit's `vendor/makefun-game.ts`.
