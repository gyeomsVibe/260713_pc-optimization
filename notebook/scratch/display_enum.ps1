# 디스플레이 어댑터-모니터 매핑 조회 (읽기 전용)
$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class DispEnum {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
  public struct DISPLAY_DEVICE {
    public int cb;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string DeviceName;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceString;
    public int StateFlags;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceID;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceKey;
  }
  [DllImport("user32.dll")]
  public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICE lpDisplayDevice, uint dwFlags);
}
'@
for ($i = 0; $i -lt 8; $i++) {
    $d = New-Object DispEnum+DISPLAY_DEVICE
    $d.cb = [Runtime.InteropServices.Marshal]::SizeOf($d)
    if (-not [DispEnum]::EnumDisplayDevices($null, $i, [ref]$d, 0)) { continue }
    $attached = ($d.StateFlags -band 1) -ne 0
    $primary  = ($d.StateFlags -band 4) -ne 0
    $m = New-Object DispEnum+DISPLAY_DEVICE
    $m.cb = [Runtime.InteropServices.Marshal]::SizeOf($m)
    $mon = if ([DispEnum]::EnumDisplayDevices($d.DeviceName, 0, [ref]$m, 0)) { $m.DeviceID } else { '(no monitor)' }
    '{0} | adapter={1} | attached={2} | PRIMARY={3} | monitor={4}' -f $d.DeviceName, $d.DeviceString, $attached, $primary, $mon
}
