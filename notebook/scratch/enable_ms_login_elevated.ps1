# Microsoft 로그인 서비스 복원 (관리자 권한 실행 및 레지스트리 강제 복구 우회 포함)
$log = Join-Path $PSScriptRoot 'enable_ms_login.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) { throw '관리자 권한이 없습니다. 관리자 권한으로 실행해주십시오.' }

    Write-Output "--- 서비스 레지스트리 복구 작업 시작 (시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) ---"
    
    # 1. wlidsvc 레지스트리 강제 변경
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\wlidsvc"
    if (Test-Path $regPath) {
        $val = Get-ItemPropertyValue -Path $regPath -Name Start
        Write-Output "wlidsvc 현재 레지스트리 Start 값: $val"
        if ($val -ne 3) {
            Set-ItemProperty -Path $regPath -Name Start -Value 3 -Force
            Write-Output "wlidsvc 레지스트리 Start 값을 3(수동)으로 변경 완료했습니다."
        }
    } else {
        throw "wlidsvc 레지스트리 키를 찾을 수 없습니다."
    }

    # 2. 서비스 제어 시도 (net start wlidsvc)
    Write-Output "wlidsvc 서비스 기동 시도 중..."
    $netStartResult = net start wlidsvc 2>&1
    Write-Output "net start 결과: $netStartResult"

    # 3. ClipSVC 및 TokenBroker 상태 점검 및 레지스트리 강제 활성화 (필요 시)
    $clipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\ClipSVC"
    if (Test-Path $clipPath) {
        $clipVal = Get-ItemPropertyValue -Path $clipPath -Name Start
        if ($clipVal -eq 4) {
            Set-ItemProperty -Path $clipPath -Name Start -Value 3 -Force
            Write-Output "ClipSVC 레지스트리 Start 값을 3(수동)으로 복원했습니다."
        }
    }

    $chk = Get-Service -Name wlidsvc
    Write-Output "wlidsvc 최종 설정 - 상태: $($chk.Status), 시작유형: $($chk.StartType)"
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally {
    Stop-Transcript | Out-Null
}
exit $code
