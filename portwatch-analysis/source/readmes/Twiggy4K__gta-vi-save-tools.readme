> **PS5 workflow validated on one tested save — 2026-11-25:** The maintainer confirmed the public decoded editor → GarlicSaves website encryption → GarlicTransfer workflow loaded the intended balances in-game and preserved them after saving and reloading. This is one-console/sample evidence, not universal compatibility. Keep untouched backups and verify every return.

# GTA VI Save Tools

**Public experimental tools: a runnable decoded-save editor, a read-only checker, and research source. Not a universal restore-ready editor.**

Developed and originally tested with PS5 story saves. An external tester, **0xSavior**, also reports successfully loading, saving and reloading a PS5-derived free-roam save in an Xbox-derived PC build. This is evidence for those samples and that build, not every Xbox game, PC port, game version or save.

## What can I use today?

| Component | Runs without private research inputs? | What it does |
|---|---|---|
| **Read-only checker** | **Yes** — Windows + Node.js | Inspects already decoded JSAV saves and supported ZIPs; creates a privacy-filtered report |
| **Decoded-save editor preview** | **Yes** — Windows + Node.js | Local JSAV money editing and ZIP export; game encoding/container encryption still required |
| **Legacy local-ASAV workshop source** | **No** | Protected-ASAV reconstruction/local GarlicMgr processing still requires undistributed codec inputs |

**[Start with the plain-language guide](docs/USER-GUIDE.md).** Part A covers the checker. For the new decoded writer, follow the [decoded editor guide](docs/DECODED-EDITOR-GUIDE.md). Part B of the older guide documents the legacy private-ASAV workshop.

### Run the checker

1. Download the **checker ZIP** from [Releases](https://github.com/Twiggy4K/gta-vi-save-tools/releases), then use Windows **Extract All**.
2. Install Node.js 22 or newer from [nodejs.org](https://nodejs.org/) if needed. Node.js is not bundled; no npm packages are needed.
3. Double-click **Start-Checker.cmd** in the extracted package (or `checker/Start-Checker.cmd` in the source checkout).
4. Click **Open decoded save or ZIP** and select an already decoded JSAV file or a ZIP containing decoded SARC entries.
5. Review the result and use **Save shareable report**. Check the gameplay balances before sharing it.

The checker cannot decrypt raw PS5 containers or protected ASAV game bodies. A platform-decrypted export may still contain ASAV. Recognition is never permission to edit or restore. Reports exclude direct account IDs, source paths, GUIDs, keys and save contents; they include balances and structural findings. Do not post private saves, sidecars or credentials in issues.

## Run the decoded editor preview

Download **Windows-x64-Portable.zip** from [Releases](https://github.com/Twiggy4K/gta-vi-save-tools/releases), choose **Extract All**, then open **Start-Editor.cmd**. Node.js is included. Source-only checkouts require Node.js 22+. Open your own already decoded JSAV or a decoded export ZIP, select a slot/wallet, review the original balances, then export a separate edit. It needs no maintainer save, account data, game executable or private codec inputs for this step.

Caps: cash **0–20,000**, checking **0–2,000,000**, Family Savings **0–1,000,000**. Accounts are found by relationships across inventories, not fixed positions, original amounts or character codes. Ambiguous mappings and unknown capacities stop editing rather than guessing.

**Output is still decoded JSAV, not a restore-ready ASAV or PS5 container.** The browser handoff opens GarlicSaves for manual sign-in/upload without a worker key. The website route passed a controlled retail PS5 load/save/reload test on one slot; the return comparison checks a user-provided decrypted ZIP. See the [full guide](docs/DECODED-EDITOR-GUIDE.md).

## Demonstrated results and limits

- Original PS5 reconstruction: five original trailers matched exactly; a sixth source decoded identically to its web-exported JSAV.
- Profile-specific money changes: the maintainer reports retail PS5 loading and save/reload persistence for cash, shared checking and Family Savings changes.
- Larger checking: an above-2M balance persisted in the edited state; the displayed 3.9M capacity is not established as a universal game limit.
- Xbox-derived PC testing: the supplied original's body and trailer matched our reconstruction. Its rebuilt control loaded successfully according to 0xSavior. The PS5-derived version-2 probe loaded into free roam, then saved and reloaded according to the tester. The team did not independently run that build. New Xbox-side money edits and broad conversion remain unverified.
- All gameplay samples remain private. No game binaries, saves, account IDs, keys, executable-derived lookup payloads or private listings are included.

See [validation](docs/VALIDATION.md), [cross-platform evidence](docs/CROSS-PLATFORM-TEST.md), [known limitations](docs/RELEASE-READINESS.md) and the [detailed history](docs/DETAILED-RESEARCH-HISTORY.md).

## Developers

Node.js 22+, no npm dependencies:

```sh
npm run audit:source
npm test
```

The automated suite uses synthetic fixtures only. See [setup](docs/SETUP.md) and [architecture](docs/ARCHITECTURE.md). The old `editor/` is a historical statistic-only prototype, not recommended restoration code. The generalized writer rejects unsupported or ambiguous layouts. Other users' saves still need compatibility and backed-up acceptance testing.

## License and credits

Our independently authored code and documentation are under [MIT](LICENSE). Forks and reuse are welcome with the license notice retained. This license does not grant rights to GTA VI, third-party tools, private game inputs, saves or trademarks. See [credits](CREDITS.md) and [third-party notices](THIRD-PARTY-NOTICES.md).

This is an unofficial research project, unaffiliated with Rockstar Games, Take-Two, Sony, Microsoft or the developers of any PC build. No game or port is distributed. This clean-history public repository is separate from the original private research archive.

### Portable Windows download (0.3.1-alpha.1)

Choose **Windows-x64-Portable.zip** in Releases, use Extract All, and double-click **Start-Editor.cmd**. Keep its runtime folder alongside the editor. Node.js 24.22.3 and its license notices are included; no separate installation or Codex subscription is needed. The source-only download still requires Node.js 22+. Other workflow and experimental limitations remain unchanged.

### 0.3.2 browser handoff correction

The public UI no longer requests worker/API keys or directs users to Contribute. **Open GarlicSaves** opens the normal Encrypt page for manual sign-in/upload. One browser-based PS5 load/save/reload test passed. Historical API tests are separate. Source-only developer API helpers remain experimental and are not required by the UI.

### Website account-profile selection

Before encrypting, add/save the profile offered when decrypting the original console export, and select the corresponding profile on Encrypt. Do not assume a previously stored profile is correct. Byte-reversed duplicate profiles occurred in testing; stop on mismatched account metadata rather than guessing. Follow the profile troubleshooting and exact-download round-trip steps in [the guide](docs/DECODED-EDITOR-GUIDE.md). The same controlled PS5 test passed content/account comparison, game loading, saving and reloading.

**Website profile warning:** Add to profile may save the ID in reversed byte order. Compare with the original decrypt job; use Dashboard → profile three-dot menu → **Swap Endian** only when that specific reversal is confirmed. Re-encrypt and verify a decrypted return. See the detailed guide; this was not observed as necessary in our local GarlicMgr tests.

## Critical transfer step

After the decrypted-return check passes, extract the **encrypted website download** and choose its **SAVEDATASARC0011** container (slot 11 example) in GarlicTransfer. **Never upload SARC0011 from a decrypted ZIP.** Keep Original, Edited, Encrypted and Verification folders separate. Confirm target balances before encryption and after verification. Read the full guide before transferring.
