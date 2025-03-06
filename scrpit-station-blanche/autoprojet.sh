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

# Analyse avec ClamAV
zenity --info --text="Analyse antivirus en cours..."
sudo freshclam
clamscan -r --remove "$MOUNT_POINT" | tee "$LOG_FILE"

if grep -q "Infected files: 0" "$LOG_FILE"; then
    zenity --info --text="Aucun virus détecté."
else
    zenity --error --text="Virus détecté ! Suppression recommandée."
    exit 1
fi

# Sélection de fichiers à copier
FILES_TO_COPY=$(zenity --file-selection --multiple --separator=" " --title="Sélectionnez les fichiers à copier" --filename="$MOUNT_POINT/")

if [ -z "$FILES_TO_COPY" ]; then
    zenity --error --text="Aucun fichier sélectionné."
    exit 1
fi

cp $FILES_TO_COPY "$TEMP_DIR/"
zenity --info --text="Fichiers copiés dans le dossier temporaire : $TEMP_DIR"

# Attente d'une nouvelle clé USB
zenity --info --text="Retirez la clé et insérez une clé USB sécurisée."

while true; do
    NEW_USB=$(lsblk -o NAME,MOUNTPOINT | grep "/media/user" | awk '{print $1}' | head -n 1)
    if [ -n "$NEW_USB" ]; then
        NEW_MOUNT_POINT=$(lsblk -o MOUNTPOINT | grep "/media/user" | head -n 1)
        break
    fi
    sleep 1
done

# Vérification et copie vers la nouvelle clé
zenity --info --text="Nouvelle clé détectée à $NEW_MOUNT_POINT. Copie en cours..."
sudo cp -r "$TEMP_DIR"/* "$NEW_MOUNT_POINT/"
zenity --info --text="Fichiers copiés avec succès."

# Nettoyage
rm -rf "$TEMP_DIR"
zenity --info --text="Nettoyage terminé. Processus finalisé."
