@echo off
C:\Windows\System32\chcp.com 65001 > nul 2>&1
echo =========================================================
echo  Reverting System Optimization Settings to Default...
echo =========================================================
echo.

echo [1/3] Reverting CPU Processor Power State (AC 100%)...
C:\Windows\System32\powercfg.exe /setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 100
C:\Windows\System32\powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo - Power settings reverted.

echo.
echo [2/3] Deleting TCP Latency Registry entries...
C:\Windows\System32\reg.exe delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{C166EEE1-4904-4411-9923-5034B576A19D}" /v TcpAckFrequency /f >nul 2>&1
C:\Windows\System32\reg.exe delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{C166EEE1-4904-4411-9923-5034B576A19D}" /v TCPNoDelay /f >nul 2>&1
echo - TCP registry entries deleted.

echo.
echo [3/3] Restoring Network Throttling Index...
C:\Windows\System32\reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f >nul 2>&1
echo - Network throttling index restored.

echo.
echo =========================================================
echo All settings reverted successfully.
echo Please RESTART your computer or network adapter to apply.
echo =========================================================
pause
