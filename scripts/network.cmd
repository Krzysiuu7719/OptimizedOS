@echo off
title OptimizedOS - Network Optimization

:: TCP global optimizations (only valid arguments)
netsh int tcp set global autotuning=normal
netsh int tcp set global rss=enabled
netsh int tcp set global ecncapability=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global rsc=disabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global initialRto=2000

:: Disable Nagle's algorithm (lower latency)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpDelAckTicks /t REG_DWORD /d 0 /f

:: QoS reserved bandwidth - 0% (all available for apps)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f

:: Disable power saving on NIC + Large Send Offload
powershell -Command "Get-NetAdapter | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload v2 (IPv4)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload v2 (IPv6)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue }"

:: Set DNS to Cloudflare (only for active adapters)
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { $n = $_.Name; Set-DnsClientServerAddress -InterfaceAlias $n -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue; Write-Host \"  DNS set for: $n\" }"

echo Network optimization complete.
