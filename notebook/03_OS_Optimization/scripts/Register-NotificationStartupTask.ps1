# Register-NotificationStartupTask.ps1
# 로그인 시 Windows 알림 활성화 스크립트를 자동으로 실행하도록 등록합니다.
# 현재 사용자 시작프로그램(Startup)의 무창 VBScript를 사용합니다.
# 이 PC는 현재 사용자 작업 스케줄러 생성을 거부하므로, VBScript가 30초 뒤에
# 복구 스크립트를 실행해 로그인 초기화 이후의 설정 덮어쓰기를 방지합니다.

[CmdletBinding()]
param (
    [switch]$InstallLegacyStartup
)

if (-not $InstallLegacyStartup) {
    Write-Warning "이 자동 시작 방식은 퇴역했습니다. 실제 원인은 Windows 방해 금지 자동 규칙이었습니다."
    Write-Warning "전역 알림 레지스트리 복구가 별도로 필요한 경우에만 -InstallLegacyStartup을 명시하십시오."
    exit 2
}

$scriptName = "Fix-WindowsNotifications.ps1"
$sourcePath = Join-Path $PSScriptRoot $scriptName

# 소스 파일 체크
if (-not (Test-Path $sourcePath)) {
    Write-Error "[-] 원본 스크립트를 찾을 수 없습니다: $sourcePath"
    exit 1
}

# HKCU를 올바른 로그인 사용자에게 적용하려면 ProgramData/SYSTEM이 아닌
# 현재 사용자의 AppData 아래에 실행 스크립트를 둡니다.
$targetDir = Join-Path $env:APPDATA "PC-Maintenance"
$targetPath = Join-Path $targetDir $scriptName
if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}
Copy-Item -Path $sourcePath -Destination $targetPath -Force

Write-Host "[*] 시작프로그램(Startup) 지연 실행 경로를 등록합니다..." -ForegroundColor Cyan

Write-Host "[+] 실행 스크립트를 준비했습니다: $targetPath" -ForegroundColor Green

# 시작프로그램 경로 및 VBS 파일 정의
$startupFolder = [System.Environment]::GetFolderPath('Startup')
$vbsPath = Join-Path $startupFolder "Fix-Notifications-Startup.vbs"

# 콘솔 창 없이 백그라운드로 실행하기 위한 VBScript 내용 생성
# VBScript 문자열 안의 큰따옴표는 `""`가 아니라 `""""`로 이스케이프해야 합니다.
# 경로에 공백이 있어도 PowerShell의 -File 인수가 한 값으로 유지됩니다.
$startupDelayMilliseconds = 30000
$escapedTargetPath = $targetPath.Replace('"', '""')
$vbsContent = @"
Set shell = CreateObject("WScript.Shell")
WScript.Sleep $startupDelayMilliseconds
shell.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$escapedTargetPath""", 0, False
"@

try {
    [System.IO.File]::WriteAllText($vbsPath, $vbsContent, [System.Text.Encoding]::ASCII)
    Write-Host "[+] 시작프로그램에 무창 실행 스크립트가 성공적으로 등록되었습니다." -ForegroundColor Green
    Write-Host "[+] 경로: $vbsPath" -ForegroundColor Green
} catch {
    Write-Error "[-] 시작프로그램 스크립트 생성에 실패했습니다: $_"
    exit 1
}

Write-Host "[*] 자동 등록 절차가 완료되었습니다. 다음 로그인 30초 후 알림 자동 보정이 실행됩니다." -ForegroundColor Green
