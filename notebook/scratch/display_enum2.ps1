# 디스플레이 열거 v2 — Unicode 명시 (읽기 전용)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct DISPLAY_DEVICEW {
    public uint cb;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string DeviceName;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceString;
    public uint StateFlags;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceID;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string DeviceKey;
}
public static class DispEnum2 {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "EnumDisplayDevicesW")]
    public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICEW dd, uint dwFlags);
}
'@
Write-Output "== 어댑터 열거 =="
for ($i = 0u; $i -lt 8u; $i++) {
    $d = New-Object DISPLAY_DEVICEW
    $d.cb = [uint32][Runtime.InteropServices.Marshal]::SizeOf([type][DISPLAY_DEVICEW])
    $ok = [DispEnum2]::EnumDisplayDevices([NullString]::Value, $i, [ref]$d, 0)
    if (-not $ok) { Write-Output "i=$i : 끝"; break }
    $flags = @()
    if ($d.StateFlags -band 0x1) { $flags += 'ATTACHED' }
    if ($d.StateFlags -band 0x4) { $flags += 'PRIMARY' }
    Write-Output ("{0} | {1} | flags=[{2}]" -f $d.DeviceName, $d.DeviceString, ($flags -join ','))
    $m = New-Object DISPLAY_DEVICEW
    $m.cb = $d.cb
    if ([DispEnum2]::EnumDisplayDevices($d.DeviceName, 0, [ref]$m, 0)) {
        Write-Output ("    모니터: {0}" -f $m.DeviceID)
    }
}
