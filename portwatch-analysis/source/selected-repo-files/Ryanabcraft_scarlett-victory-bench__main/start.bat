@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0victory.toml" set VICTORY_CONFIG=%~dp0victory.toml
rem A tela de selecao de conta so aceita botao de controle: sem ninguem no
rem teclado, o proprio runtime aperta A. 0 desliga.
if not defined VICTORY_AUTO_ENTER set VICTORY_AUTO_ENTER=8
rem O modo de display agora vem do monitor (dxgi.rs), nao deste arquivo.
rem VICTORY_DISPLAY_MODE=1920x1080 forca um tamanho especifico.
rem Merge do que os shaders escreveram e refresh das submissoes em varias
rem threads: medido aqui, relay merge 230-312 -> 189-209 ms e snapshots
rem 126-140 -> 108-110 ms. Off por default no upstream.
if not defined VICTORY_WIDE_MERGE set VICTORY_WIDE_MERGE=1
if not defined VICTORY_WIDE_REFRESH set VICTORY_WIDE_REFRESH=1
"%~dp0target\release\victory.exe" run "D:\Jogos\GTAVI\GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe" --execute
if errorlevel 1 pause
