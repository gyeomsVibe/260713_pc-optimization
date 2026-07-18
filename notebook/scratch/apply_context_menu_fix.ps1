# apply_context_menu_fix.ps1
# 바탕화면 우클릭 메뉴 최적화 적용 스크립트 (관리자 권한 필수)

# 1. 관리자 권한 자동 상승 체크
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "관리자 권한이 필요합니다. 권한 상승 창(UAC)에서 승인해 주세요..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "관리자 권한이 확인되었습니다. 레지스트리 수정을 시작합니다..."

# 2. Bing Wallpaper 우클릭 메뉴 차단 (HKLM/HKCU 공통 적용)
# 현재 사용자에 대해서도 차단이 들어가도록 HKCU에 차단 레지스트리를 유지합니다.
$blockedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
if (-not (Test-Path $blockedPath)) {
    New-Item -Path $blockedPath -Force | Out-Null
}
New-ItemProperty -Path $blockedPath -Name "{15589FA6-768B-4826-97B8-D12DE265B3BB}" -Value "Bing Wallpaper Desktop Context Menu" -PropertyType String -Force | Out-Null
Write-Host "Bing Wallpaper shell extension ({15589FA6-768B-4826-97B8-D12DE265B3BB}) blocked."

# 2. 잘못 생성한 이전 CLSID 키 제거 (HKCU)
$oldClsidPath = "HKCU:\Software\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}"
if (Test-Path $oldClsidPath) {
    Remove-Item -Path $oldClsidPath -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. '새로 만들기(New)' 메뉴 핸들러 복구 (HKCU 및 HKLM 배치 호출)
$newMenuPath = "HKCU:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\New"
if (-not (Test-Path $newMenuPath)) {
    New-Item -Path $newMenuPath -Force | Out-Null
}
Set-Item -Path $newMenuPath -Value "{D969A300-E7FF-11d0-A93B-00A0C90F2719}"
Write-Host "'New' context menu handler restored under HKCU."

# HKLM 반영용 배치 파일 호출
$batPath = Join-Path (Split-Path $PSCommandPath) "apply_hklm.bat"
if (Test-Path $batPath) {
    Start-Process cmd.exe -ArgumentList "/c `"$batPath`"" -Wait
    Write-Host "HKLM context menu settings updated."
}


# 5. Windows 탐색기 재시작
Write-Host "Windows 탐색기를 재시작하여 변경 사항을 바로 적용합니다..."
Stop-Process -Name explorer -Force
Write-Host "바탕화면 우클릭 최적화가 안전하게 완료되었습니다!"


