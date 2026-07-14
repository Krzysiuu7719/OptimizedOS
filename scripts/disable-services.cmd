@echo off
title OptimizedOS - Disable Services (Rename Method)

set "dir1=%SystemRoot%\System32"
set "dir2=%SystemRoot%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy"
set "dir3=%SystemRoot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy"
set "dir4=%SystemRoot%\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy"

ren "%dir1%\backgroundTaskHost.exe" "backgroundTaskHost.exe.bak" 2>nul
ren "%dir1%\ctfmon.exe" "ctfmon.exe.bak" 2>nul
ren "%dir2%\SearchUI.exe" "SearchUI.exe.bak" 2>nul
ren "%dir3%\SearchApp.exe" "SearchApp.exe.bak" 2>nul
ren "%dir4%\TextInputHost.exe" "TextInputHost.exe.bak" 2>nul

echo Services renamed successfully.
