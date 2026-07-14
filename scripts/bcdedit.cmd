@echo off
title OptimizedOS - BCDEdit Tweaks

bcdedit /set useplatformtick yes
bcdedit /set useplatformlock no
bcdedit /set tscsyncpolicy enhanced
bcdedit /set disabledynamictick yes
bcdedit /set {current} description "OptimizedOS"
fsutil behavior set disablelastaccess 1

echo BCDEdit tweaks applied.
