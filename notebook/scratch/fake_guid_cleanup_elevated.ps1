# 오타 GUID(be337238-...-4f3749d47017) 무효 키 제거 (관리자)
# 실제 PERFBOOSTMODE는 ...470c7 이며 AC=2/DC=3으로 이미 정상 — 본 스크립트는 건드리지 않음
$log = Join-Path $PSScriptRoot 'fake_guid_cleanup.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    $s   = 'd8b6868d-205e-4ab9-bbcb-14384ef0455a'
    $sub = '54533251-82be-4824-96c1-47b60b740d00'
    $FAKE = 'be337238-0d82-4146-a960-4f3749d47017'
    $targets = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$s\$sub\$FAKE",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\$sub\$FAKE"
    )
    foreach ($t in $targets) {
        if (Test-Path $t) {
            Remove-Item $t -Recurse -Force -Confirm:$false
            Write-Output ("제거: {0} -> {1}" -f $t, $(if(Test-Path $t){'실패'}else{'완료'}))
        } else { Write-Output "이미 없음: $t" }
    }
    # 실제 설정 무결성 재확인
    $REAL = 'be337238-0d82-4146-a960-4f3749d470c7'
    $v = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$s\$sub\$REAL"
    Write-Output "실제 설정 무결성: AC=$($v.ACSettingIndex) DC=$($v.DCSettingIndex) (기대: AC=2 DC=3)"
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally { Stop-Transcript | Out-Null }
exit $code
