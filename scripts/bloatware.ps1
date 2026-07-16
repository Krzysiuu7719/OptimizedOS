# OptimizedOS - Bloatware Removal
# Aggressive removal with wildcards and provisioned packages

Write-Host "=== Bloatware Removal ===" -ForegroundColor Cyan

# Use wildcards to catch ALL variants
$bloatPatterns = @(
    "Microsoft.Copilot*"
    "Microsoft.Windows.Ai.Copilot*"
    "MicrosoftTeams*"
    "Microsoft.MicrosoftTeams*"
    "Microsoft.WindowsCamera*"
    "Microsoft.DevHome*"
    "Microsoft.Family*"
    "Microsoft.Xbox*"
    "Microsoft.XboxGameOverlay*"
    "Microsoft.XboxGamingOverlay*"
    "Microsoft.XboxIdentityProvider*"
    "Microsoft.XboxSpeechToTextOverlay*"
    "Microsoft.Xbox.TCUI*"
    "Microsoft.XboxApp*"
    "Microsoft.WindowsWidgets*"
    "Microsoft.Widgets*"
    "Microsoft.SkypeApp*"
    "Microsoft.People*"
    "Microsoft.WindowsCommunicationsApps*"
    "Microsoft.Bing*"
    "Microsoft.549981C3F5F10"
    "Microsoft.MicrosoftOfficeHub*"
    "Microsoft.MicrosoftSolitaireCollection*"
    "Microsoft.PowerAutomateDesktop*"
    "Microsoft.Todos*"
    "Microsoft.MicrosoftStickyNotes*"
    "Microsoft.OutlookForWindows*"
    "Microsoft.ZuneMusic*"
    "Microsoft.ZuneVideo*"
    "Microsoft.927A8DFB"
    "Clipchamp.Clipchamp*"
    "Microsoft.WindowsSoundRecorder*"
    "Microsoft.WindowsAlarms*"
    "Microsoft.GetHelp*"
    "Microsoft.Getstarted*"
    "Microsoft.MixedReality.Portal*"
    "Microsoft.WindowsFeedbackHub*"
    "Microsoft.WindowsMaps*"
    "Microsoft.PowerToys*"
    "Microsoft.Windows.Phonelink*"
    "Microsoft.WindowsMobileStore*"
    "Microsoft.Microsoft3DViewer*"
    "Microsoft.WindowsAlarms*"
    "Microsoft.WindowsTerminal*"
    "king.com.*"
    "Disney.*"
    "SpotifyAB.*"
    "BytedancePte.*"
    "Facebook.*"
    "Instagram.*"
    "ShazamEntertainmentLtd.*"
    "Flipboard.*"
    "AdobeSystemsIncorporated.*"
    "CanvaPtyLtd.*"
    "DolbyLaboratories.*"
)

$removed = 0
$failed = 0

# Remove installed packages
foreach ($pattern in $bloatPatterns) {
    $packages = Get-AppxPackage -Name $pattern -AllUsers -ErrorAction SilentlyContinue
    foreach ($pkg in $packages) {
        Write-Host "  Removing package: $($pkg.Name)" -ForegroundColor Gray
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            $removed++
        } catch {
            Write-Host "    FAILED: $($_.Exception.Message)" -ForegroundColor Yellow
            $failed++
        }
    }
}

# Remove provisioned packages (prevents reinstall on new users)
Write-Host "`n  Removing provisioned packages..." -ForegroundColor Gray
$provs = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
$provRemoved = 0
foreach ($pattern in $bloatPatterns) {
    $matches = $provs | Where-Object { $_.PackageName -like "$pattern" }
    foreach ($p in $matches) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop | Out-Null
            Write-Host "    Removed provisioned: $($p.PackageName)" -ForegroundColor Gray
            $provRemoved++
        } catch { }
    }
}
Write-Host "  Removed: $removed packages, $provRemoved provisioned, $failed failed" -ForegroundColor Green

# Remove OneDrive
Write-Host "`n  Removing OneDrive..." -ForegroundColor Gray
try {
    $onedrive = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $onedrive)) { $onedrive = "$env:SystemRoot\System32\OneDriveSetup.exe" }
    if (Test-Path $onedrive) {
        Start-Process $onedrive "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        Write-Host "  OneDrive uninstalled" -ForegroundColor Green
    }
} catch { }

# Remove Remote Desktop
Write-Host "`n  Removing Remote Desktop..." -ForegroundColor Gray
try {
    $rdp = Get-AppxPackage -Name "Microsoft.RemoteDesktop*" -AllUsers -ErrorAction SilentlyContinue
    foreach ($pkg in $rdp) {
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Write-Host "  Removed: $($pkg.Name)" -ForegroundColor Green
    }
} catch { }

# Disable Copilot via registry
Write-Host "`n  Disabling Copilot via registry..." -ForegroundColor Gray
try {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord
    Write-Host "  Copilot disabled via registry" -ForegroundColor Green
} catch { }

# Unpin from taskbar
Write-Host "`n  Unpinning taskbar..." -ForegroundColor Gray
try {
    $taskbarKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
    if (Test-Path $taskbarKey) {
        Set-ItemProperty -Path $taskbarKey -Name "Favorites" -Value ([byte[]]@()) -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $taskbarKey -Name "Favorites" -Force -ErrorAction SilentlyContinue
    }
    $advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $advKey -Name "ShowTaskViewButton" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advKey -Name "TaskbarMn" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $advKey -Name "TaskbarDa" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "  Taskbar cleaned" -ForegroundColor Green
} catch { }

# Unpin from Start Menu
Write-Host "`n  Cleaning Start Menu..." -ForegroundColor Gray
try {
    # Clear CloudStore tile data
    $cloudBase = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current"
    $tiles = Get-ChildItem $cloudBase -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like "*tilecollection*" }
    foreach ($t in $tiles) {
        Remove-Item -Path $t.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Set empty start layout
    $startLayout = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <DefaultLayoutOverride LayoutType="StartTile">
    <StartLayoutCollection>
      <defaultlayout:StartLayoutGroupAdapter>
      </defaultlayout:StartLayoutGroupAdapter>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
    $layoutFile = "$env:TEMP\start_layout.xml"
    $startLayout | Out-File -FilePath $layoutFile -Encoding UTF8 -Force
    Import-StartLayout -LayoutPath $layoutFile -MountPath "C:\" -ErrorAction SilentlyContinue
    Remove-Item $layoutFile -Force -ErrorAction SilentlyContinue
    Write-Host "  Start Menu cleaned" -ForegroundColor Green
} catch {
    Write-Host "  Start Menu partial cleanup" -ForegroundColor Yellow
}

Write-Host "`nTotal: $removed removed, $failed failed, $provRemoved provisioned" -ForegroundColor Green
