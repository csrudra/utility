# tools/watch — upstream source watcher

Tracks head commits of the public projects this lab reads, so a "what's new" question is answered by a
recorded diff instead of by browsing.

## Run it

```powershell
powershell -File tools\watch\sweep.ps1
```

In the lab this is just the word **sweep**. It takes ~20–40 s, needs `git` on `PATH` and network
access, and spawns no agents.

## How it works

1. Reads `sources.json` — the registry.
2. `git ls-remote --heads https://github.com/<name>.git` for each entry to get the current head per branch.
3. Compares against `state.json` (the previous heads).
4. For anything that moved, reads the repo's Atom commit feed and takes the first three commit subjects.
5. Rewrites `state.json`, writes `latest.json`, and appends to `deltas.md`.

Outputs are written to `notes\watch\`, which the script resolves as two levels above `tools\watch\` —
i.e. the repository root here, or the notes tree when the script sits inside a lab checkout. Keep the
generated files out of version control: `state.json` is machine state, and `deltas.md` is history you
may want to keep elsewhere.

| Output | Use |
|---|---|
| `state.json` | head baseline. Machine-written; do not hand-edit |
| `latest.json` | `checked_utc` plus `changes[{repo,branch,status,from,to,subjects}]` where status is `changed`, `new`, `gone` or `unreachable` |
| `deltas.md` | append-only history, one block per run |

## The registry (`sources.json`)

An array of objects:

```json
{ "name": "owner/repo", "branches": ["main"], "category": "runtime", "url": "https://github.com/owner/repo" }
```

- `name` — `owner/repo`, as GitHub spells it. This is what gets queried.
- `branches` — restrict tracking to these branches. Omit or leave empty to track every head.
- `category` — free text used for grouping: `runtime`, `shaders`, `formats`, `vm`, `title`.
- `url` — for humans; the script builds its own URLs.

Add new sources here, never only in prose, or the next sweep will not know about them.

## Rules of use

1. **Commit subjects are leads, not evidence.** Fetch the diff or the raw file before claiming anything.
2. Head changes are reported as heads and subjects only. Triage into a watchlist document is a separate,
   explicitly requested step (**sweep deep**), and hunting for brand-new sources happens only then.
3. Never upgrade a pinned runtime or rebase a frozen baseline because upstream moved. Note the delta and
   move on.
4. GitHub API/feed rate limits are shared and low; the Atom feed and `ls-remote` are used to stay under them.
