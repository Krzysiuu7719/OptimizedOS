@echo off
title OptimizedOS - Disable Event Trace Sessions

for %%a in ("SleepStudy" "Kernel-Processor-Power" "UserModePowerService") do (
    wevtutil sl "Microsoft-Windows-%%~a/Diagnostic" /e:false
)

echo Event trace sessions disabled.
