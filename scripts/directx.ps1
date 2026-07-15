[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dxUrls = @(
    "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe",
    "https://download.microsoft.com/download/1/B/C/1BCBDB93-35AB-4214-8EA1-E04089FC89FC/dxwebsetup.exe"
)
$dxPath = "$env:TEMP\dxwebsetup.exe"

Write-Host "Downloading DirectX End-User Runtime..."
$downloaded = $false

foreach ($url in $dxUrls) {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $dxPath)
        if (Test-Path $dxPath) {
            $downloaded = $true
            break
        }
    } catch {
        Write-Host "  Failed from: $url"
    }
}

if (-not $downloaded) {
    Write-Host "Failed to download DirectX installer from all sources."
    exit 1
}

Write-Host "Installing DirectX (silent)..."
$proc = Start-Process $dxPath "/Q" -Wait -PassThru
if ($proc.ExitCode -ne 0) {
    Write-Host "DirectX installer exited with code: $($proc.ExitCode)"
    exit $proc.ExitCode
}

Write-Host "DirectX installed successfully."
Remove-Item $dxPath -Force -ErrorAction SilentlyContinue
