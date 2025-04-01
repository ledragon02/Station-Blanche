@echo off
setlocal enabledelayedexpansion

::  Détecter la lettre de la clé USB
for /f "tokens=1,2 delims= " %%A in ('wmic logicaldisk where "DriveType=2" get DeviceID^, VolumeName ^| find ":"') do (
    set USB_DRIVE=%%A
)

::  Vérifier si une clé USB a été détectée
if "%USB_DRIVE%"=="" (
    echo  Aucune clé USB détectée.
    exit /b
)

echo Clé USB détectée : %USB_DRIVE%\

:: Créer un fichier temporaire pour les logs
set LOGFILE=%TEMP%\clamscan_log.txt
​
echo Les logs sont enregistrés dans : %LOGFILE%
echo Scan en cours...
start /min cmd /c "clamscan -r --remove "%USB_DRIVE%\" > "%LOGFILE%" 2>&1"
​
pause
