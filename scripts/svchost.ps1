# OptimizedOS - Dynamic SvcHostSplitThreshold
# Sets SvcHostSplitThresholdInKB based on installed RAM
# More RAM = fewer svchost instances = lower overhead

Write-Host "=== SvcHostSplit Threshold (Dynamic) ===" -ForegroundColor Cyan

$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host "  Detected RAM: ${ramGB}GB" -ForegroundColor Gray

if ($ramGB -ge 16) {
    $thresholdKB = 8192      # 8GB threshold — fewer splits, less overhead
    $label = "8192KB (16GB+ RAM)"
} elseif ($ramGB -ge 8) {
    $thresholdKB = 4096      # 4GB threshold
    $label = "4096KB (8GB RAM)"
} elseif ($ramGB -ge 4) {
    $thresholdKB = 2048      # 2GB threshold
    $label = "2048KB (4GB RAM)"
} else {
    $thresholdKB = 1024      # 1GB threshold — more splits for low RAM
    $label = "1024KB (<4GB RAM)"
}

Write-Host "  Using: $label" -ForegroundColor Gray

$path = "HKLM:\SYSTEM\ControlSet001\Control"
try {
    Set-ItemProperty -Path $path -Name "SvcHostSplitThresholdInKB" -Value $thresholdKB -Type DWord -ErrorAction Stop
    Write-Host "  Applied successfully" -ForegroundColor Green
} catch {
    Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
}
