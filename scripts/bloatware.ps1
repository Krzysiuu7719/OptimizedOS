# OptimizedOS - Bloatware Removal
# Removes preinstalled Windows apps, Teams, Copilot, Xbox, Widgets, etc.

Write-Host "=== Bloatware Removal ===" -ForegroundColor Cyan

$bloatware = @(
    # Copilot / AI
    "Microsoft.Copilot"
    "Microsoft.Windows.Ai.Copilot.Provider"
    "Microsoft.Copilot_8wekyb3d8bbwe"
    # Teams
    "MicrosoftTeams"
    "Microsoft.MicrosoftTeams"
    "Microsoft.MicrosoftTeams_8wekyb3d8bbwe"
    "Microsoft.StickyNotes"
    # Camera
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsCamera_8wekyb3d8bbwe"
    # Dev Home
    "Microsoft.WindowsTerminal" # Dev Home often pulls this
    "Microsoft.DevHome"
    "Microsoft.DevHome_8wekyb3d8bbwe"
    # Family
    "Microsoft.MicrosoftFamily"
    "Microsoft.Family"
    "MicrosoftCorporationII.QuickAssist"
    # Game Bar / Game Speech / Game Window
    "Microsoft.XboxGamingOverlay"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.Xbox.TCUI_8wekyb3d8bbwe"
    # Xbox full suite
    "Microsoft.XboxApp_8wekyb3d8bbwe"
    "Microsoft.XboxGameOverlay_8wekyb3d8bbwe"
    "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe"
    "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe"
    "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe"
    # Widgets
    "Microsoft.WindowsWidgets"
    "Microsoft.WindowsWidgets_8wekyb3d8bbwe"
    "Microsoft.Widgets"
    # Communication
    "Microsoft.SkypeApp"
    "Microsoft.SkypeApp_8wekyb3d8bbwe"
    "Microsoft.People"
    "Microsoft.WindowsCommunicationsApps"
    # Bing
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.BingFinance"
    "Microsoft.BingSports"
    "Microsoft.BingSearch"
    "Microsoft.Bing_8wekyb3d8bbwe"
    "Microsoft.549981C3F5F10"
    # Office / Productivity
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Todos"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.OutlookForWindows"
    "Microsoft.OutlookForWindows_8wekyb3d8bbwe"
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
    "Microsoft.Windows.Phonelink"
    "Microsoft.Windows.Phonelink_8wekyb3d8bbwe"
    "Microsoft.WindowsMobileStore"
    "Microsoft.WindowsMobileStore_8wekyb3d8bbwe"
    # Microsoft Store (keep if you want it, uncomment to remove)
    # "Microsoft.WindowsStore"
    # "Microsoft.WindowsStore_8wekyb3d8bbwe"
    # Games / Third-party
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "Disney.*"
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
        Set-ItemProperty -Path $taskbarKey -Name "Favorites" -Value ([byte[]](0)) -Force -ErrorAction SilentlyContinue
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "  Taskbar cleaned" -ForegroundColor Green
} catch { }

# Unpin everything from Start Menu
Write-Host "`n  Cleaning Start Menu..." -ForegroundColor Gray
try {
    # Clear user pinned tiles
    $startMenuKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current"
    $tilePath = "$startMenuKey\default$windows.data.tilecollection.tilecollection"
    if (Test-Path $tilePath) {
        Remove-Item -Path $tilePath -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Remove all user pinned items from Start Layout
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

    # Also force clear via Registry CloudStore
    $cloudStorePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default`$windows.data.start.tilecollection`$windows.data.start.tilecollection"
    if (Test-Path $cloudStorePath) {
        Remove-Item -Path $cloudStorePath -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "  Start Menu cleaned" -ForegroundColor Green
} catch {
    Write-Host "  Start Menu cleanup partial" -ForegroundColor Yellow
}

Write-Host "`nRemoved: $removed, Failed: $failed" -ForegroundColor Green
