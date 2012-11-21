@ECHO OFF
SETLOCAL EnableDelayedExpansion
%~d0

CD "%~dp0"

SET powerShellDir=%WINDIR%\system32\windowspowershell\v1.0
echo.
echo ========= Setting PowerShell Execution Policy =========
%powerShellDir%\powershell.exe -NonInteractive -Command "Set-ExecutionPolicy unrestricted"
echo Setting Execution Policy Done!

%powerShellDir%\powershell.exe -NonInteractive -command "& '%~dp0\setup.local.ps1'"

CHOICE /M "Do you want to configure the deployment for segment 5?"

IF errorlevel 2 goto exit

%~dp0\..\Setup.Deployment.cmd

:exit

echo.

@pause
