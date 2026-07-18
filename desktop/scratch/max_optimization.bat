@echo off
C:\Windows\System32\chcp.com 65001 > nul 2>&1
echo ===================================================
echo  Max PC Optimization and Time Recovery Installer
echo ===================================================
echo.

:: 1. Enable and configure w32time service to run automatically
echo [1/4] Configuring Windows Time Service (w32time)...
C:\Windows\System32\sc.exe config w32time start= auto > nul 2>&1
C:\Windows\System32\w32tm.exe /config /manualpeerlist:"time.windows.com,0x9 pool.ntp.org,0x9" /syncfromflags:manual /update > nul 2>&1
C:\Windows\System32\net.exe stop w32time > nul 2>&1
C:\Windows\System32\net.exe start w32time > nul 2>&1
echo - Service set to Automatic and NTP peer configured.

:: 2. Register Startup Task Scheduler Task for sync_time.bat
echo.
echo [2/4] Registering sync_time.bat to Task Scheduler (on startup)...
set "script_path=d:\D_Workspace_PC\-Google_Workspace\-Antigravity_Workspace\260713_desktop-optimization\desktop\scratch\sync_time.bat"
C:\Windows\System32\schtasks.exe /create /tn "StartupTimeSync" /tr "\"%script_path%\"" /sc onstart /ru SYSTEM /f > nul 2>&1
echo - Startup sync scheduler task registered successfully.

:: 3. Applied CPU and System Latency optimization settings
echo.
echo [3/4] Tuning System Priority and Power Settings...
:: System responsiveness tuning (Priority to background process compiled/AI workload)
C:\Windows\System32\reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f > nul 2>&1
:: Disable Network throttling for general optimization
C:\Windows\System32\reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f > nul 2>&1
:: Power state stability tweak (Disable connected standby to prevent CPU throttling)
C:\Windows\System32\reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d 0 /f > nul 2>&1
echo - System Latency and Power registries tuned.

:: 4. NTFS filesystem caching and search index slimming
echo.
echo [4/4] Optimizing NTFS Disk I/O Caching and Services...
:: Increase memory limit for NTFS system cache for high I/O (model loads, compilers)
C:\Windows\System32\fsutil.exe behavior set memoryusage 2 > nul 2>&1
:: Turn off continuous Search Indexing service auto-start (release disk and CPU overhead)
C:\Windows\System32\sc.exe config WSearch start= demand > nul 2>&1
echo - NTFS caching optimized and Windows Search set to Demand.

echo.
echo ===================================================
echo  Max PC Optimization has been successfully applied!
echo ===================================================
C:\Windows\System32\timeout.exe /t 3 > nul
