@echo off
setlocal EnableExtensions
set "HERE=%~dp0"
set "SCRIPT=%HERE%new_ru_name_fragment.sh"
set "BASH_EXE="

if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_EXE if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH_EXE (
  where bash >nul 2>&1 && for /f "usebackq delims=" %%P in (`where bash`) do (
    set "BASH_EXE=%%P"
    goto :run
  )
)

:run
if not defined BASH_EXE (
  echo new_ru_name_fragment.cmd: Git for Windows or bash.exe on PATH is required. 1>&2
  exit /b 1
)
"%BASH_EXE%" "%SCRIPT%" %*
exit /b %ERRORLEVEL%
