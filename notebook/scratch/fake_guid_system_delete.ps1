# SYSTEM 권한 예약작업으로 새 스킴 내 오타 GUID 키 삭제 (관리자에서 실행)
$log = Join-Path $PSScriptRoot 'fake_guid_system_delete.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    $key = 'HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\0482f20d-125e-4f77-82ac-8e4f1fa77b69\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017'
    $tn  = 'TempFakeGuidCleanup'
    schtasks /create /tn $tn /tr "reg delete `"$key`" /f" /sc once /st 23:59 /ru SYSTEM /f | Out-Null
    schtasks /run /tn $tn | Out-Null
    Start-Sleep -Seconds 4
    schtasks /delete /tn $tn /f | Out-Null
    $q = reg query "$key" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Output 'RESULT: SYSTEM 권한 삭제 성공'; $code = 0 }
    else { Write-Output "RESULT: 잔존"; $code = 2 }
} catch { Write-Output "FAIL: $($_.Exception.Message)"; $code = 2 }
finally { Stop-Transcript | Out-Null }
exit $code
