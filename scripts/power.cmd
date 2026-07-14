@echo off
title OptimizedOS - Custom Power Plan

:: Delete old custom plans if they exist
powercfg /delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
powercfg /delete a1841308-3541-4fab-bc81-f71556f20b4a 2>nul

:: Create "OptimizedOS Ultimate" power plan based on High Performance
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
for /f "tokens=4" %%a in ('powercfg /getactivescheme') do set "GUID=%%a"
powercfg /changel name "OptimizedOS Ultimate" %GUID%
powercfg /change description "OptimizedOS Ultimate - Full custom gaming/production power plan with maximum performance, disabled power saving, aggressive CPU boosting, and zero latency tuning." %GUID%
powercfg /setactive %GUID%

:: === SUBGROUPS ===

:: Hard Disk - Turn off after: Never (0)
powercfg /setacvalueindex %GUID% 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
powercfg /setdcvalueindex %GUID% 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0

:: Wireless Adapter - Max Performance
powercfg /setacvalueindex %GUID% 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
powercfg /setdcvalueindex %GUID% 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 2

:: Sleep - Never sleep on AC
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
powercfg /setdcvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 600
:: Allow hybrid sleep
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
powercfg /setdcvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
:: Hibernate - Never
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-97e-8888-515a05f02364 0
powercfg /setdcvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-97e-8888-515a05f02364 0
:: Allow standby states
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 abfc2519-3608-4c2a-94ea-171b0ed546ab 1
powercfg /setdcvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 abfc2519-3608-4c2a-94ea-171b0ed546ab 1
:: Allow wake timers
powercfg /setacvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1
powercfg /setdcvalueindex %GUID% 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1

:: PCI Express - Link State Power Management: Off
powercfg /setacvalueindex %GUID% 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setdcvalueindex %GUID% 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 2

:: Processor - Full Performance
:: Processor performance core parking min: 100%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 100
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 10
:: Processor energy perf preference: AC=0% DC=50%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 0
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 50
:: Processor idle demote threshold: AC=40% DC=20%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 4b92d758-5a24-4851-a470-815d78aee119 40
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 4b92d758-5a24-4851-a470-815d78aee119 20
:: Processor idle disable: AC=0 DC=0
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 5d76a2ca-e8c0-402f-a133-2158492d58ad 0
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 5d76a2ca-e8c0-402f-a133-2158492d58ad 0
:: Processor idle promote threshold: AC=60% DC=40%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 7b224883-b3cc-4d79-819f-8374152cbe7c 60
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 7b224883-b3cc-4d79-819f-8374152cbe7c 40
:: Minimum processor state: AC=100% DC=5%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 100
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
:: Maximum processor state: AC=100% DC=100%
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
:: Processor performance boost mode: Aggressive
powercfg /setacvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2
powercfg /setdcvalueindex %GUID% 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2

:: Display - Turn off after: Never (0) on AC
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
powercfg /setdcvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 180
:: Display brightness: AC=100% DC=75%
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 100
powercfg /setdcvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 75
:: Dimmed display brightness: AC=50% DC=50%
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 50
powercfg /setdcvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 50
:: Adaptive brightness: Off
powercfg /setacvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 0
powercfg /setdcvalueindex %GUID% 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 0

:: Video - Quality on AC
powercfg /setacvalueindex %GUID% 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
powercfg /setdcvalueindex %GUID% 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 1

:: Battery - Critical action: Hibernate
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 2
powercfg /setdcvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 2
:: Low battery level: 10%
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 10
powercfg /setdcvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 10
:: Critical battery level: 5%
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 5
powercfg /setdcvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 5
:: Reserve battery level: 7%
powercfg /setacvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 7
powercfg /setdcvalueindex %GUID% e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 7

:: Delete default Balanced plans
powercfg /delete 381b4222-f694-41f0-9685-ff5bb260df2e 2>nul
powercfg /delete a1841308-3541-4fab-bc81-f71556f20b4a 2>nul

:: Set as active
powercfg /setactive %GUID%

echo OptimizedOS Ultimate power plan applied and set as active.
