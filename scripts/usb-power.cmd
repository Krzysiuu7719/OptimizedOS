@echo off
title OptimizedOS - USB Power Saving Disable

powershell -ExecutionPolicy Bypass -NoProfile -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\USB' -Recurse | Where-Object { $_.PSChildName -eq 'Device Parameters' } | ForEach-Object { foreach ($n in 'EnhancedPowerManagementEnabled','AllowIdleIrpInD3','DeviceSelectiveSuspended','SelectiveSuspendOn','EnableSelectiveSuspend') { if ((Get-ItemProperty -LiteralPath $_.PSPath -Name $n -ErrorAction SilentlyContinue) -ne $null) { Set-ItemProperty -LiteralPath $_.PSPath -Name $n -Value 0 -Force } } }"

echo USB power saving disabled.
