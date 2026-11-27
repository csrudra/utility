@echo off
title GTA VI Harness Launcher
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launcher.ps1"
if errorlevel 1 (
  echo.
  echo Something went wrong. Screenshot this window and send it to the AI helper.
)
pause
