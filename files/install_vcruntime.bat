@echo off
title OptimizedOS - Visual C++ Runtimes

set "DIR=%~dp0"
set IS_X64=0
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set IS_X64=1
if "%PROCESSOR_ARCHITEW6432%"=="AMD64" set IS_X64=1
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set IS_X64=1

if "%IS_X64%"=="1" goto X64

:X86
echo Installing Visual C++ x86...
"%DIR%vcredist2005_x86.exe" /q
"%DIR%vcredist2008_x86.exe" /qb
"%DIR%vcredist2010_x86.exe" /passive /norestart
"%DIR%vcredist2012_x86.exe" /passive /norestart
"%DIR%vcredist2013_x86.exe" /passive /norestart
"%DIR%vcredist2015_2017_2019_2022_x86.exe" /passive /norestart
goto END

:X64
echo Installing Visual C++ x64 + x86...
"%DIR%vcredist2005_x86.exe" /q
"%DIR%vcredist2005_x64.exe" /q
"%DIR%vcredist2008_x86.exe" /qb
"%DIR%vcredist2008_x64.exe" /qb
"%DIR%vcredist2010_x86.exe" /passive /norestart
"%DIR%vcredist2010_x64.exe" /passive /norestart
"%DIR%vcredist2012_x86.exe" /passive /norestart
"%DIR%vcredist2012_x64.exe" /passive /norestart
"%DIR%vcredist2013_x86.exe" /passive /norestart
"%DIR%vcredist2013_x64.exe" /passive /norestart
"%DIR%vcredist2015_2017_2019_2022_x86.exe" /passive /norestart
"%DIR%vcredist2015_2017_2019_2022_x64.exe" /passive /norestart

:END
echo Visual C++ runtimes installed.
