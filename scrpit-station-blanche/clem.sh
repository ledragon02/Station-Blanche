#!/bin/bash

TEMP_DIR="/home/user/dossier_tempo"
LOG_FILE="$HOME/clamav_scan.log"

# Détection de la clé USB
USB_DEVICE=$(lsblk -rno NAME,TYPE | grep 'sda1' | awk '{print "/dev/"$1}')
if [ -z "$USB_DEVICE" ]; then
    zenity --error --text="Aucune clé USB détectée."
    exit 1
fi
udisksctl mount -b "$USB_DEVICE"

MOUNT_POINT=$(lsblk -o NAME,MOUNTPOINT | grep '/media/user' | awk '{print $2}' | head -n 1)
if [ ! -d "$MOUNT_POINT" ]; then
    zenity --error --text="Aucune clé USB détectée à $MOUNT_POINT."
    exit 1
fi

# Récupérer la liste des fichiers à scanner
FILES_TO_SCAN=$(find "$MOUNT_POINT" -type f)
TOTAL_FILES=$(echo "$FILES_TO_SCAN" | wc -l)
PROCESSED=0

> "$LOG_FILE"  # Vide le fichier log

(
for FILE in $FILES_TO_SCAN; do
    clamscan "$FILE" >> "$LOG_FILE"
    PROCESSED=$((PROCESSED + 1))
    PERCENT=$((PROCESSED * 100 / TOTAL_FILES))
    echo "$PERCENT"
    echo "# Analyse de : $FILE"
done
) | zenity --progress \
  --title="Analyse antivirus en cours" \
  --text="Initialisation..." \
  --percentage=0 \
  --auto-close

# Vérifie si Zenity a été interrompu
if [ $? -ne 0 ]; then
    zenity --error --text="Analyse annulée par l'utilisateur."
    exit 1
fi

# Vérifie les résultats
INFECTED_FILE=$(grep "FOUND" "$LOG_FILE" | sed -E 's/: .*FOUND.*//')
if [ -z "$INFECTED_FILE" ]; then
    zenity --info --text="Aucun virus détecté."
else
    zenity --error --text="Virus détecté dans les fichiers suivants :\n\n $INFECTED_FILE \n\n Suppression obligatoire."
    exit 1
fi

# Création du dossier temporaire
mkdir -p "$TEMP_DIR"

# Sélection de fichiers à copier
FILES_TO_COPY=$(zenity --file-selection --multiple --separator=" " --title="Sélectionnez les fichiers à copier" --filename="$MOUNT_POINT/")
for file in $FILES_TO_COPY; do
        if [[ "$file" != "$MOUNT_POINT"* ]];then
        zenity --error --text="Fichier pas sur la clé usb"
        exit 1
fi
done

if [ -z "$FILES_TO_COPY" ]; then
    zenity --error --text="Aucun fichier sélectionné."
    exit 1
fi

cp $FILES_TO_COPY "$TEMP_DIR/"
zenity --info --text="Fichiers copiés dans le dossier temporaire : $TEMP_DIR"

# Attente d'une nouvelle clé USB
zenity --info --text="Retirez la clé et insérez une clé USB sécurisée."
udisksctl mount -b "$USB_DEVICE"

while true; do
    NEW_USB=$(lsblk -o NAME,MOUNTPOINT | grep "/media/user" | awk '{print $1}' | head -n 1)
    if [ -n "$NEW_USB" ]; then
        NEW_MOUNT_POINT=$(lsblk -o MOUNTPOINT | grep "/media/user" | head -n 1)
        break
    fi
    sleep 1
done
#Scan de la seconde clé usb
clamscan -r "$NEW_MOUNT_POINT"
# Vérification et copie vers la nouvelle clé
zenity --info --text="Nouvelle clé détectée à $NEW_MOUNT_POINT. Copie en cours..."
sudo cp -r "$TEMP_DIR"/* "$NEW_MOUNT_POINT/"
zenity --info --text="Fichiers copiés avec succès."

# Nettoyage
rm -rf "$TEMP_DIR"
zenity --info --text="Nettoyage terminé. Processus finalisé."

