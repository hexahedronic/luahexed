REM This is a launch file.
REM OKAY?

@echo off
title LuaHexed

"bin/luajit.exe" "src/init.lua"

if %ERRORLEVEL% NEQ 1 goto FAILURE

exit

:FAILURE

echo Uh-oh! An error occured.
pause >nul
