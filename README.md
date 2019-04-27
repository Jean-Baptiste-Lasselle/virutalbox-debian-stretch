# Recette de provision de VirtualBox pour une machine Debian Stretch.


# Introduction 

En cherchant sur le web une procédure "officielle", d'installation de VirtualBox, pour un poste de travail `Debian`, on tombe rapidement sur les pages ci-dessous : 

* https://wiki.debian.org/VirtualBox

On peut lire de cette source officielle, qu'il faut (au Jeudi 16 Août 2018) configurer un repository particulier, pour procéder à l'installation de virtualbox par le package manager apt. Ce repository est un repository dit de "back-ports" au sens de `Debian` : 

* https://backports.debian.org/Instructions/

Le repository de backport à utiliser est maintenu par Oracle, [`http://download.virtualbox.org/virtualbox/debian`], à configurer selon la procédure standard d'ajout de repo de backports : 

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

# Installation par le repository de `back-ports` debian maintenu par`Oracle`

Cette installation est documentée sur le site offciel Debian, à la page https://wiki.debian.org/VirtualBox .

## Recette bash

```

export FICHIER_CONF=/etc/apt/sources.list.d/stretch-backports-repo.list
export FICHIER_TEMP=$HOME/etc.apt.sources.list.d.stretch-backports-repo.list
rm -f $FICHIER_TEMP
touch $FICHIER_TEMP
echo "deb http://download.virtualbox.org/virtualbox/debian stretch contrib" >> $FICHIER_TEMP
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

## Remarques :  Sécurité

Dans cette recette, la sécurisation du repository Debian repose sur une clé `PGP` téléchargée, à savoir `oracle_vbox_2016.asc` ( https://www.virtualbox.org/download/oracle_vbox_2016.asc )

Ceci me pose le problème de sécurité suivant : 
* Je ne comprends pas la précédure de sécurité consistant à télécharger la cé de sécurisation du repository http://download.virtualbox.org/virtualbox/debian  , à l'URI https://www.virtualbox.org/download/oracle_vbox_2016.asc 
* Je n'ai aucun moyen de vérifier quand et comment cette clé, sécurisant ce repository de backports debian, est mise à jour : 
  * Il me faudrait au moins un document officiel Oracle, dans lequel Oracle indique que https://www.virtualbox.org/download/oracle_vbox_2016.asc est bel et bien la clé de sécurité correspondant au repo de backport debian http://download.virtualbox.org/virtualbox/debian, offcialisant ce canal de distribution.
  * Il me faudrait une visibilité quant à la politique de sécurité appliquée sur ce repository http://download.virtualbox.org/virtualbox/debian   par Oracle.
* http://download.virtualbox.org/virtualbox/debian   n'est pas sécurisé par https, et j'aimerais quelque chose de plus sécurisé.


## furher : sums of keys

On remarque : 

* D'un côté, la documentation officlelle `Debian` nous idique de télécharger la clé de repository Oracle, [oracle_vbox_2016.asc](http://download.virtualbox.org/virtualbox/debian), à l'URI http://download.virtualbox.org/virtualbox/debian
* D'un autre côté, un fichier `oracle_vbox_2016.asc` est bien présent sur l'emplacement serveur http://download.virtualbox.org/virtualbox/debian . 
* Donc, pourquoi télécharger la clé de sécurisation du repostory http://download.virtualbox.org/virtualbox/debian à l'URI https://www.virtualbox.org/download/oracle_vbox_2016.asc , au lieu de http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc ? 
* Mieux, à l'emplacement serveur http://download.virtualbox.org/virtualbox/debian, on trouve aussi deux fichiers de somme de contrôle, `MD5SUMS` et`SHA256SUMS`, et ces fichiers de comme contiennent une somme de contrôle pour le fichier `oracle_vbox_2016.asc` :  

```bash
wget http://download.virtualbox.org/virtualbox/debian/MD5SUMS
wget http://download.virtualbox.org/virtualbox/debian/SHA256SUMS
cat MD5SUMS|grep oracle_vbox_2016.asc
cat SHA256SUMS|grep oracle_vbox_2016.asc
```
_donne :_
```bash
jibl@poste-devops-jbl-16gbram:~/IAAS/virtualbox/garage$ cat MD5SUMS|grep oracle_vbox_2016.asc
35eac5b13a7c055578d33115b1864740 *oracle_vbox_2016.asc
jibl@poste-devops-jbl-16gbram:~/IAAS/virtualbox/garage$ cat SHA256SUMS|grep oracle_vbox_2016.asc
49e6801d45f6536232c11be6cdb43fa8e0198538d29d1075a7e10165e1fbafe2 *oracle_vbox_2016.asc
jibl@poste-devops-jbl-16gbram:~/IAAS/virtualbox/garage$ 
```

* Il faudrait donc vérifier la somme de contrôle de la clé téléchargée, avant de l'ajouter comme clé référencée avec une commande `apt-key add` : 

```bash
export NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9=oracle_vbox_2016.asc
wget http://download.virtualbox.org/virtualbox/debian/$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9
wget http://download.virtualbox.org/virtualbox/debian/MD5SUMS
wget http://download.virtualbox.org/virtualbox/debian/SHA256SUMS


echo "Vérfication de la somme 'SHA2' de contrôle de la clé [$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9] de sécurisation du repostory de cbackports debian / virtualbox maintenu par Oracle [http://download.virtualbox.org/virtualbox/debian] "
rm -f masomme.sha512sum
cat SHA256SUMS|grep "$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9" >> masomme.sha512sum
sha256sum -c masomme.sha512sum || echo "Le fichier téléchargé [$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9] a été corrompu, il ne correspond pas à la somme de contrôle 'SHA2' fournie par Oracle : [$(cat masomme.sha512sum)] " && exit 1

echo "Vérfication de la somme 'MD5' de contrôle de la clé [$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9] de sécurisation du repostory de cbackports debian / virtualbox maintenu par Oracle [http://download.virtualbox.org/virtualbox/debian] "
rm -f masomme.md5sum
cat MD5SUMS|grep "$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9" >> masomme.md5sum
sha256sum -c masomme.md5sum || echo "Le fichier téléchargé [$NOM_CLE_SECURISATION_REPO_ORACLE_VBOX_DEBIAN_9] a été corrompu, il ne correspond pas à la somme de contrôle 'MD5' fournie par Oracle : [$(cat masomme.md5sum)] " && exit 1

# Et maintenant que l'on s'est assuré que toutes les vérifications ont été menées avec tous les voyants au vert : 
sudo apt-key add oracle_vbox_2016.asc

```
Enfin, toujours à l'URI de la racine du repo de backport debian maintenu par Oracle, j'ai trouvé deux autres clés `PGP`, qu'il faut manifestement aussi vérifier et pour lesquelles il faut configurer le package manager avec `apt-key add $NOM_FICHIER_CLE_PGP.asc` : 

* `oracle_vbox.asc` : http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
* `sun_vbox.asc` : http://download.virtualbox.org/virtualbox/debian/sun_vbox.asc

Pourquoi 3 signatures `PGP` à la racine du même repo ? 


# Installation par téléchargement de binaires distribués par Oracle

Je veux ici noter de plus, que sur le site officiel de `VirtualBox`, on trouve les liens de téléchargement de tous les binaires distribués par `Oracle`, ainsi que les `checksum` correspondant. Si bien qu'il est aussi possible d'installer virtualbox de la manière suivante : 

## Recette bash

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
sha256sum -c masomme.sha512sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.sha512sum)] " && exit 1

rm -f masomme.md5sum
cat MD5SUMS|grep *~Debian~stretch_amd64.deb >> masomme.md5sum
md5sum -c masomme.md5sum || echo "Le fichier téléchargé [$NOM_FICHIER_DEB_INSTALLATION_VBOX] a été corrompu, il ne correspond pas à la somme de contrôle fournie par Oracle : [$(cat masomme.md5sum)] "


# L'exécution du processus d'installation `sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX`  log une indication : 
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
# sudo /sbin/vboxconfig


# Exécution de l'installation du package debian : l'intégrité du package a été doublement vérifiée. 
sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX

echo "Et bingo, nous sommes bons :  lees dépendances du processus exécutant la commande [sudodpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX] ont toutes été correctement installées, "
echo "Notons : l'idéal sera, pour une recette de \"production\", d'installer ces dépendances avant même l'exécuation [dpkg -i \$NOM_FICHIER_PACKAGE_LINUX_DEBIAN]"



# Nous veneons d'installer un package debian (virutalbox), "manuellement", i.e. avec 'dpkg -i ....' :  
# Il peut lui manquer des dépendances.
# `apt-get` a la capacité de résoudre ces dépendances automatiquement, avec la commande : 
sudo apt-get -f install
```

## Remarques : Exécution de `sudo dpkg -i ./$NOM_FICHIER_DEB_INSTALLATION_VBOX`

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
sudo systemctl enable vboxballoonctrl-service
sudo systemctl enable vboxautostart-service
sudo systemctl enable vboxweb-service
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

* Dans le premier mode d'installation, on a une installation "propre", par le package manager, avec les garanties fournies par le repository, quant à la résolution automatique des dépendances, et l'intégration à l'instance d'OS. Toutefois, pour ce mode d'installation, quelques problématiques de sécurité se posent, et l'application d'une politique de gestion de la sécurité est difficile avec cette solution de provision de `VirtualBox`.
* Dans le second mode d'installation : 
  * j'ai une procédure de sécurité qui constitue un cycle complet  : il faut aller vérifier régulièrement de nouveaux contenus ont été publiés par Oracle sur virtualbox.org
  * une installation que je dois concenvoir entièrement au lieu de laisser faire le package manager, 
  * j'obtiens manifestement avec cette méthode d'installation, une version plus récente de virutalbox.

En conclusion, je pense que je suis là dans le cas typique pour lequel il serait jsutifié que je me monte moi-même mes repositories `apt-get` , `apk` et `yum` pour distribuer les paquets virutalbox les plus frais, tout en appliquant une politique de gestion de la sécurité aux contenu délivré par ce canal de distribution : 

* Il s'agit d'avoir dans un repository géré en interne, des versions plus récentes de virtualbox, quelle celles distribuées via le repository Oracle correspondant
* Il s'agit de régler un problème posé par l'installation avec `dpkg -i $NOM_FICHIER_LINUX_DEBIAN`  : en isnallant virtualbox de cette manière, la commandes `sudo apt-get update -y` et  `sudo apt-get upgrade -y`, n'impliqueront aucune mise à jour, ni aucune montée de verion de virtualbox, sur le `poste-devops-typique`.
* Et d'appliquer la politique de gestion del a éscurité en vigueur, sur ce nouveau canal de distribution, comme pour les  autres.

Voir, pour la gestion des repositories `apt-get` , `apk` et `yum` : 

* [`Redhat Satellite / Spacewalk`](https://spacewalkproject.github.io/) => pour `yum` / `CentOS`
* [`Pulp repository manager`](https://pulpproject.org/) => pour `apt-get` , `apk` / `Ubuntu`, `Debian`, `Alpine`


# Plus d'investigations : les 4 mystérieux

Lorsque l'on a analysé la procédure d'installaiton de virtualbox, on a pu remarquer la mention de 4 exécutables utilisables en tant que services de l'OS DEbian Stretch : 

* **`vboxdrv`** : il s'agit du `Linux Kernel Module` de `VirtualBox` , c'est à dire son composant principal (ce qui lui permet de faire de la virtualisation). Extrait de `sudo cat /usr/lib/virtualbox/vboxdrv.sh|more` : 

```bash
# Oracle VM VirtualBox
# Linux kernel module init script

#
# Copyright (C) 2006-2019 Oracle Corporation
#
# This file is part of VirtualBox Open Source Edition (OSE), as
# available from http://www.virtualbox.org. This file is free software;
# you can redistribute it and/or modify it under the terms of the GNU
# General Public License (GPL) as published by the Free Software
# Foundation, in version 2 as it comes in the "COPYING" file of the
# VirtualBox OSE distribution. VirtualBox OSE is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY of any kind.
#

# chkconfig: 345 20 80
# description: VirtualBox Linux kernel module
#
### BEGIN INIT INFO
# Provides:       vboxdrv
# Required-Start: $syslog
# Required-Stop:
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description: VirtualBox Linux kernel module
### END INIT INFO

```

* **`vboxballoonctrl-service`**   : j'ai trouvé https://www.virtualbox.org/manual/ch09.html#vboxwatchdog  il semblerait que le remplaçant en cours du `ballon controller` soit devenu un certain `watchdog`
* **`vboxautostart-service`** : Ce service permet de démarrer les VM choisies, au démarrage de l'OS de l'hôte de virtualisation (la machine sur laquelle est intallé virutalbox), et réciproquement, d'arrêter (correctement) l'exécution de VMs, avec l'arrêt (correct) de l'OS de l'hôte de virtualisation. cf. https://pgaskin.net/linux-tips/configuring-virtualbox-autostart/  .
* **`vboxweb-service`** :   est lié au composant **`vboxwebsrv`**, comme le montre le script [`vboxweb-service.sh`](https://www.virtualbox.org/svn/vbox/trunk/src/VBox/Installer/linux/vboxweb-service.sh) qui permet de contrôle `VirtualBox` à distance, via une (pseudo) REST API.    cf. https://www.virtualbox.org/manual/ch09.html#vboxwebsrv-daemon 

# Contrôle à distance de VirtualBox par SOAP API

Je cite la documentation officielle de `VirtualBox`, version `6.0.4`, dite [`VirtualBox Programming Guide And References`[(http://download.virtualbox.org/virtualbox/SDKRef.pdf)  : 


> VirtualBox comes with a web service that maps nearly the entire Main API. The web service ships in a standalone executable (`vboxwebsrv`) that, when running, acts as an HTTP server, accepts `SOAP` connections and processes them.


Il est possible de customiser l'autyhentification qui est faite auprès du serveur hébergeant le endpoint SAOP, à savoir `vboxwebsrv`, grâce à une indication donnée dans le `Programming guide` : 

> The IWebsessionManager::logon() API takes a user name and a password as arguments, which the web service then passes to a customizable authentication plugin that performs the actual authentication.
> For testing purposes, it is recommended that you first disable authentication with this com-
mand : 

```bash
VBoxManage setproperty websrvauthlibrary null
```

Donc, l'implémentation que je dois gfournir doit certainement être la fameuse `websrvauthlibrary`


* Comment configurer `username` et `password` pour le serveur `vboxwebsrv` ? 
* Comment configurer une VM pour qu'elle démarre avec l'hôte de vritualisation `VirtualBox` ? https://pgaskin.net/linux-tips/configuring-virtualbox-autostart/




### Démarrer le serveur 

Il faut juste fixer des varaibles d'envrionnement, et utiliser éventuellement des options d'invocation d'exécutable `GNU`  : 

où retrouver ce tableau pour le terminer : https://www.virtualbox.org/manual/ch09.html#vboxwebsrv-daemon

| Parameter | Description | default |
| ------| ------| ------|
| `USER` | ccc | `ccc` |
| `HOST` | ccc | `ccc` |
| `PORT` | ccc | `ccc` |
| `SSL_KEYFILE` | ccc | ...? |
| `SSL_PASSWORDFILE` | ccc | ...? |
| `SSL_CACERT` | ccc | ...? |
| `SSL_CAPATH` | CA certificate path | ...? |
| `SSL_DHFILE` | DH file name or DH key length in bits | ...? |
| `SSL_RANDFILE` | File containing seed for random number generator | ...? |
| `TIMEOUT` | Session timeout in seconds, 0 disables timeouts  | `300` |
| `CHECK_INTERVAL` | Frequency of timeout checks in seconds | `5` |
| `THREADS` | Maximum number of worker threads to run in parallel  | `100` |
| `KEEPALIVE` | Maximum number of requests before a socket will be closed | `100` |
| `ROTATE` | Number of log files, 0 disables log rotation | `10` |
| `LOGSIZE` | Maximum log file size to trigger rotation, in bytes  | `1MB` |
| `LOGINTERVAL` | Maximum time interval to trigger log rotation, in seconds | 1 day = `24 * 60 * 60 ` seconds |


