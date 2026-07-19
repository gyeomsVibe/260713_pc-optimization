$path = "Registry::HKEY_CLASSES_ROOT\PackagedCom\Package"
if (Test-Path $path) {
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.PSChildName
        if ($name -like "*BingWallpaper*") {
            Write-Host "Found Package: $name"
            # Get all subkeys
            Get-ChildItem -Path $_.PSPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                Write-Host "  SubKey: $($_.PSPath)"
                $props = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
                if ($props) {
                    foreach ($prop in $props.PSObject.Properties) {
                        if ($prop.Name -notmatch "^PS") {
                            Write-Host "    $($prop.Name) : $($prop.Value)"
                        }
                    }
                }
            }
        }
    }
} else {
    Write-Host "PackagedCom Package path not found."
}



