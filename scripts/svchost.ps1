# OptimizedOS - Dynamic SvcHostSplitThreshold
# Sets SvcHostSplitThresholdInKB to group svchost processes (reduce overhead)
# Formula: RAM_GB * 1024 * 1024 = threshold in KB
# Value set HIGHER than RAM = services grouped = less memory overhead

Write-Host "=== SvcHostSplit Threshold (Dynamic) ===" -ForegroundColor Cyan

$ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$ramGB = [math]::Round($ramBytes / 1GB, 1)
Write-Host "  Detected RAM: ${ramGB}GB" -ForegroundColor Gray

# Set threshold to 2x RAM — forces grouping (less overhead, less isolated svchost instances)
$thresholdKB = [math]::Round($ramGB * 1024 * 1024 * 2)

Write-Host "  Threshold: ${thresholdKB}KB (2x RAM = group services)" -ForegroundColor Gray

$path = "HKLM:\SYSTEM\CurrentControlSet\Control"
try {
    Set-ItemProperty -Path $path -Name "SvcHostSplitThresholdInKB" -Value $thresholdKB -Type DWord -ErrorAction Stop
    Write-Host "  Applied successfully" -ForegroundColor Green
} catch {
    Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
}
