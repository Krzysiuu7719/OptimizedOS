@echo off
title OptimizedOS - Custom Power Plan

echo Importing OptimizedOS Custom power plan...

:: Import and capture the GUID from output
for /f "tokens=4" %%a in ('powercfg /import "%~dp0OptimizedOS.pow" ^| findstr /i "GUID"') do set "NEWGUID=%%a"

if "%NEWGUID%"=="" (
    echo ERROR: Failed to import power plan
    exit /b 1
)

echo Imported GUID: %NEWGUID%

:: Delete default plans
powercfg /delete 381b4222-f694-41f0-9685-ff5bb260df2e 2>nul
powercfg /delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
powercfg /delete a1841308-3541-4fab-bc81-f71556f20b4a 2>nul
powercfg /delete e9a42b02-d5df-448d-aa00-03f14749eb61 2>nul

:: Set the imported plan as active
powercfg /setactive %NEWGUID%

echo.
echo ============================================
echo  OptimizedOS Custom Power Plan Activated
echo ============================================
powercfg /getactivescheme
