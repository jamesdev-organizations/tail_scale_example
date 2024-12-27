@echo off
for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -like 'Docker*' }).InstallLocation"') do set dockerInstallLocation=%%i

if not "%dockerInstallLocation%"=="" (
    echo DOCKER_RUNNING
    powershell -Command "start '%dockerInstallLocation%\Docker Desktop.exe'"
) else (
    echo DOCKER_RUNNING_ERROR
)

