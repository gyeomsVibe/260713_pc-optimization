$paths = @(
    "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell",
    "Registry::HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers",
    "Registry::HKEY_CLASSES_ROOT\DesktopBackground\shell",
    "Registry::HKEY_CLASSES_ROOT\DesktopBackground\shellex\ContextMenuHandlers",
    "Registry::HKEY_CLASSES_ROOT\Directory\shell",
    "Registry::HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers",
    "Registry::HKEY_CLASSES_ROOT\*\shell",
    "Registry::HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers",
    "Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shell",
    "Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers",
    "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell",
    "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\Background\shellex\ContextMenuHandlers",
    "Registry::HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell",
    "Registry::HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shellex\ContextMenuHandlers",
    "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell",
    "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shellex\ContextMenuHandlers",
    "Registry::HKEY_CURRENT_USER\Software\Classes\*\shell",
    "Registry::HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers",
    "Registry::HKEY_CURRENT_USER\Software\Classes\AllFilesystemObjects\shell",
    "Registry::HKEY_CURRENT_USER\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\Background\shell",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\DesktopBackground\shell",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\DesktopBackground\shellex\ContextMenuHandlers",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shell",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shell",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AllFilesystemObjects\shell",
    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers"
)

$outFile = "d:\D_Workspace_NB\-google-workspace\-antigravity-workspace\260713_pc-optimization\notebook\scratch\all_menus.txt"
if (Test-Path $outFile) { Remove-Item $outFile }

foreach ($path in $paths) {
    if (Test-Path $path) {
        Add-Content $outFile "========================================="
        Add-Content $outFile "PATH: $path"
        Add-Content $outFile "========================================="
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            $keyName = $_.PSChildName
            $pspath = $_.PSPath
            $defaultVal = (Get-ItemProperty -Path $pspath -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
            Add-Content $outFile "  Key: $keyName"
            if ($defaultVal) {
                Add-Content $outFile "    Default Value: $defaultVal"
            }
            
            # Get other properties
            $props = Get-ItemProperty -Path $pspath -ErrorAction SilentlyContinue
            if ($props) {
                foreach ($prop in $props.PSObject.Properties) {
                    if ($prop.Name -notmatch "^PS" -and $prop.Name -ne "(default)") {
                        Add-Content $outFile "    $($prop.Name) : $($prop.Value)"
                    }
                }
            }
            
            # Check one level deeper for shell subcommands
            Get-ChildItem -Path $pspath -ErrorAction SilentlyContinue | ForEach-Object {
                $subKeyName = $_.PSChildName
                $subPspath = $_.PSPath
                $subDefaultVal = (Get-ItemProperty -Path $subPspath -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
                Add-Content $outFile "    SubKey: $subKeyName"
                if ($subDefaultVal) {
                    Add-Content $outFile "      Default Value: $subDefaultVal"
                }
            }
        }
        Add-Content $outFile ""
    }
}
Write-Host "Done! Results written to $outFile"
