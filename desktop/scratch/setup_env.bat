@echo off
C:\Windows\System32\chcp.com 65001 > nul 2>&1
echo =========================================================
echo  Antigravity Optimization Agent Auto Setup Script
echo =========================================================
echo.

echo [1/3] Restoring PowerShell Path (Safe Mode)...
:: Add PowerShell to User PATH using Registry API
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p='C:\Windows\System32\WindowsPowerShell\v1.0\'; $u=[System.Environment]::GetEnvironmentVariable('Path', 'User'); if ($u -notlike '*'+$p+'*') { [System.Environment]::SetEnvironmentVariable('Path', $u+';'+$p, 'User'); Write-Host '- Added PowerShell to User PATH.' } else { Write-Host '- PowerShell path already in PATH.' }"
echo - Complete.

echo.
echo [2/3] Checking and Installing Python and UV...
:: Install Python 3.14 via winget only if not present, and install UV
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$py=Get-Command python.exe -ErrorAction SilentlyContinue; if ($py) { Write-Host '- Python is already installed.' } else { Write-Host '- Python not found. Trying to install via winget...'; if (Get-Command winget -ErrorAction SilentlyContinue) { winget install --id Python.Python.3.14 -e --silent --accept-package-agreements --accept-source-agreements } else { Write-Host 'winget not found. Please install Python 3.14 manually.' } }; Write-Host '- Installing UV package manager...'; Invoke-WebRequest -Uri https://astral.sh/uv/install.ps1 -UseBasicParsing | Invoke-Expression"

echo.
echo [3/3] Initializing Agent Workspace...
if not exist agent_workspace mkdir agent_workspace
cd agent_workspace
:: Create venv using --clear option to prevent interactive prompt, and install packages
"%USERPROFILE%\.local\bin\uv.exe" venv .venv --python 3.14 --clear
"%USERPROFILE%\.local\bin\uv.exe" pip install langgraph pydantic-ai python-dotenv langsmith

echo.
echo =========================================================
echo Setup completed successfully!
echo Please RESTART Antigravity IDE to reload environment variables.
echo =========================================================
pause
