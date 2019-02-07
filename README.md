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
wget $CHECKSUM_SHA2

echo "Vérfication des sommes de contrôle des fichiers téléchargés"
rm -f masomme.sha512sum
cat SHA256SUMS|grep *~Debian~stretch_amd64.deb >> masomme.sha512sum
sha256sum -c masomme.sha512sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.sha512sum)] "

rm -f masomme.md5sum
cat MD5SUMS|grep *~Debian~stretch_amd64.deb >> masomme.md5sum
md5sum -c masomme.md5sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.md5sum)] "


# Exécution de l'installation du package debian : l'intégrité du package a été doublement vérifiée. 
sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX

# L'exécution de ce processus d'installation log une indication : 
# 
# > There were problems setting up VirtualBox.  To re-start the set-up process, run
# >  /sbin/vboxconfig
# > as root.
# 
# De plus, lorsque l'on exécute : 
#  [sudo /sbin/vboxconfig]
# On obtient un certain nombre de messages d'erreurs, ainsi que la suggestion pour les résoudre : des dépendances de l'exécutable [/sbin/vboxconfig] manquent à l'appel. Il faut donc installer ces exécutables avant de ré-essayer d'exécuter [sbin/vboxconfig] : 

sudo apt-get install -y linux-headers-amd64 linux-headers-4.9.0-7-amd64 gcc make perl

# Maintenant, on peut ré-essayer d'exécuter [/sbin/vboxconfig]
sudo /sbin/vboxconfig

echo "Et bingo, nous sommes bons! "
echo "Notons : l'idéal sera, pour une recette de \"production\", d'installer ces dépendances avant même l'exécuation [dpkg -i \$NOM_FICHIER_PACKAGE_LINUX_DEBIAN]"



# Nous veneons d'installer un package debian (virutalbox), manuellement. Il peut lui manquer des dépendances.
# apt-get a la capacité de résoudre ces dépendances automatiquement, avec la commande : 
sudo apt-get -f install

```

## Exécution de `sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX`

Lorsque l'on exécute la commande `sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX`, sans avoir exécuté avant la commande : 

```bash
sudo apt-get install -y linux-headers-amd64 linux-headers-4.9.0-7-amd64 gcc make perl
```
On constate un arrêt de l'exécution avec ereur, et des logs. Dans ces logs, on note plusieurs éléments : 

* D'abord, les logs se terminent en mentionnant un problème, et qu'une fois réoslu le problème, il faudra ré-esayer d'exécuter "avec `sudo`" la commande `/sbin/vboxconfig` : 
```bash
There were problems setting up VirtualBox.  To re-start the set-up process, run
 /sbin/vboxconfig
as root.
```
Donc, le processus exécutant la commande `dpkg -i $NOM_DE_FICHIER`, a déjà essayé d'exécuter `sudo /sbin/vboxconfig`, mais un problème est survenu.

* Ensuite, on pourra noter que la procédure d'installation de virtualbox créée un groupe d'utilisateurs linux sur la machine debian :  le groupe `vboxusers`, qui est un _groupe système_.
```bash
addgroup: The group `vboxusers' already exists as a system group. Exiting.
```
* De plus, on notera la définition de service `SystemD`  :  
```bash
Created symlink /etc/systemd/system/multi-user.target.wants/vboxdrv.service → /lib/systemd/system/vboxdrv.service.
Created symlink /etc/systemd/system/multi-user.target.wants/vboxballoonctrl-service.service → /lib/systemd/system/vboxballoonctrl-service.service.
Created symlink /etc/systemd/system/multi-user.target.wants/vboxautostart-service.service → /lib/systemd/system/vboxautostart-service.service.
Created symlink /etc/systemd/system/multi-user.target.wants/vboxweb-service.service → /lib/systemd/system/vboxweb-service.service.
```
Impliquant que plusieurs exécutables virtualbox seront démarrables en tant que service, `vboxdrv`, `vboxballoonctrl`, `vboxautostart`, `vboxweb`, et sont activables en tant que service, avec les commandes : 

```bash
sudo systemctl enable vboxdrv
sudo systemctl enable vboxballoonctrl
sudo systemctl enable vboxautostart
sudo systemctl enable vboxweb
```

* Enfin, une dernière indication mérite investigation, parcequ'il s'agit de faire le build d'un composant VirtualBox : 

```bash
This system is currently not set up to build kernel modules.
Please install the gcc make perl packages from your distribution.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    linux-headers-amd64 linux-headers-4.9.0-7-amd64
This system is currently not set up to build kernel modules.
Please install the gcc make perl packages from your distribution.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    linux-headers-amd64 linux-headers-4.9.0-7-amd64
```
Ainsi, il semble que ce soient là les erreurs rencontrées, que nous devons résoudre, pour essayer à nouveau l'éxécution de `sudo /sbin/vboxconfig`.
Mais ces mentions sont claires, il s'agit de dépendances à l'exécution de `/sbin/vboxconfig`, que l'on peut installer de la manière suivante :
```bash
sudo apt-get install -y linux-headers-amd64 linux-headers-4.9.0-7-amd64 gcc make perl
```


# Conclusion

Je  remarque deux choses : 

* Dans le premier mode d'installation, on aune installation "propre", par le package manager, avec les garanties fournie spar le repository. Totuefois, je n'ai pas trouvé, pour ce mode d'installation, de procédure, automatique ou non, par laquelle il m'est possbile de vérifier quelles sont les clés disponibles pour le repository de backports debian / virtualbox  
* Dans le second moide d'isntallation : 
  * j'ai une procédure de sécurité qui constitue un cycle complet  : il faut aller vérifier régulièrement de nouveaux contenus ont été publiés par Oracle sur virtualbox.org
  * une installation que je dois concenvoir entièrement au lieu de laisser faire le package manager, 
  * j'obtiens manifestement avec cette méthode d'installation, une version plus récente de virutalbox.

En conclusion, je pense que je suis là dans le cas typique pour lequel il serait jsutifié que je me monte moi-même mes repo `apt-get` , `apk` et `yum` pour distribuer les paquets virutalbox les plus frais : 
* il s'agit d'avoir dans un repository géré en interne, des versions plsu récentes de virtualbox, quelle celles distribuées via le repository Oracle correspondant
* Il s'agit de régler un problème posé par l'installation avec `dpkg -i $NOM_FICHIER_LINUX_DEBIAN`  : en isnallant virtualbox de cette manière, la commandes `sudo apt-get update -y` et  `sudo apt-get upgrade -y`, n'impliqueront aucune mise à jour, ni aucune montée de verion de virtualbox, sur le `poste-devops-typique`.

Voir: [`Redhat Satellite / Spacewalk`](https://spacewalkproject.github.io/) + [`Pulp repository manager`](https://pulpproject.org/)
