# OptimizedOS - Bloatware Removal
# Removes preinstalled Windows apps, Teams, Copilot, Remote Desktop, etc.

Write-Host "=== Bloatware Removal ===" -ForegroundColor Cyan

$bloatware = @(
    # AI / Copilot
    "Microsoft.Copilot"
    "Microsoft.Windows.Ai.Copilot.Provider"
    "Microsoft.Copilot_8wekyb3d8bbwe"
    # Teams
    "MicrosoftTeams"
    "Microsoft.MicrosoftTeams"
    # Communication
    "Microsoft.SkypeApp"
    "Microsoft.People"
    "Microsoft.WindowsCommunicationsApps"
    # Bing
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.BingFinance"
    "Microsoft.BingSports"
    "Microsoft.BingSearch"
    "Microsoft.549981C3F5F10"
    # Office / Productivity
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Todos"
    "Microsoft.MicrosoftStickyNotes"
    # Media
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.927A8DFB"
    "Clipchamp.Clipchamp"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.WindowsAlarms"
    # System / Misc
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.MixedReality.Portal"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.PowerToys"
    "Microsoft.WindowsTerminal"
    "Microsoft.WindowsNotepad"
    # Games
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "Disney.*"
    # Social / Third-party
    "SpotifyAB.SpotifyMusic"
    "BytedancePte.Ltd.TikTok"
    "Facebook.*"
    "Instagram.*"
    "ShazamEntertainmentLtd.Shazam"
    "Flipboard.Flipboard"
    "AdobeSystemsIncorporated.AdobeCreativeCloudExpress"
    "CanvaPtyLtd.Canva"
    "DolbyLaboratories.DolbyAccess"
)

$removed = 0
$failed = 0

foreach ($app in $bloatware) {
    $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
    foreach ($pkg in $packages) {
        Write-Host "  Removing: $($pkg.Name)" -ForegroundColor Gray
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            $removed++
        } catch {
            Write-Host "  Failed: $($pkg.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
            $failed++
        }
    }

    $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "$app*" }
    foreach ($p in $prov) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop
        } catch { }
    }
}

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

# Remove Remote Desktop AppX
Write-Host "`n  Removing Remote Desktop..." -ForegroundColor Gray
try {
    $rdp = Get-AppxPackage -Name "Microsoft.RemoteDesktop*" -AllUsers -ErrorAction SilentlyContinue
    foreach ($pkg in $rdp) {
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Write-Host "  Removed: $($pkg.Name)" -ForegroundColor Green
    }
} catch { }

# Disable Copilot via registry (even if app was already removed)
Write-Host "`n  Disabling Copilot via registry..." -ForegroundColor Gray
try {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord
    Write-Host "  Copilot disabled via registry" -ForegroundColor Green
} catch { }

# Unpin everything from taskbar except Explorer
Write-Host "`n  Unpinning taskbar..." -ForegroundColor Gray
try {
    $taskbarKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
    if (Test-Path $taskbarKey) {
        Remove-ItemProperty -Path $taskbarKey -Name "Favorites" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $taskbarKey -Name "FavoritesResolve" -Force -ErrorAction SilentlyContinue
    }
    # Clear pinned taskbar items via layout modification
    $layoutPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $layoutPath -Name "ShowTaskViewButton" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $layoutPath -Name "TaskbarMn" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "  Taskbar cleaned" -ForegroundColor Green
} catch { }

# Unpin everything from Start Menu
Write-Host "`n  Cleaning Start Menu..." -ForegroundColor Gray
try {
    $startLayout = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileSmallRowCount="1" StartTileMediumRowCount="2" StartTileLargeRowCount="2" />
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

    # Also clear user pinned tiles
    $startMenuKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.tilecollection.tilecollection"
    if (Test-Path $startMenuKey) {
        Remove-Item -Path $startMenuKey -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "  Start Menu cleaned" -ForegroundColor Green
} catch {
    Write-Host "  Start Menu cleanup partial" -ForegroundColor Yellow
}

Write-Host "`nRemoved: $removed, Failed: $failed" -ForegroundColor Green
