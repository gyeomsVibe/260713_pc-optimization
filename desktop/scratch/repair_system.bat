@echo off
C:\Windows\System32\chcp.com 65001 > nul 2>&1
echo =========================================================
echo  Windows Update & MS Store Deep Repair Script
echo =========================================================
echo.

echo [1/4] Resetting Local Group Policy Cache...
if exist C:\Windows\System32\GroupPolicy\Machine\Registry.pol (
    del /f /q C:\Windows\System32\GroupPolicy\Machine\Registry.pol >nul 2>&1
    echo - Removed GPO Registry.pol cache.
) else (
    echo - GPO Registry.pol cache is already clean.
)
echo - Forcing Group Policy Update...
C:\Windows\System32\gpupdate.exe /force >nul 2>&1
echo - Group Policy updated.

echo.
echo [2/4] Removing residual block registries...
C:\Windows\System32\reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f >nul 2>&1
C:\Windows\System32\reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\WindowsStore /f >nul 2>&1
echo - Residual policy registries removed.

echo.
echo [3/4] Trying to unlock and start update services...
C:\Windows\System32\reg.exe add HKLM\SYSTEM\CurrentControlSet\Services\wuauserv /v Start /t REG_DWORD /d 3 /f >nul 2>&1
C:\Windows\System32\reg.exe add HKLM\SYSTEM\CurrentControlSet\Services\dosvc /v Start /t REG_DWORD /d 3 /f >nul 2>&1

C:\Windows\System32\net.exe start wuauserv >nul 2>&1
C:\Windows\System32\net.exe start dosvc >nul 2>&1
echo - Services triggered.

echo.
echo [4/4] Ensuring Microsoft Store Appx package registration...
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$path = Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'Microsoft.WindowsStore*_x64__8wekyb3d8bbwe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName; if ($path) { Add-AppxPackage -DisableDevelopmentMode -Register \"$path\AppxManifest.xml\"; Write-Host '- Microsoft Store appx registration complete.' } else { Write-Warning 'Store directory not found!' }"

echo.
echo =========================================================
echo Repair commands executed.
echo =========================================================
