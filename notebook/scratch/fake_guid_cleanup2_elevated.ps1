# 스킴 내부 오타 GUID 키 제거 2차 시도 — reg.exe 직접 + 실패 시 에러 노출 (관리자)
$log = Join-Path $PSScriptRoot 'fake_guid_cleanup2.log'
Start-Transcript -Path $log -Force | Out-Null
$key = 'HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\d8b6868d-205e-4ab9-bbcb-14384ef0455a\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d47017'
Write-Output "대상: $key"
$out = reg.exe delete "$key" /f 2>&1
Write-Output "reg delete 출력: $out"
$exists = reg.exe query "$key" 2>&1
if ($LASTEXITCODE -ne 0) { Write-Output 'RESULT: 제거 완료' ; $code = 0 }
else { Write-Output "RESULT: 잔존 — $exists" ; $code = 2 }
Stop-Transcript | Out-Null
exit $code
