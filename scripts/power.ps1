# OptimizedOS - Custom Power Plan
# Downloads .pow from GitHub and imports it

Write-Host "=== Custom Power Plan ===" -ForegroundColor Cyan

$powUrl = "https://raw.githubusercontent.com/Krzysiuu7719/OptimizedOS/main/files/OptimizedOS.pow"
$powPath = "$env:TEMP\OptimizedOS.pow"

Write-Host "  Downloading power plan from GitHub..." -ForegroundColor Gray
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($powUrl, $powPath)
    if (!(Test-Path $powPath)) { throw "File not downloaded" }
    $size = (Get-Item $powPath).Length
    Write-Host "  Downloaded: $size bytes" -ForegroundColor Gray
} catch {
    Write-Host "  FAILED to download: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "  Importing power plan..." -ForegroundColor Gray
$output = powercfg /import "$powPath" 2>&1
Write-Host "  $output" -ForegroundColor Gray

# Extract GUID from output
$match = [regex]::Match($output, '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})')
if ($match.Success) {
    $guid = $match.Groups[1].Value
    Write-Host "  Imported GUID: $guid" -ForegroundColor Green

    # Delete default plans
    @(
        "381b4222-f694-41f0-9685-ff5bb260df2e",
        "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
        "a1841308-3541-4fab-bc81-f71556f20b4a",
        "e9a42b02-d5df-448d-aa00-03f14749eb61"
    ) | ForEach-Object { powercfg /delete $_ 2>$null }

    # Activate
    powercfg /setactive $guid
    Write-Host "  Activated!" -ForegroundColor Green
} else {
    Write-Host "  Could not parse GUID from output" -ForegroundColor Red
}

Write-Host ""
powercfg /getactivescheme
Remove-Item $powPath -Force -ErrorAction SilentlyContinue
