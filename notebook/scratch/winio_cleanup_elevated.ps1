# WinIo 드라이버 해제 및 Dragon Center 최종 잔존물 제거 (관리자)
$log = Join-Path $PSScriptRoot 'winio_cleanup.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    # WinIo 계열 드라이버 서비스 확인·중지·삭제
    foreach ($drv in @('WinIo', 'WinIo64')) {
        $svc = Get-CimInstance Win32_SystemDriver -Filter "Name='$drv'" -ErrorAction SilentlyContinue
        if ($svc) {
            Write-Output "드라이버 발견: $drv (State=$($svc.State), Path=$($svc.PathName))"
            sc.exe stop $drv 2>&1 | Out-Null
            sc.exe delete $drv 2>&1 | Out-Null
            Write-Output "드라이버 서비스 중지·삭제 시도: $drv"
        }
    }
    Start-Sleep -Seconds 2
    $target = 'C:\Program Files (x86)\MSI\Dragon Center'
    Remove-Item $target -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    if (Test-Path $target) {
        # 여전히 잠겨 있으면 재부팅 시 삭제 예약
        $file = Join-Path $target 'WinIo64.sys'
        Write-Output "잠김 지속 — 재부팅 시 삭제 예약 시도"
        $sig = 'public static class PendMove { [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true, CharSet=System.Runtime.InteropServices.CharSet.Unicode)] public static extern bool MoveFileEx(string src, string dst, int flags); }'
        Add-Type $sig
        [PendMove]::MoveFileEx($file, $null, 4) | Out-Null   # MOVEFILE_DELAY_UNTIL_REBOOT
        [PendMove]::MoveFileEx($target, $null, 4) | Out-Null
        Write-Output "재부팅 시 삭제 예약 완료"
    } else {
        Write-Output "폴더 완전 삭제 성공"
    }
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally { Stop-Transcript | Out-Null }
exit $code
