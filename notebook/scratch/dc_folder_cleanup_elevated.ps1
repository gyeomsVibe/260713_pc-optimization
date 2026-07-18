# Dragon Center 잔존 폴더 제거 (관리자)
$target = 'C:\Program Files (x86)\MSI\Dragon Center'
if (Test-Path $target) {
    Remove-Item $target -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
}
if (Test-Path $target) { exit 2 } else { exit 0 }
