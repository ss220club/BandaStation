@echo off
setlocal
cd /d "%~dp0"

if "%~1"=="" (
    echo Drag .DMM file on this bat
    pause
    exit /b
)

:: Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is missing!
    pause
    exit /b
)

:: Script
python flipper.py "%~1"

echo.
echo Finished.
pause