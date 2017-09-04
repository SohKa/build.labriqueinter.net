#!/bin/bash

# Add HyperCube packages
chroot_deb $DEBOOTSTRAP_DIR "$APT jq udisks-glue php5-fpm ntfs-3g"

# Add hypercube init script
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube.sh $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube-webserver.py $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube.service $DEBOOTSTRAP_DIR/etc/systemd/system/
chroot_deb $DEBOOTSTRAP_DIR "/bin/systemctl enable hypercube >> /dev/null"

# Add hypercube scripts
mkdir -p $DEBOOTSTRAP_DIR/var/log/hypercube
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/install.html $DEBOOTSTRAP_DIR/var/log/hypercube/
