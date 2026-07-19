# Dragon Center / Seagate Toolkit 제거 후 찌꺼기 정리 (관리자)
$log = Join-Path $PSScriptRoot 'cleanup_leftovers.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    # 1) 죽은 시작프로그램 항목 (HKLM Run)
    foreach ($hive in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
                        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run')) {
        foreach ($name in @('Toolkit', 'Dragon Center')) {
            if (Get-ItemProperty $hive -Name $name -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $hive -Name $name -Confirm:$false
                Write-Output "시작항목 삭제: $hive\$name"
            }
        }
    }
    # 2) 죽은 서비스 등록 해제 (모두 Stopped 상태 확인됨)
    foreach ($svc in @('MSI Foundation Service', 'Sendevsvc')) {
        if (Get-Service $svc -ErrorAction SilentlyContinue) {
            sc.exe delete "$svc" | Out-Null
            Write-Output "서비스 등록 해제: $svc"
        }
    }
    # 3) 잔존 폴더 제거
    foreach ($dir in @('C:\Program Files (x86)\MSI\Dragon Center',
                       'C:\Program Files (x86)\Toolkit',
                       'C:\ProgramData\Toolkit')) {
        if (Test-Path $dir) {
            Remove-Item $dir -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
            Write-Output ("폴더 제거: {0} -> {1}" -f $dir, $(if(Test-Path $dir){'일부 잔존(사용중 파일)'}else{'완료'}))
        }
    }
    Write-Output 'SUCCESS'
    $code = 0
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    $code = 2
} finally { Stop-Transcript | Out-Null }
exit $code
