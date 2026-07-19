$paths = @(
    "Registry::HKEY_CLASSES_ROOT\CLSID",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID",
    "Registry::HKEY_CURRENT_USER\Software\Classes\CLSID"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            $keyName = $_.PSChildName
            $pspath = $_.PSPath
            
            # Check default value
            $defaultVal = (Get-ItemProperty -Path $pspath -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
            if ($defaultVal -like "*Bing*" -or $defaultVal -like "*Wallpaper*") {
                Write-Host "Found CLSID: $keyName | Default: $defaultVal"
            }
            
            # Check InProcServer32
            $subPath = Join-Path $pspath "InProcServer32"
            if (Test-Path $subPath) {
                $subDefault = (Get-ItemProperty -Path $subPath -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
                if ($subDefault -like "*Bing*" -or $subDefault -like "*Wallpaper*") {
                    Write-Host "Found InProcServer32: $keyName | Path: $subDefault"
                }
            }
        }
    }
}
Write-Host "Search finished."
