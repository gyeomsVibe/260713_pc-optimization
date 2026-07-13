<#
.SYNOPSIS
    i7-9750H 발열/렉 방지 전역 최적화 스크립트 (ThrottleStop 설정 비침범)

.DESCRIPTION
    기존 '고성능' 스킴을 복제한 "Agent Optimized" 전원 스킴을 생성해 조율한다.
    원본 스킴은 절대 수정하지 않으므로 롤백은 원본 스킴 재활성화만으로 완료된다.

    조율 항목:
      - 최소 프로세서 상태  AC 100% -> 5%  (유휴 발열 제거)
      - 터보 부스트 모드    AC 2(Aggressive) -> 4(Efficient Aggressive)
                            DC 2(Aggressive) -> 3(Efficient Enabled)
      - 시스템 냉각 정책    AC 1(Active) 명시
      - 페이지파일          자동 관리 -> C: 고정 8192MB (관리자 권한 필요, 없으면 건너뜀)

.PARAMETER DryRun
    아무것도 변경하지 않고 현재값과 제안값을 비교 출력한다.

.PARAMETER Apply
    백업 생성 후 실제 적용한다.

.PARAMETER Rollback
    백업 파일 기준으로 원본 스킴을 재활성화하고 생성된 스킴을 제거한다.

.EXAMPLE
    powershell -File .\cpu_boost_optimizer.ps1 -DryRun
    powershell -File .\cpu_boost_optimizer.ps1 -Apply
    powershell -File .\cpu_boost_optimizer.ps1 -Rollback
#>
[CmdletBinding(DefaultParameterSetName = 'DryRun')]
param(
    [Parameter(ParameterSetName = 'DryRun')]  [switch]$DryRun,
    [Parameter(ParameterSetName = 'Apply')]   [switch]$Apply,
    [Parameter(ParameterSetName = 'Rollback')][switch]$Rollback
)

$ErrorActionPreference = 'Stop'

# ── 상수 정의 ─────────────────────────────────────────────
$SUB_PROCESSOR   = '54533251-82be-4824-96c1-47b60b740d00'
$PROCTHROTTLEMIN = '893dee8e-2bef-41e0-89c6-b55d0929964c'
$PERFBOOSTMODE   = 'be337238-0d82-4146-a960-4f3749d470c7'
$SYSCOOLPOL      = '94d3a615-a899-4ac5-ae2b-e4d8f634367f'
$NewSchemeName   = 'Agent Optimized'
$BackupFile      = Join-Path $PSScriptRoot 'power_backup.json'

# 제안 설정 값 (계산 근거: implementation_plan.md 2장)
$Targets = @(
    @{ Name = '최소 프로세서 상태'; Guid = $PROCTHROTTLEMIN; AC = 5; DC = 5 },
    @{ Name = '터보 부스트 모드';   Guid = $PERFBOOSTMODE;   AC = 4; DC = 3 },
    @{ Name = '시스템 냉각 정책';   Guid = $SYSCOOLPOL;      AC = 1; DC = $null }
)
$PageFileSizeMB = 8192

function Get-ActiveSchemeGuid {
    $out = powercfg /getactivescheme
    if ($out -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})') {
        return $Matches[1]
    }
    throw "활성 전원 스킴 GUID를 파싱할 수 없습니다: $out"
}

function Get-SettingValue {
    param([string]$Scheme, [string]$Setting)
    $reg = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$Scheme\$SUB_PROCESSOR\$Setting"
    if (Test-Path $reg) {
        $v = Get-ItemProperty $reg
        return @{ AC = $v.ACSettingIndex; DC = $v.DCSettingIndex; Source = '개별 설정' }
    }
    $def = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\$SUB_PROCESSOR\$Setting\DefaultPowerSchemeValues\$Scheme"
    if (Test-Path $def) {
        $v = Get-ItemProperty $def
        return @{ AC = $v.ACSettingIndex; DC = $v.DCSettingIndex; Source = '스킴 기본값' }
    }
    return @{ AC = '?'; DC = '?'; Source = '조회 불가' }
}

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ══════════════════ ROLLBACK ══════════════════
if ($Rollback) {
    if (-not (Test-Path $BackupFile)) { throw "백업 파일이 없습니다: $BackupFile" }
    $bak = Get-Content $BackupFile -Raw | ConvertFrom-Json
    Write-Host "[롤백] 원본 스킴 재활성화: $($bak.OriginalScheme)"
    powercfg /setactive $bak.OriginalScheme
    if ($LASTEXITCODE -ne 0) { throw "원본 스킴 활성화 실패 (exit $LASTEXITCODE)" }
    if ($bak.NewScheme) {
        Write-Host "[롤백] 생성했던 스킴 제거: $($bak.NewScheme)"
        powercfg /delete $bak.NewScheme 2>$null
    }
    Write-Host "[롤백] 완료. 페이지파일을 변경했었다면 시스템 속성에서 '자동 관리'로 되돌린 뒤 재부팅하십시오." -ForegroundColor Green
    exit 0
}

# ══════════════════ 현재 상태 수집 ══════════════════
$current = Get-ActiveSchemeGuid
Write-Host "현재 활성 스킴 : $current"
Write-Host ("모드           : " + ($(if ($Apply) { 'APPLY (실제 적용)' } else { 'DRY-RUN (변경 없음)' })))
Write-Host ""
Write-Host ("{0,-22} {1,-14} {2,-14} {3}" -f '항목', '현재(AC/DC)', '제안(AC/DC)', '출처')
Write-Host ('-' * 70)
foreach ($t in $Targets) {
    $cur = Get-SettingValue -Scheme $current -Setting $t.Guid
    $dcTxt = if ($null -eq $t.DC) { '유지' } else { $t.DC }
    Write-Host ("{0,-22} {1,-14} {2,-14} {3}" -f $t.Name, "$($cur.AC)/$($cur.DC)", "$($t.AC)/$dcTxt", $cur.Source)
}
Write-Host ""

$isAdmin = Test-IsAdmin
$pf = Get-CimInstance Win32_ComputerSystem
Write-Host "페이지파일 자동관리: $($pf.AutomaticManagedPagefile)  ->  제안: C: 고정 ${PageFileSizeMB}MB (관리자 권한: $isAdmin)"
Write-Host ""

if (-not $Apply) {
    Write-Host "[DRY-RUN] 어떤 설정도 변경되지 않았습니다. 적용하려면 -Apply 를 사용하십시오." -ForegroundColor Cyan
    exit 0
}

# ══════════════════ APPLY ══════════════════
# 재실행 가드: 이미 Agent Optimized 스킴이 활성화되어 있으면 스킴 생성을 건너뛴다
$alreadyApplied = $false
if ((Test-Path $BackupFile)) {
    $prev = Get-Content $BackupFile -Raw | ConvertFrom-Json
    if ($prev.NewScheme -and $current -eq $prev.NewScheme) {
        Write-Host "[안내] 이미 '$NewSchemeName' 스킴이 활성 상태입니다. 스킴 생성/값 입력을 건너뛰고 페이지파일 단계만 수행합니다." -ForegroundColor Yellow
        $alreadyApplied = $true
    }
}

# 1) 백업 (powercfg 전체 스킴 내보내기 + JSON 메타)
if (-not $alreadyApplied) {
Write-Host "[1/4] 백업 생성..."
$exportPath = Join-Path $PSScriptRoot "scheme_backup_$current.pow"
powercfg /export $exportPath $current | Out-Null

# 2) 스킴 복제
Write-Host "[2/4] '$NewSchemeName' 스킴 생성 (원본 복제)..."
$dupOut = powercfg /duplicatescheme $current
if ($dupOut -notmatch '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})') {
    throw "스킴 복제 실패: $dupOut"
}
$newScheme = $Matches[1]
powercfg /changename $newScheme $NewSchemeName "Agent/IDE 작업용 발열 최적화 스킴 (ThrottleStop 병행)"

@{
    OriginalScheme = $current
    NewScheme      = $newScheme
    BackupPow      = $exportPath
    Timestamp      = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
} | ConvertTo-Json | Set-Content $BackupFile -Encoding UTF8
Write-Host "        백업 저장: $BackupFile"

# 3) 값 적용
Write-Host "[3/4] 새 스킴에 최적화 값 입력..."
foreach ($t in $Targets) {
    powercfg /setacvalueindex $newScheme $SUB_PROCESSOR $t.Guid $t.AC
    if ($LASTEXITCODE -ne 0) { throw "AC 설정 실패: $($t.Name)" }
    if ($null -ne $t.DC) {
        powercfg /setdcvalueindex $newScheme $SUB_PROCESSOR $t.Guid $t.DC
        if ($LASTEXITCODE -ne 0) { throw "DC 설정 실패: $($t.Name)" }
    }
    Write-Host "        $($t.Name) -> AC $($t.AC)" -NoNewline
    if ($null -ne $t.DC) { Write-Host " / DC $($t.DC)" } else { Write-Host "" }
}
powercfg /setactive $newScheme
if ($LASTEXITCODE -ne 0) { throw "새 스킴 활성화 실패" }
Write-Host "        새 스킴 활성화 완료: $newScheme" -ForegroundColor Green
} # end if (-not $alreadyApplied)

# 4) 페이지파일 (관리자 권한이 있을 때만)
Write-Host "[4/4] 페이지파일 설정..."
if ($isAdmin) {
    $cs = Get-CimInstance Win32_ComputerSystem
    if ($cs.AutomaticManagedPagefile) {
        Set-CimInstance -InputObject $cs -Property @{ AutomaticManagedPagefile = $false }
    }
    $pfs = Get-CimInstance Win32_PageFileSetting | Where-Object Name -like 'C:*'
    if ($pfs) {
        Set-CimInstance -InputObject $pfs -Property @{ InitialSize = $PageFileSizeMB; MaximumSize = $PageFileSizeMB }
    } else {
        New-CimInstance -ClassName Win32_PageFileSetting -Property @{
            Name = 'C:\pagefile.sys'; InitialSize = $PageFileSizeMB; MaximumSize = $PageFileSizeMB
        } | Out-Null
    }
    Write-Host "        C: 고정 ${PageFileSizeMB}MB 설정 완료 — 재부팅 후 반영됩니다." -ForegroundColor Green
} else {
    Write-Host "        관리자 권한이 없어 건너뜁니다. 관리자 PowerShell에서 이 스크립트를 -Apply로 재실행하면 페이지파일만 마저 적용됩니다." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "완료. 롤백: powershell -File `"$PSCommandPath`" -Rollback" -ForegroundColor Cyan
