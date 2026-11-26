# Port Solana — A Golden Hour Open-World Crime Story

![gta6-01](https://make.fun/badge/gta6-01.svg)
![rank](https://make.fun/badge/gta6-01/Van7art/gta6-01-r4-entry/rank.svg)
![reward](https://make.fun/badge/gta6-01/Van7art/gta6-01-r4-entry/reward.svg)

Entry for [make.fun bounty gta6-01 — Make GTA 6](https://make.fun/bounty/gta6-01).

A complete 2D top-down open-world crime game set in **Port Solana**, a sun-soaked
modern city at golden hour: warm tan streets, green Central Park, the Marina Bay
waterfront, Southside Market, Sunset Plaza, Airport Road and a highway ring.

## The city

Seven districts to explore on foot and by car, generated deterministically from a
fixed seed — the same city every time you load it. Traffic cars cruise the grid,
parked cars wait to be taken, pedestrians wander the sidewalks, and rival muscle
holds Southside Market.

## How to play

Open `game/index.html` in a desktop browser (or serve the `game/` folder with any
static server, e.g. `node serve.ts` then visit `http://localhost:8080`). No build
step, no network, no audio files — all sound is synthesized live with WebAudio.

### Controls

| Key | Action |
| --- | --- |
| WASD / Arrows | Walk / run, drive, steer |
| Shift | Run on foot |
| Space | Handbrake |
| E | Enter a car / carjack an occupied car / exit a car |
| Mouse + Click | Aim and shoot |
| R | Reload |
| F | Punch |
| Q (hold) + 1 / 2 / 3 | Weapon wheel: Pistol / SMG / Shotgun |
| M | Switch radio station |
| Z | Rico the Driver — getaway speed boost |
| X | Lena the Hacker — blackout, minus 1 wanted star |
| V | Big Marco — muscle who fights beside you |
| G | Open Rico's Garage (near the garage) |
| P | Pause |
| U | Mute |
| Enter / C | New Game / Continue (on the title screen) |

## Systems

- **Wanted level 0–5 stars.** Crimes raise the heat. Cop cars and foot cops
  pursue, roadblocks appear from 4 stars, and at 5 stars a police helicopter
  sweeps the streets with a searchlight while spike strips shred your tires.
  Stay out of sight and the heat decays.
- **Cars.** Carjacking, arcade driving physics, damage, smoke, and explosions
  that damage everything nearby and chain from car to car.
- **Combat.** Pistol, SMG and shotgun with magazines, reloads and spread;
  melee punches; a radial weapon wheel.
- **Crew of 3.** Rico (speed), Lena (blackout), Big Marco (ally fighter) — each
  on its own cooldown, shown on the HUD.
- **8 story missions** with HUD objectives, cash and respect rewards: First
  Wheels, Sunset Delivery, Park Pickup, Muscle Memory, Highway Heat, Golden
  Garage, Five Star Sunset, and King of Port Solana.
- **Respect ranks.** Hustler → Runner → Enforcer → Shot Caller → King of Solana,
  earned from missions, stunts and escapes, with a progress bar on the HUD.
- **Rico's Garage.** Repair, repaint, armor, engine upgrades and sport tires —
  each priced, each changing how the car drives and survives.
- **Radio.** Three synthesized stations — Sunset FM 98.5, Vice Wave 101.2,
  Marina Nights 104.7 — switchable in game, station name on the HUD.
- **Save & continue.** Progress saves to local storage at every completed
  mission; Continue on the title screen picks it back up.
- **HUD.** Wanted stars, health and armor bars, money, respect rank and bar,
  crew status, mission panel, minimap, speed, current weapon and ammo, radio
  station, and district names.

## Screenshots

The four staged scenes (`?scene=cover|chase|garage|foot`) are deterministic:
the same scene name always stages the same frame.

1. `1-cover.jpg` — Five Star Sunset: helicopter, searchlight, roadblock, spike
   strip and explosion in one frame.
2. `2-chase.jpg` — Highway Heat: a 4-star chase on the highway ring.
3. `3-garage.jpg` — Rico's Garage shop menu.
4. `4-foot.jpg` — Muscle Memory on foot with Big Marco.

## Development

- `node probe.js` — deterministic probe of every system (95 checks, must pass 100%).
- `node --check game/src/*.js` — syntax check every game script.
- `mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts` — build the dossier
  into `out/` and verify it is byte-identical across runs.

## License

MIT — see `LICENSE`.
