@echo off
setlocal

rem One-click safe tuning. It does not restart Explorer, so file transfers stay intact.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Invoke-ExplorerResponsivenessTuning.ps1" -Mode Apply

if errorlevel 1 (
  echo Explorer responsiveness tuning failed. Review the PowerShell output above.
  pause
  exit /b 1
)

start "" explorer.exe shell:MyComputerFolder
echo Applied. New Explorer windows open through This PC; restart Windows later if the current Explorer process needs refreshing.
