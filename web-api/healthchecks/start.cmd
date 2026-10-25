@echo off
chcp 65001 >nul
setlocal
rem healthchecks web app (port 8910) - start
set "BASH=D://code//environment//Git//bin//bash.exe"
if not exist "%BASH%" set "BASH=C://Program Files\Git\bin\bash.exe"
"%BASH%" "%~dp0..\_run\run.sh" healthchecks start
echo %cmdcmdline% | findstr /i /c:"%~nx0" >nul && pause
endlocal
