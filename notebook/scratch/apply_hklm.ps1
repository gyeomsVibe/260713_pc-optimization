# apply_hklm.ps1
# 통합 레지스트리 수정 및 복구 스크립트

Write-Host "1. 잘못 생성했던 CLSID 삭제 중..."
Start-Process reg.exe -ArgumentList 'delete "HKLM\SOFTWARE\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}" /f' -Verb RunAs -Wait
Start-Process reg.exe -ArgumentList 'delete "HKCU\Software\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}" /f' -Verb RunAs -Wait

Write-Host "2. Bing Wallpaper 우클릭 메뉴 차단 중..."
Start-Process reg.exe -ArgumentList 'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{15589FA6-768B-4826-97B8-D12DE265B3BB}" /t REG_SZ /d "Bing Wallpaper Desktop Context Menu" /f' -Verb RunAs -Wait

Write-Host "3. 새로 만들기 메뉴에 올바른 CLSID 등록 중..."
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f' -Verb RunAs -Wait
Start-Process reg.exe -ArgumentList 'add "HKCU\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\New" /ve /t REG_SZ /d "{D969A300-E7FF-11d0-A93B-00A0C90F2719}" /f' -Verb RunAs -Wait

Write-Host "4. Windows 탐색기 재시작 중..."
Stop-Process -Name explorer -Force

Write-Host "모든 최적화 복구 적용 완료!"
