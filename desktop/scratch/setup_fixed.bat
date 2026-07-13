@echo off
echo =========================================================
echo Antigravity Setup Script (Safe Version - No Korean)
echo =========================================================
echo.

echo [1/3] Fixing PowerShell PATH...
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p='C:\Windows\System32\WindowsPowerShell\v1.0\'; $u=[System.Environment]::GetEnvironmentVariable('Path', 'User'); if ($u -notlike '*'+$p+'*') { [System.Environment]::SetEnvironmentVariable('Path', $u+';'+$p, 'User'); Write-Host 'Added PowerShell to User PATH.' } else { Write-Host 'PowerShell already in PATH.' }"

echo.
echo [2/3] Installing Python and UV...
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "winget install --id Python.Python.3.14 -e --silent --accept-package-agreements --accept-source-agreements; Invoke-WebRequest -Uri https://astral.sh/uv/install.ps1 -UseBasicParsing | Invoke-Expression"

echo.
echo [3/3] Creating agent_workspace...
if not exist agent_workspace mkdir agent_workspace
cd agent_workspace
"%USERPROFILE%\.local\bin\uv.exe" venv .venv --python 3.14
"%USERPROFILE%\.local\bin\uv.exe" pip install langgraph pydantic-ai python-dotenv langsmith

echo.
echo =========================================================
echo Setup Complete! agent_workspace folder is created.
echo PLEASE RESTART YOUR ANTIGRAVITY IDE NOW!
echo =========================================================
pause
