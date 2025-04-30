#!/bin/bash

# Trouver le point de montage de la clé USB
USB_MOUNT_POINT=$(lsblk -o MOUNTPOINT,MODEL | grep -i "usb" | awk '{print $1}')

if [ -z "$USB_MOUNT_POINT" ]; then
    echo "Aucune clé détectée"
    exit 1
fi

# Verrouillage en lecture seule
sudo mount -o remount,ro "$USB_MOUNT_POINT"

MAX_SIZE=$((500 * 1024 * 1024)) # 500 Mo en octets

# Chercher un fichier plus gros que 25 Mo
if find "$USB_MOUNT_POINT" -type f -size +"$MAX_SIZE"c | grep -q .; then
    zenity --error --title="⚠️ Fichier trop volumineux" --text="Un ou plusieurs fichiers de plus de 25 Mo ont été détectés.\nLa clé reste en lecture seule.\nVeuillez la retirer."
    exit 2
fi

# Fichier de log
LOGFILE="/home/utilisateur/.log/clamav.log"
> "$LOGFILE"

# Affichage d'une fenêtre de progression (non bloquante)
stdbuf -oL clamdscan --fdpass -v -r "$USB_MOUNT_POINT"  2>&1 | tee "$LOGFILE" | \
while read line; do
    echo "# $line"
    echo "90"  # Pourcentage fixe (tu peux ajouter une logique de suivi réel si tu veux)
done | zenity --progress \
    --title="Analyse ClamAV" \
    --text="Analyse de la clé USB en cours..." \
    --percentage=0 \
    --auto-close

# Vérification du résultat
SCAN_RESULT=${PIPESTATUS[0]}
if [ "$SCAN_RESULT" -eq 0 ]; then
	sudo mount -o remount,rw "$USB_MOUNT_POINT"
    zenity --info --title="Analyse terminée" --text="✅ Aucun fichier infecté détecté.\nLa clé est maintenant réactivée en écriture."
else
    zenity --error --title="⚠️ Virus détecté" --text="Un ou plusieurs fichiers infectés ont été trouvés.\nLa clé reste en lecture seule.\nVeuillez la retirer en toute sécurité."
fi
