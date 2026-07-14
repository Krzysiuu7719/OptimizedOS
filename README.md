# OptimizedOS

**Windows Optimization Tool** — one-click system debloat and performance tuning.

## How it works

1. Run `OptimizedOS.exe` as Administrator
2. Click **START**
3. Tool downloads all scripts from this repository and executes them in order
4. Watch the live log for progress

Adding a new optimization = upload script + edit `manifest.json` — no recompile needed.

## What it does

- Registry tweaks (debloat, privacy, performance)
- Disable 130+ unnecessary services
- Disable Scheduled Tasks (telemetry, compat, diagnostics)
- Remove Windows bloatware
- Privacy hardening (O&O ShutUp10 + custom)
- BCD boot tweaks (no boot GUI, dynamic tick)
- Ultimate power plan (no sleep, no hibernate, max CPU)
- Network optimization (TCP heuristics off, RSS, Fast Open)
- USB power saving off
- Memory compression off
- Event tracing off
- Edge removal
- VC++ Runtime install (2005-2022)
- DirectX runtime install
- Temp/prefetch cleanup

## Tech

- C# WPF .NET 8
- Single-file self-contained EXE
- Dark UI with live log panel
- Downloads scripts from GitHub at runtime

## Author

**Krzysi_x** (Krzysiuu7719)
