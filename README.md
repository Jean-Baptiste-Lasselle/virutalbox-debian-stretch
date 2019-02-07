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

# puis installation virtualbox
sudo apt-get install -y virtualbox

```
