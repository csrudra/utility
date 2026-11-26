@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0victory.toml" set VICTORY_CONFIG=%~dp0victory.toml
"%~dp0target\release\victory-play.exe" --rt "D:\Jogos\GTAVI\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe"
if errorlevel 1 pause
