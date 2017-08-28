#!/bin/bash

# Add HyperCube packages
chroot_deb $DEBOOTSTRAP_DIR "$APT jq udisks-glue php5-fpm ntfs-3g"

# Add firstrun and secondrun init script
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/firstrun $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/secondrun $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube.sh $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 755 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube-webserver.py $DEBOOTSTRAP_DIR/usr/local/bin/
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/firstrun.service $DEBOOTSTRAP_DIR/etc/systemd/system/
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/secondrun.service $DEBOOTSTRAP_DIR/etc/systemd/system/
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/hypercube.service $DEBOOTSTRAP_DIR/etc/systemd/system/
#chroot_deb $DEBOOTSTRAP_DIR "/bin/systemctl daemon-reload >> /dev/null"
chroot_deb $DEBOOTSTRAP_DIR "/bin/systemctl enable firstrun >> /dev/null"
chroot_deb $DEBOOTSTRAP_DIR "/bin/systemctl enable hypercube >> /dev/null"

# Add hypercube scripts
mkdir -p $DEBOOTSTRAP_DIR/var/log/hypercube
install -m 444 -o root -g root $DIR/conf/labriqueinternet/scripts/hypercube/install.html $DEBOOTSTRAP_DIR/var/log/hypercube/
