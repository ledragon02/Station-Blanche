@echo off
echo Désactivation de toutes les clés USB...
"C:\Program Files (x86)\Windows Kits\10\Tools\10.0.26100.0\x64\devcon.exe" disable *USB\Class_08*

echo Activation de la clé USB autorisée...
"C:\Program Files (x86)\Windows Kits\10\Tools\10.0.26100.0\x64\devcon.exe" enable "USB\VID_18A5&PID_0302*"

echo Opération terminée.
pause
