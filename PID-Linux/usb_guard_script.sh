#!/bin/bash

# Fichier des règles USBGuard
RULES_FILE="/etc/usbguard/rules.conf"

# Liste des ID des claviers et souris (à modifier selon tes périphériques)
ALLOWED_DEVICES=("04b3:3025" "17ef:608d") # Ajoute ici les ID de tes périphériques

# Liste des ID des clés USB autorisées (remplace avec tes clés USB)
ALLOWED_USB_KEYS=("18a5:0302")


# Sauvegarde des anciennes règles
cp "$RULES_FILE" "$RULES_FILE.bak"

# Ajoute les règles pour les claviers/souris
echo "# Autoriser les claviers et souris" | sudo tee "$RULES_FILE" > /dev/null
for ID in "${ALLOWED_DEVICES[@]}"; do
    echo "allow id $ID" | sudo tee -a "$RULES_FILE" > /dev/null
done

# Ajoute les règles pour les clés usb
echo "# Autoriser les clés USB spécifiques" | sudo tee -a "$RULES_FILE" > /dev/null
for ID in "${ALLOWED_USB_KEYS[@]}"; do
    echo "allow id $ID" | sudo tee -a "$RULES_FILE" > /dev/null
done

# Bloquer tout le reste
echo "block" | sudo tee -a "$RULES_FILE" > /dev/null

# Appliquer les nouvelles règles
sudo systemctl restart usbguard

echo "Les nouvelles règles USBGuard ont été appliquées."
echo "Claviers/Souris autorisés : ${ALLOWED_INPUT_DEVICES[*]}"
echo "Clés USB autorisées : ${ALLOWED_USB_KEYS[*]}"
