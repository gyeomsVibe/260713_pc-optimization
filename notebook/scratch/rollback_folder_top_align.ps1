# rollback_folder_top_align.ps1
# 폴더 정렬 및 뷰 최적화 롤백 스크립트

# 1. Directory 및 Folder 표시 이름 오버라이드 삭제
$dirPath = "HKCU:\Software\Classes\Directory"
if (Test-Path $dirPath) {
    Remove-Item -Path $dirPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Directory override removed."
}
$folderPath = "HKCU:\Software\Classes\Folder"
if (Test-Path $folderPath) {
    Remove-Item -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Folder override removed."
}

# 2. 모든 기본 폴더 템플릿(FolderTypes) 설정 삭제
$folderTypesPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"
$guids = @(
    "{5c4f28b5-f869-4e84-8e60-f11db97c5cc7}",
    "{7d49d726-3c21-4f05-99aa-fdc2c9474656}",
    "{b3690e58-e961-423b-b687-357d332b2483}",
    "{94d6ddcc-4a68-4175-8022-d0566d3d2b3b}",
    "{5fa96407-7e77-483c-ac93-691d0585028e}",
    "{0b2baa59-fb09-4b84-b040-05d7be58e56b}"
)

foreach ($guid in $guids) {
    $targetPath = "$folderTypesPath\$guid"
    if (Test-Path $targetPath) {
        Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "FolderType GUID $guid settings removed."
    }
}

# 3. 폴더 뷰 캐시 초기화 (롤백 즉시 반영)
$shellPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"
if (Test-Path "$shellPath\Bags") {
    Remove-Item -Path "$shellPath\Bags" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "$shellPath\BagMRU") {
    Remove-Item -Path "$shellPath\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Windows 탐색기 재시작
Write-Host "Restarting Windows Explorer to apply rollback immediately..."
Stop-Process -Name explorer -Force
Write-Host "Folders on top and global views rollback completed successfully!"
