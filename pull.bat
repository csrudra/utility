@echo off
title GTA VI Harness - Update from GitHub
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0pull.ps1"
echo.
pause
