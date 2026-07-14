@echo off
title OptimizedOS - Cleanup Temp Files

rd /s /q "%TEMP%" 2>nul
rd /s /q "%WINDIR%\Temp" 2>nul
rd /s /q "%WINDIR%\Prefetch" 2>nul

echo Temp files cleaned.
