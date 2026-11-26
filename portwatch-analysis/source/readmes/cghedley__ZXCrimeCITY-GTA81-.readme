# CRIME CITY for the ZX81

A tiny top-down crime game for the Sinclair ZX81 (16K): steal cars, run over pedestrians, dodge the police,
do taxi jobs, and get on the high score table.

* `docs/index.html` – the game in the browser (the real Z80 machine code running in a small JavaScript emulator). This is the GitHub Pages site.
* `dist/crimecity_mc.p` – the machine-code version as a ZX81 tape file (emulator or real hardware)
* `dist/crimecity_basic_v2.txt` – the earlier BASIC version (type-in listing)

Controls: 5 6 7 8 steer (arrow keys also work in the browser), 0 stops, E leaves the car, Q at the title screen quits to BASIC.

## Setting up GitHub Pages with a shared high score table

1. Create a **public** repo and push this folder to the `main` branch.
2. **Settings → Pages**: Source "Deploy from a branch", branch `main`, folder `/docs`.
3. **Settings → Actions → General → Workflow permissions**: choose "Read and write permissions" (the workflow also asks for this itself, but an organisation policy can override it).
4. Make sure **Issues** are enabled (Settings → General → Features).
5. Open `https://YOUR-NAME.github.io/REPO/`, play, and submit a score to test the loop.

### How scores work
* The table lives in `docs/data/scores.json`, which Pages serves next to the game. The game reads it each time the title screen appears (falling back to raw.githubusercontent.com).
* After you enter your initials the game shows a **Submit score on GitHub** button. It opens a pre-filled issue from `.github/ISSUE_TEMPLATE/score.yml`; the player presses *Submit new issue* (a free GitHub account is needed).
* `.github/workflows/add-score.yml` runs `.github/scripts/add_score.py`. It reads every open `[score]` issue, validates it (three letters, 1 to 65535, matching check code, not a bot, at most 3 entries per GitHub account), commits the new `scores.json`, then comments on and closes the issue. A bad issue is closed with a reason. If the commit fails the issue stays open and is retried (an hourly sweep also runs).
* Until a score is accepted it is kept in the player's browser and shown in their own table.
* Scores come from the player's browser, and the check code is only a speed bump, so the table runs on trust. You can edit `docs/data/scores.json` or close issues to moderate; each entry records the GitHub account that submitted it.
* If the site is not at `owner.github.io/repo/`, set `REPO_OVERRIDE` near the top of the high-score section of `docs/index.html` (or `web/template_gh.html`).

## Build
Needs Python 3 and `pasmo` (and Node for the browser tests).

    cd src && python3 build.py && python3 mkp.py     # crime.asm -> crime.bin -> ../crimecity.p (copy to dist/)
    cd ../web && python3 build_web_gh.py ../docs/index.html   # needs sym.json and ../crimecity.p

`build.py` expands the `ZS`/`ZB`/`HSE` macros (ZX81 character codes) and runs pasmo. `mkp.py` wraps the code in a
`1 REM` line plus `2 RAND USR VAL "16514"`. `web/sym.json` holds label addresses from the build; regenerate it if you change the code.

## Tests
* `python3 tests/test_action.py` – score validation, per-user cap, git commit/push, failure handling, check-code match with the page.
* `web/page_test_gh.js` (needs `npm i jsdom`) – the page end to end with a fake `fetch`.
* `tests/` also has the Z80 emulator checks used while developing (paths may need adjusting).

## Notes
* The machine code calls ROM `$0F2B` (SLOW), reads FRAMES at `$4034`, scans the keyboard with `IN`, and avoids IX/IY and the shadow registers.
* The browser page does not include the ZX81 ROM; it uses its own Z80 core and a hand-drawn font.
* High scores in the tape version live inside the REM line, so `SAVE` after quitting to BASIC keeps them.
* No licence is included yet: pick one before publishing.
