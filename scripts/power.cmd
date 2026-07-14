@echo off
title OptimizedOS - Custom Power Plan

:: Find or create High Performance base
set "BASE=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg /query %BASE% >nul 2>&1
if %errorlevel% neq 0 set "BASE=381b4222-f694-41f0-9685-ff5bb260df2e"

:: Create new plan from base
powercfg /duplicatescheme %BASE%
for /f "tokens=4" %%a in ('powercfg /getactivescheme') do set "GUID=%%a"
if "%GUID%"=="" (
    echo ERROR: Failed to create power plan
    exit /b 1
)

:: Name and description
powercfg /changel name "OptimizedOS Custom" %GUID%
powercfg /change description "OptimizedOS Custom - Maximum performance power plan. All power saving disabled, CPU pinned to 100%%, aggressive boost, zero latency. For desktop/gaming use." %GUID%

:: ===== CPU / PROCESSOR =====
:: Processor performance core parking min: 100% (all cores active)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 100
:: Processor performance core parking max: 100%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 8baa4a8a-04b0-4f28-98c9-e2f52f6a100a 100
:: Processor performance core parking parked: 0%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 68b3adb8-2943-4f48-a337-5742a3a483f8 0
:: Minimum processor state: 100%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 100
:: Maximum processor state: 100%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
:: Processor energy performance preference: 0% (max performance)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 0
:: Processor idle demote threshold: 0% (never demote)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 4b92d758-5a24-4851-a470-815d78aee119 0
:: Processor idle promote threshold: 100% (always boost)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 7b224883-b3cc-4d79-819f-8374152cbe7c 100
:: Processor performance boost mode: Aggressive
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2
:: Processor performance time check: 20000 (default, lower = more aggressive scheduling)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 5d76a2ca-e8c0-402f-a133-2158492d58ad 20000
:: Processor duty cycling: Disabled (continuous full performance)
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 64a36d31-4db1-4f74-9c20-45b7a16b7aea 0

:: ===== HARD DISK =====
:: Turn off hard disk after: Never (0)
powercfg /setacvalueindex %GUID% 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0

:: ===== SLEEP / HIBERNATE =====
:: Sleep: Never (0)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
:: Allow hybrid sleep: Off (0)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
:: Hibernate: Never (0)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-97e-8888-515a05f02364 0
:: Allow standby states: Off (0)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 abfc2519-3608-4c2a-94ea-171b0ed546ab 0
:: Allow wake timers: Disable (0)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 0
:: System unattended sleep timeout: 0 (disabled)
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 0

:: ===== PCI EXPRESS =====
:: Link State Power Management: Off (0)
powercfg /setacvalueindex %GUID% 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0

:: ===== DISPLAY =====
:: Turn off display after: Never (0)
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
:: Display brightness: 100%
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 100
:: Adaptive brightness: Off (0)
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 0

:: ===== WIRELESS =====
:: Wireless adapter power saving: Max Performance (0)
powercfg /setacvalueindex %GUID% 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0

:: ===== USB =====
:: USB selective suspend: Disabled (0)
powercfg /setacvalueindex %GUID% 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

:: ===== VIDEO =====
:: Video playback quality: Max Performance (0)
powercfg /setacvalueindex %GUID% 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0

:: ===== BATTERY (laptop) =====
:: Critical battery action: Hibernate
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 2
:: Low battery level: 5%
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 5
:: Critical battery level: 1%
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 1

:: ===== DELETE DEFAULT PLANS =====
:: Remove Balanced
powercfg /delete 381b4222-f694-41f0-9685-ff5bb260df2e 2>nul
:: Remove High Performance
powercfg /delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
:: Remove Power saver
powercfg /delete a1841308-3541-4fab-bc81-f71556f20b4a 2>nul
:: Remove Ultimate Performance (if exists)
powercfg /delete e9a42b02-d5df-448d-aa00-03f14749eb61 2>nul

:: ===== ACTIVATE =====
powercfg /setactive %GUID%

echo.
echo ============================================
echo  OptimizedOS Custom Power Plan Applied
echo  GUID: %GUID%
echo  CPU: 100%% min, 100%% max, aggressive boost
echo  Parking: 100%% cores active
echo  Sleep/Hibernate: ALL OFF
echo  PCI Express LSPM: Off
echo  Display: Never turn off
echo  Default plans: DELETED
echo ============================================
echo.
echo Active power plan:
powercfg /getactivescheme
