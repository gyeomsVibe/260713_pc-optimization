# Test-NotificationStartupVbs.ps1
# 시작프로그램 VBScript의 큰따옴표 이스케이프가 Windows Script Host에서
# 실제로 파싱되는지, 시스템 설정을 변경하지 않는 명령으로 검증합니다.

[CmdletBinding()]
param()

$testPath = Join-Path ([System.IO.Path]::GetTempPath()) ("Test-NotificationStartupVbs-{0}.vbs" -f [guid]::NewGuid())
$targetPath = 'C:\Program Files\PC-Maintenance\Fix-WindowsNotifications.ps1'
$escapedTargetPath = $targetPath.Replace('"', '""')
$vbsContent = @"
Set shell = CreateObject("WScript.Shell")
shell.Run "cmd.exe /c exit 0 ""$escapedTargetPath""", 0, True
"@

try {
    [System.IO.File]::WriteAllText($testPath, $vbsContent, [System.Text.Encoding]::ASCII)
    & cscript.exe //nologo $testPath
    if ($LASTEXITCODE -ne 0) {
        throw "Windows Script Host returned exit code $LASTEXITCODE."
    }

    Write-Host '[PASS] Startup VBScript quoted-path syntax parsed successfully.' -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $testPath) {
        Remove-Item -LiteralPath $testPath -Force
    }
}
