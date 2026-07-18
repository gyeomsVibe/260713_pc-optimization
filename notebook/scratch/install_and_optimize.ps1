# Antigravity 2.0 격리 설치 및 사용자 폴더 최적화 정리 스크립트
# install_and_optimize.ps1

$LogPath = "d:\D_Workspace_NB\-google-workspace\-antigravity-workspace\260713_pc-optimization\notebook\scratch\install_and_optimize.log"
Start-Transcript -Path $LogPath -Append

Write-Host "=================================================="
Write-Host " 작업 시작 시간: $(Get-Date)"
Write-Host "=================================================="

# 1. 디스크 사용량 사전 측정
Write-Host "[1/5] 디스크 사전 상태 측정 중..."
$InitialFreeSpace = (Get-PSDrive C).Free
Write-Host "C드라이브 초기 여유 공간: $([Math]::Round($InitialFreeSpace / 1GB, 2)) GB"

# 2. Antigravity 2.0 격리 설치
Write-Host "[2/5] Antigravity 2.0 격리 설치(Portable 추출) 진행 중..."
$TargetInstallDir = "C:\Users\Kimyoongyeom\AppData\Local\Programs\Antigravity2.0"
$SourceInstaller = "d:\D_Workspace_NB\-google-workspace\-antigravity-workspace\260713_pc-optimization\notebook\scratch\Antigravity-x64.exe"

if (-not (Test-Path $TargetInstallDir)) {
    New-Item -ItemType Directory -Force -Path $TargetInstallDir | Out-Null
    Write-Host "설치 폴더 생성 완료: $TargetInstallDir"
}

if (Test-Path $SourceInstaller) {
    Write-Host "바이너리 추출 중 (tar -xf)..."
    tar -xf $SourceInstaller -C $TargetInstallDir
    Write-Host "바이너리 추출 완료."
    
    # 바로가기 생성
    Write-Host "시작 메뉴 바로가기 생성 중..."
    $WshShell = New-Object -ComObject WScript.Shell
    $ShortcutPath = "C:\Users\Kimyoongyeom\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Antigravity 2.0.lnk"
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "$TargetInstallDir\Antigravity.exe"
    $Shortcut.WorkingDirectory = $TargetInstallDir
    $Shortcut.Description = "Antigravity 2.0 Standalone Agent Command Center"
    $Shortcut.Save()
    Write-Host "바로가기 생성 완료: $ShortcutPath"
} else {
    Write-Warning "원본 설치 파일($SourceInstaller)을 찾을 수 없습니다. 설치 단계를 건너뜁니다."
}

# 3. 레거시 백업 폴더 안전 삭제
Write-Host "[3/5] 사용자 폴더 내 불필요 레거시 백업 폴더 정리 중..."
$DeleteFolders = @(
    "C:\Users\Kimyoongyeom\.antigravity-ide_backup",
    "C:\Users\Kimyoongyeom\AppData\Roaming\Antigravity.bak",
    "C:\Users\Kimyoongyeom\AppData\Roaming\Antigravity IDE_backup",
    "C:\Users\Kimyoongyeom\.aevum_pipernet"
)

foreach ($folder in $DeleteFolders) {
    if (Test-Path $folder) {
        Write-Host "삭제 중: $folder"
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $folder)) {
            Write-Host "성공적으로 삭제됨: $folder"
        } else {
            Write-Warning "일부 파일이 사용 중이거나 권한 문제로 삭제되지 못했습니다: $folder"
        }
    } else {
        Write-Host "폴더가 존재하지 않음 (건너뜀): $folder"
    }
}

# 4. AppData\Local\Temp 폴더 안전 정리
Write-Host "[4/5] AppData\Local\Temp 임시 폴더 청소 중..."
$TempPath = "C:\Users\Kimyoongyeom\AppData\Local\Temp"
if (Test-Path $TempPath) {
    $TempItems = Get-ChildItem -Path $TempPath -ErrorAction SilentlyContinue
    $SuccessCount = 0
    $FailCount = 0
    
    foreach ($item in $TempItems) {
        try {
            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
            $SuccessCount++
        } catch {
            # 사용 중인 파일/폴더는 안전하게 건너뜀
            $FailCount++
        }
    }
    Write-Host "임시 파일 정리 완료 (성공: $SuccessCount 건, 사용 중 건너뜀: $FailCount 건)"
}

# 5. 임시 다운로드 파일 정리
Write-Host "[5/5] 임시 다운로드 설치 원본 정리 중..."
$TempDownloads = @(
    "d:\D_Workspace_NB\-google-workspace\-antigravity-workspace\260713_pc-optimization\notebook\scratch\Antigravity-x64.exe",
    "d:\D_Workspace_NB\-google-workspace\-antigravity-workspace\260713_pc-optimization\notebook\scratch\Antigravity-IDE-Installer.exe"
)
foreach ($file in $TempDownloads) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
        Write-Host "임시 다운로드 파일 제거 완료: $(Split-Path $file -Leaf)"
    }
}

# 6. 디스크 사용량 사후 측정 및 결과 보고
$FinalFreeSpace = (Get-PSDrive C).Free
$SavedSpace = $FinalFreeSpace - $InitialFreeSpace
Write-Host "=================================================="
Write-Host " 작업 완료 시간: $(Get-Date)"
Write-Host " C드라이브 최종 여유 공간: $([Math]::Round($FinalFreeSpace / 1GB, 2)) GB"
Write-Host " 이번 작업으로 확보된 공간: $([Math]::Round($SavedSpace / 1MB, 2)) MB ($([Math]::Round($SavedSpace / 1GB, 2)) GB)"
Write-Host "=================================================="

Stop-Transcript
