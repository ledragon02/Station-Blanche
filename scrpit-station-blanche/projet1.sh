#!/bin/bash

TEMP_DIR="/home/user/temp_usb_files"
MOUNT_POINT=$(lsblk -o NAME,MOUNTPOINT | grep '/media/user' | awk '{print $2}' | head -n 1)
LOG_FILE="$HOME/clamav_scan.log"

# Création du dossier temporaire
mkdir -p "$TEMP_DIR"

# Vérification que la clé est montée
if [ ! -d "$MOUNT_POINT" ]; then
    zenity --error --text="Aucune clé USB détectée à $MOUNT_POINT."
    exit 1
fi
