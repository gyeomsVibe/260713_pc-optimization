[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Diagnose', 'Apply', 'Rollback')]
    [string]$Mode = 'Diagnose',

    [switch]$RestartExplorer
)

$ErrorActionPreference = 'Stop'
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$backupPath = Join-Path $PSScriptRoot 'explorer-responsiveness-backup-20260719.json'

function Get-ExplorerSettings {
    $settings = Get-ItemProperty -Path $registryPath
    [PSCustomObject]@{
        LaunchTo = $settings.LaunchTo
        SeparateProcess = $settings.SeparateProcess
        ExplorerProcessCount = @(Get-Process -Name explorer -ErrorAction SilentlyContinue).Count
    }
}

function Save-Backup {
    if (Test-Path -LiteralPath $backupPath) {
        return
    }

    $settings = Get-ItemProperty -Path $registryPath
    [PSCustomObject]@{
        CapturedAt = (Get-Date).ToString('o')
        LaunchTo = $settings.LaunchTo
        SeparateProcess = $settings.SeparateProcess
    } | ConvertTo-Json | Set-Content -LiteralPath $backupPath -Encoding utf8
}

function Restore-RegistryValue {
    param(
        [string]$Name,
        $Value
    )

    if ($null -eq $Value) {
        Remove-ItemProperty -Path $registryPath -Name $Name -ErrorAction SilentlyContinue
    }
    else {
        Set-ItemProperty -Path $registryPath -Name $Name -Type DWord -Value ([int]$Value)
    }
}

function Restart-ExplorerSafely {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 700
    Start-Process explorer.exe
}

switch ($Mode) {
    'Diagnose' {
        Get-ExplorerSettings
        break
    }

    'Apply' {
        if ($PSCmdlet.ShouldProcess('File Explorer', 'Open to This PC and use one Explorer process')) {
            Save-Backup
            Set-ItemProperty -Path $registryPath -Name LaunchTo -Type DWord -Value 2
            Set-ItemProperty -Path $registryPath -Name SeparateProcess -Type DWord -Value 0

            if ($RestartExplorer) {
                Restart-ExplorerSafely
            }

            [PSCustomObject]@{
                Result = 'Applied'
                Backup = $backupPath
                RestartedExplorer = [bool]$RestartExplorer
                Settings = Get-ExplorerSettings
            }
        }
        break
    }

    'Rollback' {
        if (-not (Test-Path -LiteralPath $backupPath)) {
            throw "Rollback backup was not found: $backupPath"
        }

        $backup = Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json
        if ($PSCmdlet.ShouldProcess('File Explorer', 'Restore backed-up responsiveness settings')) {
            Restore-RegistryValue -Name 'LaunchTo' -Value $backup.LaunchTo
            Restore-RegistryValue -Name 'SeparateProcess' -Value $backup.SeparateProcess

            if ($RestartExplorer) {
                Restart-ExplorerSafely
            }

            [PSCustomObject]@{
                Result = 'Rolled back'
                Backup = $backupPath
                RestartedExplorer = [bool]$RestartExplorer
                Settings = Get-ExplorerSettings
            }
        }
    }
}
