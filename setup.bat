@echo off
setlocal

rem NexusLife setup launcher for Windows CMD.
rem The actual setup script is Bash; Git for Windows (Git Bash) is required.

where bash >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Bash tidak ditemukan.
  echo Instal Git for Windows dari https://git-scm.com/downloads/win
  echo lalu buka terminal Git Bash dan jalankan: bash setup-nexuslife.sh
  exit /b 1
)

bash "%~dp0setup-nexuslife.sh"
exit /b %errorlevel%
