#!/bin/bash

# télécharger le fichier *.deb d'installation de virtualbox sous debian stretch
# J'ai trouvé ces 3 URI de téléchargement, en allant sur le site officiel de virutalbox, au menu "dowloads", i.e. 
# https://www.virtualbox.org/wiki/Linux_Downloads
export URI_TELECHARGEMENT_PACKAGE_VBOX_DEBIAN=https://download.virtualbox.org/virtualbox/6.0.4/virtualbox-6.0_6.0.4-128413~Debian~stretch_amd64.deb
export NOM_FICHIER_DEB_INSTALLATION_VBOX=virtualbox-6.0_6.0.4-128413~Debian~stretch_amd64.deb
export CHECKSUM_MD5=https://www.virtualbox.org/download/hashes/6.0.4/MD5SUMS
export CHECKSUM_SHA2=https://www.virtualbox.org/download/hashes/6.0.4/SHA256SUMS

mkdir ./provision_virtual_box/
cd ./provision_virtual_box/
wget $URI_TELECHARGEMENT_PACKAGE_VBOX_DEBIAN
wget $CHECKSUM_MD5
wget $CHECKSUM_SHA2

echo "Vérfication des sommes de contrôle des fichiers téléchargés"
rm -f masomme.sha512sum
cat SHA256SUMS|grep *~Debian~stretch_amd64.deb >> masomme.sha512sum
sha256sum -c masomme.sha512sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.sha512sum)] " && exit 1

rm -f masomme.md5sum
cat MD5SUMS|grep *~Debian~stretch_amd64.deb >> masomme.md5sum
md5sum -c masomme.md5sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.md5sum)] " && exit 1

# installation des dépendances du processus d'installation de virutalbox
sudo apt-get update -y
sudo apt-get install -y linux-headers-amd64 linux-headers-4.9.0-7-amd64 gcc make perl

# Exécution de l'installation du package debian : l'intégrité du package a été doublement vérifiée. 
sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX

# Maintenant, on a plus besoin de ré-essayer d'exécuter [/sbin/vboxconfig] : il est exécuté par `dpkg -i `
# sudo /sbin/vboxconfig

echo "Et bingo, nous sommes bons! "
echo "Notons : l'idéal sera, pour une recette de \"production\", d'installer ces dépendances avant même l'exécuation [dpkg -i \$NOM_FICHIER_PACKAGE_LINUX_DEBIAN]"


# Nous veneons d'installer un package debian (virutalbox), manuellement. Il peut lui manquer des dépendances.
# apt-get a la capacité de résoudre ces dépendances automatiquement, avec la commande : 
# (sychronisation package manager)
sudo apt-get -f install
