@echo off
title TRY-FXCELESS - experimental renderer switcher
cd /d "%~dp0"
where powershell >nul 2>nul || (echo PowerShell not found. & pause & exit /b 1)

if not exist "%~dp0try-fxce.ps1" (
  echo This switcher is incomplete: try-fxce.ps1 is not present in this checkout.
  echo It will not download or build anything.
  echo.
  echo Upstream fxceless/victory-fork main was checked on 2026-11-27.
  echo It reports ray-traced lighting after scene streaming, but only 0.2-3
  echo world fps, 23-27 GB system memory, and 9.2-9.6 GB VRAM on one RTX 4070
  echo / 32 GB test PC. Black faces can still appear during the first minutes,
  echo and long-run device loss remains unresolved.
  echo This is not a recommended lighting fix for a 6 GB / 16 GB laptop.
  echo See harness\LIGHTING_AND_BLACKSCREEN_REVIEW.md for the evidence.
  pause
  exit /b 2
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0try-fxce.ps1" %*
echo.
pause
