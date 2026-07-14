@echo off
title OptimizedOS - Disable Memory Compression

powershell -ExecutionPolicy Bypass -NoProfile -Command "Disable-MMAgent -mc"

echo Memory compression disabled.
