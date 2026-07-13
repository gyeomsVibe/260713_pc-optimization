# 시스템 복원 지점 생성 전용 (관리자 권한 실행)
$log = Join-Path $PSScriptRoot 'restore_point.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description 'Before LTSC Store restoration 2026-07-13' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    $rp = Get-ComputerRestorePoint | Sort-Object CreationTime -Descending | Select-Object -First 1
    Write-Output "생성된 복원 지점: $($rp.Description) / $($rp.CreationTime)"
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally {
    Stop-Transcript | Out-Null
}
exit $code
