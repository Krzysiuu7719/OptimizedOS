# OptimizedOS - Bloatware Removal
# Removes preinstalled Windows apps that nobody needs
# Safe: only removes UWP apps, no system components

Write-Host "=== Bloatware Removal ===" -ForegroundColor Cyan

$bloatware = @(
    "Microsoft.549981C3F5F10"          # Cortana
    "Microsoft.BingNews"               # Bing News
    "Microsoft.BingWeather"            # Bing Weather
    "Microsoft.BingFinance"            # Bing Finance
    "Microsoft.BingSports"             # Bing Sports
    "Microsoft.BingSearch"             # Bing Search
    "Microsoft.GetHelp"                # Get Help
    "Microsoft.Getstarted"             # Get Started / Tips
    "Microsoft.MicrosoftOfficeHub"     # Office Hub
    "Microsoft.MicrosoftSolitaireCollection" # Solitaire
    "Microsoft.MixedReality.Portal"    # Mixed Reality
    "Microsoft.People"                 # People
    "Microsoft.PowerAutomateDesktop"   # Power Automate
    "Microsoft.SkypeApp"               # Skype
    "Microsoft.MicrosoftStickyNotes"   # Sticky Notes
    "Microsoft.Todos"                  # Microsoft To Do
    "Microsoft.WindowsAlarms"          # Alarms & Clock
    "Microsoft.WindowsCommunicationsApps" # Mail & Calendar
    "Microsoft.WindowsFeedbackHub"     # Feedback Hub
    "Microsoft.WindowsMaps"            # Maps
    "Microsoft.WindowsSoundRecorder"   # Voice Recorder
    "Microsoft.ZuneMusic"              # Groove Music
    "Microsoft.ZuneVideo"              # Movies & TV
    "Microsoft.927A8DFB"               # Clipchamp
    "Clipchamp.Clipchamp"              # Clipchamp
    "Microsoft Teams"                  # Teams (new)
    "MicrosoftTeams"                   # Teams (old)
    "Microsoft.PowerToys"              # PowerToys
    "Microsoft.WindowsTerminal"        # Terminal (can reinstall if needed)
    "Microsoft.WindowsNotepad"         # Notepad (classic still works)
    "king.com.CandyCrushSaga"          # Candy Crush
    "king.com.CandyCrushSodaSaga"      # Candy Crush Soda
    "king.com.*"                       # All King games
    "Disney.*"                         # Disney apps
    "SpotifyAB.SpotifyMusic"           # Spotify
    "BytedancePte.Ltd.TikTok"         # TikTok
    "Facebook.*"                       # Facebook
    "Instagram.*"                      # Instagram
    "ShazamEntertainmentLtd.Shazam"    # Shazam
    "XINGAG.XING"                     # Xing
    "ClearChannelRadiosDigital.iHeartRadio" # iHeartRadio
    "Flipboard.Flipboard"             # Flipboard
    "AdobeSystemsIncorporated.AdobeCreativeCloudExpress" # Adobe Express
    "CanvaPtyLtd.Canva"               # Canva
    "DolbyLaboratories.DolbyAccess"    # Dolby Access
    "EclipseManager.*"                 # Eclipse Manager
    "SpotifyAB.SpotifyMusic"           # Spotify
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

    # Also remove provisioned packages so they don't come back on new users
    $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "$app*" }
    foreach ($p in $prov) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop
        } catch { }
    }
}

# Remove OneDrive if present
Write-Host "`n  Removing OneDrive..." -ForegroundColor Gray
try {
    $onedrive = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $onedrive)) { $onedrive = "$env:SystemRoot\System32\OneDriveSetup.exe" }
    if (Test-Path $onedrive) {
        Start-Process $onedrive "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        Write-Host "  OneDrive uninstalled" -ForegroundColor Green
    }
} catch { }

Write-Host "`nRemoved: $removed, Failed: $failed" -ForegroundColor Green
