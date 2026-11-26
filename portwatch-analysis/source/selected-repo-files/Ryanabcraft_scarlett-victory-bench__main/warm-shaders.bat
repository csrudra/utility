@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0victory.toml" set VICTORY_CONFIG=%~dp0victory.toml
rem Traduz e compila todos os shaders do jogo uma vez, para o cache.
rem Sem isto o primeiro run depois de qualquer mudanca no tradutor de
rem shader passa minutos a 10-12 s por frame compilando pipeline no meio
rem do jogo. Com isto, o run seguinte ja entra quente.
"%~dp0target\release\victory-warm.exe" "D:\Jogos\GTAVI\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe"
if errorlevel 1 pause
