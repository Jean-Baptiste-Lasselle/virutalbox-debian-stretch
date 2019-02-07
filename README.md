# virutalbox-debian-stretch
Recette de provision de VirtualBox pour une machine Debian Stretch.


# Références 

* Sur la page accesible par le lien ci-dessous, on peut lire de source officielle qu'il faut (au Jeudi 16 Août 2018) configurer un repository particulier (de "back-ports"), pour procéder à l'installation de virtualbox par le package manager apt  :

https://wiki.debian.org/VirtualBox
https://backports.debian.org/Instructions/

Le repository à utiliser est celui de debian stretch, [`deb http://ftp.debian.org/debian stretch-backports main`] : 

```
Add backports to your sources.list

    For jessie add this line

    deb http://ftp.debian.org/debian jessie-backports main

    to your sources.list (or add a new file with the ".list" extension to /etc/apt/sources.list.d/) You can also find a list of other mirrors at https://www.debian.org/mirror/list

    For stretch add this line

    deb http://ftp.debian.org/debian stretch-backports main

    to your sources.list (or add a new file with the ".list" extension to /etc/apt/sources.list.d/) You can also find a list of other mirrors at https://www.debian.org/mirror/list

    Run apt-get update
```

# Recette bash

```

export FICHIER_CONF=/etc/apt/sources.list.d/stretch-backports-repo.list
export FICHIER_TEMP=$HOME/etc.apt.sources.list.d.stretch-backports-repo.list
rm -f $FICHIER_TEMP
touch $FICHIER_TEMP
echo "deb http://ftp.debian.org/debian stretch-backports main" >> $FICHIER_TEMP
sudo rm -f $FICHIER_CONF
sudo cp -f $FICHIER_TEMP $FICHIER_CONF
# rétablissement des droits de propriété du système
sudo chmod a-r $FICHIER_CONF
sudo chmod a-x $FICHIER_CONF
sudo chmod a-w $FICHIER_CONF
sudo chmod o+r $FICHIER_CONF
sudo chmod o+w $FICHIER_CONF
sudo chown root:root $FICHIER_CONF

# Enfin, il faut ajouter la clé GPG du repository Oracle de distribution de virtualbox
wget https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc

# On met à jour notre package mamanger système, et on va fouiller dans le repository Oracle, pour afficher les versions disponibles de virtualbox
sudo apt-get update -y
sudo apt-cache search virtualbox*


# puis installation virtualbox

sudo apt-get install -y virtualbox

```
Dans la recette ci-dessus, la sécuritsation du repository Oracle repose sur une clé GPG téléchargée, à savoir `oracle_vbox_2016.asc` ( https://www.virtualbox.org/download/oracle_vbox_2016.asc )
Je veux ici noter de plus, que sur le site officiel de VirtualBox, on trouve les liens de télépchargement de tous les binaires distribués par Oracles, ainsi que les checksum correspondant. Si bien qu'il serait aussi possible d'installer virtualbox de la manière suivante : 

```bash
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
wget $CHECKSUM_MD5

echo "Vérfication des sommes de contrôle des fichiers téléchargés"
rm -f masomme.sha512sum
cat SHA256SUMS|grep *~Debian~stretch_amd64.deb >> masomme.sha512sum
sha256sum -c masomme.sha512sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.sha512sum)] "

rm -f masomme.md5sum
cat MD5SUMS|grep *~Debian~stretch_amd64.deb >> masomme.md5sum
md5sum -c masomme.md5sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.md5sum)] "


# Exécution de l'installation du package debian : l'intégrité du package a été doublement vérifiée. 
sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX

# Nous veneons d'installer un package debian (virutalbox), manuellement. Il peut lui manquer des dépendances.
# apt-get a la capacité de résoudre ces dépendances automatiquement, avec la commande : 
sudo apt-get -f install

```
Je  remarque deux choses : 

* Dans le premier mode d'installation, on aune installation "propre", par le package manager, avec les garanties fournie spar le repository. Totuefois, je n'ai pas trouvé, pour ce mode d'installation, de procédure, automatique ou non, par laquelle il m'est possbile de vérifier quelles sont les clés disponibles pour le repository de backports debian / virtualbox  
* Dans le second moide d'isntallation : 
  * j'ai une procédure de sécurité qui constitue un cycle complet  : il faut aller vérifier régulièrement de nouveaux contenus ont été publiés par Oracle sur virtualbox.org
  * une installation que je dois concenvoir entièrement au lieu de laisser faire le package manager, 
  * j'obtiens manifestement avec cette méthode d'installation, une version plus récente de virutalbox.

En conclusion, je pense que je suis là dans le cas typique pour lequel il serait jsutifié que je me monte moi-même mes repo `apt-get` , `apk` et `yum` pour distribuer les paquets virutalbox les plsu frais
