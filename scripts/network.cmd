@echo off
title OptimizedOS - Network Optimization

:: TCP optimizations
netsh int tcp set global autotuning=normal
netsh int tcp set global chimney=disabled
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=disabled
netsh int tcp set global ecncapability=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global rss=enabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global initialRto=2000
netsh int tcp set global rsc=disabled

:: Disable Nagle's algorithm (lower latency)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpDelAckTicks /t REG_DWORD /d 0 /f

:: DNS cache optimization
netsh int ip set global dhcp=enabled
netsh int ip set global neighbors=enabled
netsh int ip set global routecache=enabled
netsh int ip set global taskoffload=enabled
netsh int ip set global monitordhcp=enabled

:: QoS reserved bandwidth - 0% (all available for apps)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f

:: Disable power saving on NIC
powershell -Command "Get-NetAdapter | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Power Saving Mode' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue }"

:: Disable Large Send Offload
powershell -Command "Get-NetAdapter | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload v2 (IPv4)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Large Send Offload v2 (IPv6)' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue }"

:: Set DNS to Cloudflare (faster)
netsh int ip set dnsservers "Wi-Fi" static 1.1.1.1 primary validate=no
netsh int ip set dnsservers "Wi-Fi" static 1.0.0.1 secondary validate=no
netsh int ip set dnsservers "Ethernet" static 1.1.1.1 primary validate=no
netsh int ip set dnsservers "Ethernet" static 1.0.0.1 secondary validate=no

echo Network optimization complete.
