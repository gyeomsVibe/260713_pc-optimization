@echo off
C:\Windows\System32\chcp.com 65001 > nul 2>&1
echo ===================================================
echo  Windows Time Force Synchronizer (NTP Resync)
echo ===================================================
echo.

:: Check w32time service and start if stopped
C:\Windows\System32\sc.exe query w32time | findstr /I "RUNNING" > nul
if errorlevel 1 (
    echo [Info] w32time service is not running. Starting service...
    C:\Windows\System32\net.exe start w32time > nul 2>&1
)

:: Retry loop to force sync time
setlocal enabledelayedexpansion
set retry=0
:loop
set /a retry+=1
echo [Attempt !retry!/5] Resynching time with time.windows.com...
C:\Windows\System32\w32tm.exe /resync /rediscover > nul 2>&1
if !errorlevel! equ 0 (
    echo.
    echo ===================================================
    echo [Success] System time successfully synchronized!
    echo ===================================================
    C:\Windows\System32\timeout.exe /t 3 > nul
    exit /b 0
)

if !retry! lss 5 (
    echo [Warning] Sync failed. Waiting 5 seconds before retry...
    C:\Windows\System32\timeout.exe /t 5 > nul
    goto loop
)

echo.
echo ===================================================
echo [Error] FAILED to synchronize system time after 5 attempts.
echo Please check your internet connection.
echo ===================================================
C:\Windows\System32\timeout.exe /t 5 > nul
exit /b 1
