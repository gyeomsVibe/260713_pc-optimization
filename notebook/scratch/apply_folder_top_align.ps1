# apply_folder_top_align.ps1
# 폴더 정렬 최상단 배치 및 전역 폴더 뷰(유형별 분류, 이름 정렬) 기본값 강제 적용 스크립트

# 1. 기존 개별 폴더 뷰 캐시(ShellBags) 강제 초기화
Write-Host "1. 기존 폴더 뷰 설정 캐시 초기화 중..."
$shellPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"
if (Test-Path "$shellPath\Bags") {
    Remove-Item -Path "$shellPath\Bags" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "$shellPath\BagMRU") {
    Remove-Item -Path "$shellPath\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. 모든 기본 폴더 템플릿(FolderTypes)에 전역 뷰 강제 (Details, Group by Type, Sort by Name)
Write-Host "2. 전역 폴더 기본 뷰 설정 강제 주입 중..."
$folderTypesPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"

# 6대 핵심 폴더 템플릿 GUID
$guids = @(
    "{5c4f28b5-f869-4e84-8e60-f11db97c5cc7}", # 일반 항목 (Generic)
    "{7d49d726-3c21-4f05-99aa-fdc2c9474656}", # 문서 (Documents)
    "{b3690e58-e961-423b-b687-357d332b2483}", # 사진 (Pictures)
    "{94d6ddcc-4a68-4175-8022-d0566d3d2b3b}", # 음악 (Music)
    "{5fa96407-7e77-483c-ac93-691d0585028e}", # 비디오 (Videos)
    "{0b2baa59-fb09-4b84-b040-05d7be58e56b}"  # 다운로드 (Downloads)
)

foreach ($guid in $guids) {
    $targetPath = "$folderTypesPath\$guid"
    if (-not (Test-Path $targetPath)) {
        New-Item -Path $targetPath -Force | Out-Null
    }
    
    # LogicalViewMode = 1 (자세히 보기)
    New-ItemProperty -Path $targetPath -Name "LogicalViewMode" -Value 1 -PropertyType DWord -Force | Out-Null
    # GroupBy = System.ItemTypeText (유형별 분류)
    New-ItemProperty -Path $targetPath -Name "GroupBy" -Value "System.ItemTypeText" -PropertyType String -Force | Out-Null
    # GroupAscending = 1
    New-ItemProperty -Path $targetPath -Name "GroupAscending" -Value 1 -PropertyType DWord -Force | Out-Null
    # SortBy = System.ItemNameDisplay (이름순 정렬)
    New-ItemProperty -Path $targetPath -Name "SortBy" -Value "System.ItemNameDisplay" -PropertyType String -Force | Out-Null
    # SortAscending = 1
    New-ItemProperty -Path $targetPath -Name "SortAscending" -Value 1 -PropertyType DWord -Force | Out-Null
}

# 3. 사용자 요청에 따라 '#Folder' 명칭 정의 (공백 제거)
Write-Host "3. '#Folder' 명칭을 주입 중..."
# 공백이 없는 '#Folder'로 최종 최적화합니다.
$friendlyName = "#Folder"

# Directory 키 적용
$dirPath = "HKCU:\Software\Classes\Directory"
if (-not (Test-Path $dirPath)) {
    New-Item -Path $dirPath -Force | Out-Null
}
Set-Item -Path $dirPath -Value $friendlyName

# Folder 키 적용
$folderPath = "HKCU:\Software\Classes\Folder"
if (-not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -Force | Out-Null
}
Set-Item -Path $folderPath -Value $friendlyName

# 4. Windows 탐색기 재시작
Write-Host "4. Windows 탐색기를 재시작하여 설정을 적용합니다..."
Stop-Process -Name explorer -Force
Write-Host "폴더 뷰 설정 및 '#Folder' 이름 적용이 완료되었습니다!"


