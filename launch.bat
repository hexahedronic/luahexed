REM This is a launch file.
REM OKAY?

@echo off
title LuaHexed

"bin/luajit.exe" "src/init.lua"

if %ERRORLEVEL% NEQ 0 goto FAILURE

exit /b 1

:FAILURE

echo Uh-oh! An error occured.
pause >nul
