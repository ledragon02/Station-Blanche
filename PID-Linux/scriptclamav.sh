#!/bin/bash

# Trouver le point de montage de la clé USB
USB_MOUNT_POINT=$(lsblk -o MOUNTPOINT,MODEL | grep -i "usb" | awk '{print $1}')

if [ -z "$USB_MOUNT_POINT" ]; then
    echo "Aucune clé USB détectée."
    exit 1
fi

echo "Vous vous situez : $(pwd)"
echo "Lancement de l'analyse"
#zenity --info --text="Analyse antivirus en cours estimation 20 secondes"
stdbuf -oL clamscan -r  "$USB_MOUNT_POINT" --remove --log=/tmp/clamav.log 2>&1 | \
while read line; do
    echo "# $line"
    echo "90" # Pourcentage fixe (la barre va avancer lentement)
    sleep 0.1
done | zenity --progress --title="Analyse ClamAV" --text="Analyse en cours..." --percentage=0 --auto-close --auto-kill



