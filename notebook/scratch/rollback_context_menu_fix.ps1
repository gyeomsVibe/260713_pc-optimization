# rollback_context_menu_fix.ps1
# 바탕화면 우클릭 메뉴 최적화 롤백 스크립트 (관리자 권한 필수)

# 1. 관리자 권한 자동 상승 체크
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "관리자 권한이 필요합니다. 권한 상승 창(UAC)에서 승인해 주세요..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "관리자 권한이 확인되었습니다. 롤백을 시작합니다..."

# 2. Bing Wallpaper 우클릭 메뉴 차단 해제
$blockedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
if (Test-Path $blockedPath) {
    Remove-ItemProperty -Path $blockedPath -Name "{15589FA6-768B-4826-97B8-D12DE265B3BB}" -ErrorAction SilentlyContinue
    Write-Host "Bing Wallpaper shell extension unblocked."
}

# 2. 잘못 생성했던 이전 CLSID 키 제거 (HKLM 및 HKCU)
$oldClsidHKCU = "HKCU:\Software\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}"
if (Test-Path $oldClsidHKCU) {
    Remove-Item -Path $oldClsidHKCU -Recurse -Force -ErrorAction SilentlyContinue
}
$oldClsidHKLM = "HKLM:\SOFTWARE\Classes\CLSID\{D67D100C-CC88-11D0-BE25-00C04FC8F20C}"
if (Test-Path $oldClsidHKLM) {
    Remove-Item -Path $oldClsidHKLM -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. '새로 만들기(New)' 메뉴 롤백 (추가된 New 키 제거)
$newMenuHKCU = "HKCU:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\New"
if (Test-Path $newMenuHKCU) {
    Remove-Item -Path $newMenuHKCU -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "'New' context menu handler HKCU rollback applied."
}

$newMenuHKLM = "HKLM:\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\New"
if (Test-Path $newMenuHKLM) {
    Remove-Item -Path $newMenuHKLM -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "'New' context menu handler HKLM rollback applied."
}


# 4. Windows 탐색기 재시작
Write-Host "Windows 탐색기를 재시작하여 변경 사항을 바로 적용합니다..."
Stop-Process -Name explorer -Force
Write-Host "Rollback applied successfully!"

