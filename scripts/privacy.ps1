# OptimizedOS - Telemetry & Privacy
# Disables Windows telemetry, tracking, and data collection
# Safe: does not break system functionality

Write-Host "=== Privacy & Telemetry ===" -ForegroundColor Cyan

# --- Disable Telemetry via Registry ---
$regPaths = @(
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 0),
    @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry", 0),
    @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "MaxTelemetryAllowed", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "ContentDeliveryAllowed", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "OemPreInstalledAppsEnabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "PreInstalledAppsEnabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338387Enabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338388Enabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353694Enabled", 0),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353696Enabled", 0),
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat", "AITEnable", 0),
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat", "DisableInventory", 1),
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat", "DisablePCA", 1),
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat", "DisableShim", 1)
)

$count = 0
foreach ($entry in $regPaths) {
    $path, $name, $value = $entry
    try {
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name $name -Value $value -Type DWord -ErrorAction Stop
        $count++
    } catch {
        Write-Host "  Failed: $path\$name" -ForegroundColor Yellow
    }
}
Write-Host "  Registry tweaks applied: $count" -ForegroundColor Gray

# --- Disable telemetry services ---
$telemetryServices = @("DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service")
foreach ($svc in $telemetryServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  Disabled service: $svc" -ForegroundColor Gray
    }
}

# --- Disable Cortana ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord
Write-Host "  Cortana & web search disabled" -ForegroundColor Gray

# --- Disable Windows Spotlight ---
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Value 1 -Type DWord

# --- Disable location tracking ---
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -Value 1 -Type DWord
Write-Host "  Location tracking disabled" -ForegroundColor Gray

# --- Disable advertising ID ---
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord

# --- Disable Feedback requests ---
New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Value 0 -Type DWord

Write-Host "`nPrivacy hardening complete ($count registry entries)" -ForegroundColor Green
