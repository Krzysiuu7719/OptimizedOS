# OptimizedOS - DirectX Installer
# Downloads and installs DirectX End-User Runtime

$dxUrl = "https://download.microsoft.com/download/1/B/C/1BCBDB93-35AB-4214-8EA1-E04089FC89FC/dxwebsetup.exe"
$dxPath = "$env:TEMP\dxwebsetup.exe"

Write-Host "Downloading DirectX End-User Runtime..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($dxUrl, $dxPath)
} catch {
    Write-Host "Failed to download DirectX: $_" -ForegroundColor Yellow
    exit 1
}

Write-Host "Installing DirectX (silent)..."
Start-Process $dxPath "/Q" -Wait -NoNewWindow

Write-Host "DirectX installed."
Remove-Item $dxPath -Force -ErrorAction SilentlyContinue
