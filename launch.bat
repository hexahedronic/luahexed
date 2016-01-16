@echo off

REM This is a launch file.
REM OKAY?

title LuaHexed

if not exist "bin/luajit.exe" goto NOBIN

"bin/luajit.exe" "src/init.lua"

if %ERRORLEVEL% NEQ 0 goto FAILURE

exit /b 1

:FAILURE

echo Uh-oh! An error occured.
pause >nul
exit /b 1

:NOBIN

echo A bin folder was not found.
echo Please download and extract the binaries from:
echo http://github.com/Hexahedronic/luahexed/releases
pause >nul
