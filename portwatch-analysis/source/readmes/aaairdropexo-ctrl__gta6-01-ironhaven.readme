# IRONHAVEN

[![make.fun](https://make.fun/badge/gta6-01.svg)](https://make.fun/competitions/gta6-01)
[![rank](https://make.fun/badge/gta6-01/aaairdropexo-ctrl/gta6-01-ironhaven/rank.svg)](https://make.fun/competitions/gta6-01)
[![reward](https://make.fun/badge/gta6-01/aaairdropexo-ctrl/gta6-01-ironhaven/reward.svg)](https://make.fun/competitions/gta6-01)

A vertical industrial port city open-world crime game for the [make.fun gta6-01 bounty](https://make.fun/competitions/gta6-01): **Make GTA 6**.

Mara runs packages for the port workers' co-op. Today the manifest is wrong, the hardcase is sealed, and Chief Rourke wants her gone. Take the evidence hauler. Break the Iron Bridge blockade. Broadcast the ledger from the radio van — and when it goes live, the city changes: the Yard 17 gate stays open, the Iron Garage opens, and the hauler has a fixed home.

## Play

Open `game/index.html` in a desktop browser (or run `node serve.ts` and open http://localhost:8080). No network, no install, no build step.

| Key | Action |
| --- | --- |
| W A S D | Move on foot / drive the hauler |
| Shift | Sprint |
| Mouse | Look |
| Right mouse / Q | Aim |
| Click | Shoot the pistol |
| R | Reload |
| E | Enter / hijack the hauler |
| P / Esc | Pause |

Three chapters, one continuous story:

1. **Wrong Manifest** — on foot in Yard 17. Get in the evidence hauler while two officers walk in and the lockdown beacon burns. Wanted: 3 stars.
2. **Iron Descent** — drive the hauler down the Wire Hill switchbacks and through the Iron Bridge roadblock, with the interceptor on your bumper and the helicopter overhead. Wanted: 5 stars.
3. **Open Frequency** — on foot at the East Dock. Hold the radio van while the ledger broadcasts. Officers come in waves. Wanted: 4 stars.

Finish the broadcast and the campaign is complete: Port Trust +1, the Iron Garage opens, the Yard 17 gate stays open, and free roam begins with the hauler parked at its fixed home.

## The city

Ironhaven is one compact, vertical port city on a hill — Wire Hill in the west, Yard 17 in the middle, the Iron Bridge over the channel, the East Dock. Three districts, one road through them, and the same red hardcase in every chapter: strapped to the hauler's flatbed, then locked into the radio van's uplink cradle. Civilian traffic drives the loop, pedestrians walk the yard and the dock, and they flee when the wanted level rises.

Built with three.js (vendored under `game/vendor/`), plain ES modules, no external requests. The game is `game/` — `main.ts` hands it in with `dossier.json`.

## Screenshots

The four screenshots (`cover`, `chase`, `defend`, `reward`) are real game states staged by `game/src/shots.js` from the same rules a player plays by, with a fixed seed so each frame is repeatable. The defend frame shows the radio van's parabolic dish — a shallow bowl with a feed arm and horn, not a solid dome — so it reads as a dish, not a balloon.

## Run the entry program

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` copies `game/` and `screenshots/` to the output directory and writes `dossier.json`.
