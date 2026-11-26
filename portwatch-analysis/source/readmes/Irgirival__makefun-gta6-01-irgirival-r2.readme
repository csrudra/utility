# Port Meridian — A Getaway Story

[![Make GTA 6](https://make.fun/badge/gta6-01.svg)](https://make.fun/bounty/gta6-01)
[![Rank](https://make.fun/badge/gta6-01/Irgirival/makefun-gta6-01-irgirival-r2/rank.svg)](https://make.fun/bounty/gta6-01)
[![Reward](https://make.fun/badge/gta6-01/Irgirival/makefun-gta6-01-irgirival-r2/reward.svg)](https://make.fun/bounty/gta6-01)

An original open-world crime game for the [Make GTA 6](https://make.fun/bounty/gta6-01) bounty on make.fun. A complete 2D top-down open world that runs offline in desktop Chrome from its own static files — no network requests, no external assets, everything drawn and synthesized in code.

## The game

You are a getaway driver new to **Port Meridian**, a fictional sun-soaked harbour city. Mara Voss's crew has three jobs for you — and the city's police have other plans.

- **Explore on foot and by car** — walk the sidewalks or steal any traffic car (press `E`) and drive it
- **Living traffic and pedestrians** — cars drive the road grid, turn at junctions, and pedestrians stroll, panic and flee
- **Wanted level** — five stars of heat that rise with every crime (stealing, shooting, hitting pedestrians) and fade when you lay low; police cruisers chase, ram and arrest you
- **Three chained missions with a story** — *First Job*, *The Getaway* and *Harbour Lights*, with dialogue, objectives, payouts, and fail states
- **Combat** — pistol shooting and punching, on foot, against a rival crew
- **HUD with live minimap** — health, cash, wanted stars, clock, district and street names, speedometer, mission objective
- **Start screen, pause, and save** — progress saves to localStorage automatically after every job and on pause; continue anytime
- **Polish** — day/night cycle with headlights and neon windows, synthesized WebAudio engine hum, sirens, gunshots and a street-groove soundtrack, particles, smoke and damage, seven named districts

## Controls

| Key | Action |
| --- | --- |
| WASD / Arrows | Walk / drive |
| SHIFT | Run |
| E | Steal / enter / exit car, pick up mission items |
| SPACE | Shoot pistol (on foot) |
| F | Punch |
| M | Mission phone (start / retry jobs) |
| P / ESC | Pause (auto-saves) |
| U | Mute sound |

## Play it

```sh
node serve.ts
# open http://localhost:8080
```

## Structure

```
game/
  index.html        page shell, loads the game
  src/
    config.js       tuning, palette, districts, streets, names
    random.js       seeded RNG for deterministic city + shots
    world.js        city generation: roads, blocks, buildings, parks
    entities.js     player, traffic, police, pedestrians, bullets
    missions.js     three chained missions, dialogue, objectives
    render.js       city/vehicle/people drawing, HUD, minimap, menus
    audio.js        WebAudio synth: engine, siren, shots, music
    input.js        keyboard state + edge-triggered presses
    shots.js        ?shot= scene staging for screenshots
    main.js         game loop, state machine, wanted, save/load
```

## Originality

Every name, character, vehicle, street, district and story beat is invented for this game. Nothing is taken from Rockstar Games, Grand Theft Auto, or any other commercial game. All art is drawn procedurally on canvas and all sound is synthesized with WebAudio.
