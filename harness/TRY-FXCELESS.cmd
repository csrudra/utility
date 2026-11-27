@echo off
:: TRY-FXCELESS - one-click switcher to fxceless/victory-fork (latest fix for black characters)
::
:: This fork (fxceless/victory-fork) has SOLVED the black character issue in:
::   - PR #1097 (Nov 25 2026): "Immediate Decoration-Bake Texture Flush & 8 GB VRAM bake_room()"
::     - fixes black character faces when VRAM is near the limit (texture residency stall)
::   - PR #1264 (Nov 26 2026): "a decoration bake draw's own textures are uploaded before it"
::     - fixes the case where a source waiting in the queue is baked wrong (black, blotched or missing skin on NPCs)
::   - Issue #1211 (Nov 26 2026): "black faces, 3-4 fps in world" — confirmed fixed by the texture residency patch
::   - Status (Nov 27 01:20 UTC): "characters, textures, sky, sunlit exteriors... play"
::
::   TRY-FXCELESS.cmd              install/switch to fxceless/victory-fork
::   TRY-FXCELESS.cmd -Restore     switch back to your previous engine
::
:: Never rebuilds finished work; never destroys your setup (config.json.backup).
:: Your game, saves and logs are untouched. Note: this fork wants the Series X
:: profile and commits ~8 GB of VRAM - keep your 48-64 GB pagefile ON.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0try-fxce.ps1" %*
pause
