#!/bin/bash
# guite-setup-server.sh
# Last update: 2024-01-07
# Description: Script pour configurer un serveur Debian/Ubuntu. Installe les paquets nécessaires,
#              met à jour le système et configure SSH pour empêcher la connexion en tant que root.

# Inclure le fichier de configuration
source guite-setup-server.conf

# Mise à jour du système
echo "Mise à jour des paquets..."
apt-get update && apt-get upgrade -y

# Installation des paquets nécessaires
for pkg in $PACKAGES; do
    if ! dpkg -l | grep -qw $pkg; then
        echo "Installation de $pkg..."
        apt-get install -y $pkg
    fi
done

# Configuration de SSH pour empêcher la connexion root
echo "Configuration de SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Configuration terminée. Maintenant BMDTU"
