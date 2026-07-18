@echo off
title context_menu_repair

echo 1. HKLM 및 HKCU에서 잘못 생성했던 CLSID 삭제...
reg delete "HKLM\SOFTWARE\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}" /f >nul 2>nul
reg delete "HKCU\Software\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}" /f >nul 2>nul

echo 2. Bing Wallpaper 우클릭 메뉴 차단 (HKCU)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{15589FA6-768B-4826-97B8-D12DE265B3BB}" /t REG_SZ /d "Bing Wallpaper Desktop Context Menu" /f >nul

echo 3. '새로 만들기(New)' 메뉴 핸들러에 올바른 CLSID ({D969A300-E7FF-11d0-A93B-00A0C90F2719}) 등록...
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f >nul

echo 4. Windows 탐색기 재시작...
taskkill /f /im explorer.exe >nul 2>nul
start explorer.exe

echo 모든 최적화 적용 완료!
