# DISPLAY4 하위 모니터 전체 열거 (읽기 전용)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct DISPLAY_DEVICEW2 {
    public uint cb;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string DeviceName;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceString;
    public uint StateFlags;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceID;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceKey;
}
public static class DispMon {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "EnumDisplayDevicesW")]
    public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICEW2 dd, uint dwFlags);
}
'@
for ($m = 0u; $m -lt 4u; $m++) {
    $d = New-Object DISPLAY_DEVICEW2
    $d.cb = [uint32][Runtime.InteropServices.Marshal]::SizeOf([type][DISPLAY_DEVICEW2])
    if (-not [DispMon]::EnumDisplayDevices('\\.\DISPLAY4', $m, [ref]$d, 0)) { break }
    $active = ($d.StateFlags -band 0x1) -ne 0
    Write-Output ("모니터[{0}]: {1}  Active={2}" -f $m, $d.DeviceID, $active)
}
