@echo off
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017" /v "Attributes" /t REG_DWORD /d 2 /f

reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\0" /ve /t REG_SZ /d "Disabled" /f >nul
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\0" /v "SettingValue" /t REG_DWORD /d 0 /f >nul

reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\1" /ve /t REG_SZ /d "Enabled" /f >nul
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\1" /v "SettingValue" /t REG_DWORD /d 1 /f >nul

reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\2" /ve /t REG_SZ /d "Aggressive" /f >nul
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\2" /v "SettingValue" /t REG_DWORD /d 2 /f >nul

reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\3" /ve /t REG_SZ /d "Efficient Aggressive" /f >nul
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\3" /v "SettingValue" /t REG_DWORD /d 3 /f >nul

reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\4" /ve /t REG_SZ /d "Efficient Aggressive at Guaranteed" /f >nul
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017\4" /v "SettingValue" /t REG_DWORD /d 4 /f >nul

powercfg /setacvalueindex d8b6868d-205e-4ab9-bbcb-14384ef0455a 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d47017 2
powercfg /setdcvalueindex d8b6868d-205e-4ab9-bbcb-14384ef0455a 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d47017 3
powercfg /setactive d8b6868d-205e-4ab9-bbcb-14384ef0455a
pause
