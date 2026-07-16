@echo off
title OptimizedOS - BCDEdit Tweaks

REM bcdedit /set useplatformtick yes
REM bcdedit /set useplatformlock no
REM bcdedit /set tscsyncpolicy enhanced
REM bcdedit /set disabledynamictick yes
bcdedit /set {current} description "OptimizedOS"
fsutil behavior set disablelastaccess 1

echo BCDEdit tweaks applied.
