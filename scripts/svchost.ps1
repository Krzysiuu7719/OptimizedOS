# OptimizedOS - Dynamic svchost Stack Commit
# Calculates MinimumStackCommitInBytes based on installed RAM
# 8GB+ = 32KB (aggressive), 4GB = 64KB (balanced), <4GB = 128KB (safe)

Write-Host "=== svchost Stack Commit (Dynamic) ===" -ForegroundColor Cyan

$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host "  Detected RAM: ${ramGB}GB" -ForegroundColor Gray

if ($ramGB -ge 8) {
    $commitBytes = 0x8000   # 32KB - aggressive
    $label = "aggressive (32KB)"
} elseif ($ramGB -ge 4) {
    $commitBytes = 0x10000  # 64KB - balanced
    $label = "balanced (64KB)"
} else {
    $commitBytes = 0x30000  # 128KB - safe
    $label = "safe (128KB)"
}

Write-Host "  Using: $label" -ForegroundColor Gray

$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe"
$perfPath = "$path\PerfOptions"

try {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "MinimumStackCommitInBytes" -Value $commitBytes -Type DWord -ErrorAction Stop

    if (!(Test-Path $perfPath)) { New-Item -Path $perfPath -Force | Out-Null }
    Set-ItemProperty -Path $perfPath -Name "CpuPriorityClass" -Value 1 -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $perfPath -Name "IoPriority" -Value 0 -Type DWord -ErrorAction Stop

    Write-Host "  Applied successfully" -ForegroundColor Green
} catch {
    Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
}
