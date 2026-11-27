@echo off
title TRY UNIFIED - character-fix engine switcher
cd /d "%~dp0"
where powershell >nul 2>nul || (echo PowerShell not found. & pause & exit /b 1)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0try-unified.ps1" %*
echo.
pause
