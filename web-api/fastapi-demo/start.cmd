@echo off
chcp 65001 >nul
setlocal
rem FastAPI demo (port 8900) - start
set "BASH=D:/code/environment/Git/bin/bash.exe"
if not exist "%BASH%" set "BASH=C:/Program Files\Git\bin\bash.exe"
if not exist "%BASH%" (
  echo [X] bash.exe not found. Please install Git for Windows.
  pause
  exit /b 1
)
"%BASH%" "%~dp0..\_run\run.sh" fastapi-demo start
echo %cmdcmdline% | findstr /i /c:"%~nx0" >nul && pause
endlocal
