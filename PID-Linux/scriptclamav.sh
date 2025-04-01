#!/bin/bash

# Trouver le point de montage de la clé USB
USB_MOUNT_POINT=$(lsblk -o MOUNTPOINT,MODEL | grep -i "usb" | awk '{print $1}')

if [ -z "$USB_MOUNT_POINT" ]; then
    echo "Aucune clé USB détectée."
    exit 1
fi

echo "Vous vous situez : $(pwd)"
echo "Lancement de l'analyse"
stdbuf -oL clamscan -r "$USB_MOUNT_POINT" --remove 2>&1 | tee /tmp/clamav.log | \
while read line; do
    echo "# $line"  # Affiche chaque ligne dans Zenity
    echo "90"       # Pourcentage fixe (à améliorer pour un vrai suivi)
    sleep 0.1
done | zenity --progress --title="Analyse ClamAV" --text="Analyse en cours..." --percentage=0



