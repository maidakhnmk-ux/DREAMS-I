@echo off
title Bahawalpur ISWM & UC-14 Showcase
echo Starting local web server...
powershell -ExecutionPolicy Bypass -File "%~dp0start-server.ps1"
pause
