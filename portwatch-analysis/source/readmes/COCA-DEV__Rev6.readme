# Rev6
# Rev6

Research and a Windows compatibility layer experiment for the Xbox Series build of a game dump (research only, no game files here).

- `docs/research/` - analysis notes (PE/import analysis, RPF headers, roadmap, review of the upstream Leonida runtime).
- `XboxCompat/` - own shim layer (xmem, d3d12_xs, stubs generator) and `leonida-mix/`: a patch against upstream Leonida (`5d96ea83937866d9ad75691339ddfbf99c262722`) plus notes on how far the boot gets (see its README).
- `tools/` - helpers (RPF viewer, function finder by .pdata, PDB symbolizer, DXBC carver, Ghidra headless decompile script).

Not included on purpose: the game dump, executables/DLLs, extracted or translated shaders, decompiler output of the game.

## License note
`XboxCompat/leonida-mix/leonida-mix.patch` is a modification of the upstream Leonida project (https://github.com/ItsNotRexed/Leonida), which is GPL-3.0; that patch is distributed under the same terms.
