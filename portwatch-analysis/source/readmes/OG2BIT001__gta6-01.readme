[![make.fun · gta6-01](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![rank](https://make.fun/badge/gta6-01/OG2BIT001/gta6-01/rank.svg)](https://make.fun/bounty/gta6-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)
[![reward](https://make.fun/badge/gta6-01/OG2BIT001/gta6-01/reward.svg)](https://make.fun/bounty/gta6-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-01)

# Port Solana: Neon Heat

An original top-down open-world crime game that runs in the browser — no build step, no
libraries, no network requests. You are Jules "Rook" Ferreira, new in Port Solana, a
sun-soaked bay city of palms, neon and other people's cars. Fixer Mara Voss has five
jobs for you. The Port Solana Police Department has opinions about how you do them.

## How to play

Open `game/index.html` in a desktop browser, or serve the folder:

```
node serve.ts          # then open http://localhost:8080
```

| Input | Action |
| --- | --- |
| W A S D / arrows | Walk and drive |
| Shift | Run on foot · handbrake in a car |
| E | Enter / exit a car (stealing one is a crime, if anyone sees) |
| Mouse + click | Aim and shoot with the pistol · click to punch without one |
| F | Interact: buy a pistol/ammo at Solana Supply, take a taxi fare at Hotel Solana, enter the street race at the Neon Mile Arcade |
| P / Esc | Pause |
| M | Mute |

**The loop.** Follow the gold marker to Mara's garage and work her five-job story: a
stolen coupe, a hot package run to the marina, three debt collections, an armored van,
and one last neon goodbye at the seaplane dock. Between jobs, the city pays: taxi fares,
stolen cars stripped at the Portside Chop Shop, and a five-checkpoint street race.

**The law.** Crimes witnessed by civilians or officers raise your heat; heat becomes
stars (up to five). Interceptors hunt you, officers bail out and fight on foot, and if
they pin you down you are **BUSTED** — a fine, your pistol, and your day. Break line of
sight and the stars drain. Get **WASTED** and Solana General sends you the bill instead.

## What is implemented

- A seeded, procedurally built city: 8×6 blocks across nine named districts, avenues
  with lane discipline and crosswalks, parking lots, parks, a beach, piers and the bay,
  landmark buildings with signage, palms, lamps and shipping containers.
- Driving with arcade physics — acceleration, grip, handbrake slides, skid marks,
  building and car collisions, damage and smoking wrecks — across nine vehicle types.
- On-foot mode with running, fists, a purchasable pistol with mouse aim, pickups
  (cash, health, ammo) and health regeneration.
- Traffic that follows the road grid and brakes for obstacles, parked cars, and 40+
  pedestrians who stroll, panic and flee.
- A full wanted system: witnessed-crime heat, five stars, interceptor spawns that scale
  with the stars, foot officers who chase, shoot and baton, an arrest meter, and heat
  decay when you are lost from sight.
- Five story missions with staged objectives (go-to, steal, deliver, timed delivery,
  fights, a holdout), plus taxi fares, chop-shop sales and a checkpoint race.
- HUD with cash, district and clock, health, wanted stars, weapon and ammo, mission
  banner with distance, phone toasts, and a full-city minimap with the objective, the
  law and you on it.
- A day cycle: dawn warmth, bright afternoons, neon dusk, and night with lamp glow and
  headlights.
- Fully synthesised WebAudio sound: engine, sirens, gunfire, impacts and a synthwave
  loop. No audio files.
- Title, pause, help, wasted and busted screens; progress saved to localStorage with
  Continue on the title screen.

## Layout

- `game/` — the game itself: `index.html`, `style.css`, and ES modules in `game/src/`
  (world generation, cars, pedestrians, player, police, missions, combat, rendering,
  HUD, screens, save, and the deterministic screenshot scenes in `shots.js`).
- `main.ts` — the hand-in program: copies `game/` and `screenshots/` to the output
  directory and writes `dossier.json` with the vendored library in `vendor/`.
- `serve.ts` — a small static server for playing locally.
- `shots.json` — the screenshot scenes (`?shot=title|drive|chase|foot&seed=7`); each
  scene is staged by the game's own code and flagged ready via `window.__shotReady`.
- `screenshots/` — four 1280×720 JPEGs rendered from the game's own draw calls.

## Bounty

Built for the make.fun bounty **gta6-01 — "Make GTA 6"**:
https://make.fun/bounty/gta6-01

## Licence

MIT — see `LICENSE`.
