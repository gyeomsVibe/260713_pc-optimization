# 페이지파일 고정 전용 (관리자 권한 실행)
$log = Join-Path $PSScriptRoot 'pagefile_apply.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) { throw '관리자 권한 아님' }

    $sizeMB = 8192
    $cs = Get-CimInstance Win32_ComputerSystem
    Write-Output "자동관리(변경 전): $($cs.AutomaticManagedPagefile)"
    if ($cs.AutomaticManagedPagefile) {
        Set-CimInstance -InputObject $cs -Property @{ AutomaticManagedPagefile = $false }
        Write-Output '자동관리 해제 완료'
    }
    $pfs = Get-CimInstance Win32_PageFileSetting | Where-Object Name -like 'C:*'
    if ($pfs) {
        Set-CimInstance -InputObject $pfs -Property @{ InitialSize = $sizeMB; MaximumSize = $sizeMB }
    } else {
        New-CimInstance -ClassName Win32_PageFileSetting -Property @{
            Name = 'C:\pagefile.sys'; InitialSize = $sizeMB; MaximumSize = $sizeMB } | Out-Null
    }
    $chk = Get-CimInstance Win32_PageFileSetting | Where-Object Name -like 'C:*'
    Write-Output "적용 결과: $($chk.Name) Initial=$($chk.InitialSize)MB Max=$($chk.MaximumSize)MB"
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally {
    Stop-Transcript | Out-Null
}
exit $code
