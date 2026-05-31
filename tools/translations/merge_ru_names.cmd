@echo off
setlocal EnableExtensions

if "%~3"=="" (
  echo usage: merge_ru_names.cmd header fragments-dir output 1>&2
  exit /b 1
)

cd /d "%~dp0..\.."
for %%I in ("%~1") do set "HEADER=%%~fI"
for %%I in ("%~2") do set "FRAGMENTS=%%~fI"
for %%I in ("%~3") do set "OUTPUT=%%~fI"
set "TMP=%OUTPUT%.tmp"
set "NL=%TEMP%\ru_names_merge_nl_%RANDOM%.tmp"

if not exist "%HEADER%" (
  echo merge_ru_names.cmd: header not found: %HEADER% 1>&2
  exit /b 1
)

for %%I in ("%OUTPUT%") do if not exist "%%~dpI" mkdir "%%~dpI"
(echo.)>"%NL%"
copy /b "%HEADER%" "%TMP%" >nul || exit /b 1

for /f "delims=" %%F in ('dir /s /b /on "%FRAGMENTS%\*.toml" 2^>nul') do (
  copy /b "%TMP%"+"%%F"+"%NL%" "%TMP%.new" >nul || exit /b 1
  move /y "%TMP%.new" "%TMP%" >nul
)

move /y "%TMP%" "%OUTPUT%" >nul
del "%NL%" 2>nul
