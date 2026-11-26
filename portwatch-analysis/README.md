# PortWatch analysis artifacts

Generated 2026-11-26 UTC. These are research artifacts only; no code from the current
`csrudra/utility` repo was used as project logic.

- `../PORTWATCH_FIX_REPORT.md` — main human-readable report (repo root).
- `../PORTWATCH_FIX_MATRIX.csv` — curated actionable fix matrix (repo root).
- `catalogs/` — complete indexed inventories: 6,343 relevant public commit headlines,
  2,910 de-duplicated fix messages, 624 branch-only relevant commits, 2,136 README
  keyword lines, 134 relevant defects from the knowledge catalog, and keyword snippets.
- `metadata/` — live-repo metadata, branch list/coverage, branch comparison data,
  curated-repo license/branch table, and fetch indexes.
- `source/` — PortWatch site source snapshot, all fetched README texts, selected
  repository docs/patches/launch scripts, and the `gta6-port-knowledge` docs/catalog.
- `scripts/` — Python tools used to fetch/derive the catalogs.

The site source says it contains no game files, keys, executables, or bypasses, and
warns that fake "PC installer" repos may be malware. Private PortWatch builds with
no public code are claims, not fixes. See the main report for caveats.
