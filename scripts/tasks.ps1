function Is-Admin() {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Toggle-Task($task, $enable) {
    $toggle = if ($enable) { "/enable" } else { "/disable" }

    $userResult = (Start-Process "schtasks.exe" -ArgumentList "/change $($toggle) /tn `"$($task)`"" -PassThru -Wait -WindowStyle Hidden).ExitCode
    if ($userResult -eq 0) { return 0 }

    $minsudo = Join-Path (Split-Path $PSScriptRoot -Parent) "files\MinSudo.exe"
    if (Test-Path $minsudo) {
        $tiResult = [int](& $minsudo --NoLogo --TrustedInstaller --Privileged cmd /c "schtasks.exe /change $($toggle) /tn `"$($task)`" > nul 2>&1 && echo 0 || echo 1")
        return $tiResult
    }

    return $userResult
}

function main() {
    if (-not (Is-Admin)) {
        Write-Host "error: administrator privileges required"
        return 1
    }

    $wildcards = @(
        "helloface",
        "customer experience improvement program",
        "microsoft compatibility appraiser",
        "dssvccleanup",
        "bitlocker",
        "chkdsk",
        "data integrity scan",
        "defrag",
        "languagecomponentsinstaller",
        "upnp",
        "speech",
        "spaceport",
        "power efficiency",
        "cloudexperiencehost",
        "diagnosis",
        "bgtaskregistrationmaintenancetask",
        "autochk\proxy",
        "siuf",
        "device information",
        "edp policy manager"
    )

    Write-Host "Disabling scheduled tasks..."

    $scheduledTasks = schtasks /query /fo list
    $taskNames = [System.Collections.ArrayList]@()
    $failedCount = 0
    $successCount = 0

    foreach ($line in $scheduledTasks) {
        if ($line.contains("TaskName:")) {
            ($taskNames.Add($line.Split(":")[1].Trim().ToLower())) 2>&1 > $null
        }
    }

    foreach ($wildcard in $wildcards) {
        Write-Host "Searching for $($wildcard)"
        foreach ($task in $taskNames) {
            if ($task.contains($wildcard)) {
                $result = Toggle-Task -task $task -enable $false
                if ($result -eq 0) {
                    $successCount++
                } else {
                    Write-Host "  Warning: could not disable: $task"
                    $failedCount++
                }
            }
        }
    }

    Write-Host "Done: $successCount disabled, $failedCount failed"

    if ($successCount -eq 0 -and $failedCount -gt 0) {
        return 1
    }
    return 0
}

$_exitCode = main
Write-Host
exit $_exitCode
