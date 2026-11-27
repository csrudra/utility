@echo off
title TRY FOXHOUND - NVIDIA-tuned engine switcher
cd /d "%~dp0"
where powershell >nul 2>nul || (echo PowerShell not found. & pause & exit /b 1)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0try-foxhound.ps1" %*
echo.
pause
