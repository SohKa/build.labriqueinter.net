#!/bin/bash

# Configure debian apt repository
cat <<EOT > $DEBOOTSTRAP_DIR/etc/apt/sources.list
deb http://ftp.fr.debian.org/debian $DEBIAN_RELEASE main contrib non-free
deb http://security.debian.org/ $DEBIAN_RELEASE/updates main contrib non-free
EOT
cat <<EOT > $DEBOOTSTRAP_DIR/etc/apt/apt.conf.d/71-no-recommends
APT::Install-Suggests "0";
EOT

if [ ${APTCACHER} ] ; then
 cat <<EOT > $DEBOOTSTRAP_DIR/etc/apt/apt.conf.d/01proxy
Acquire::http::Proxy "http://${APTCACHER}:3142";
EOT
 # if we are in docker and chroot and we want to have proxy resolvedi
 cp $DEBOOTSTRAP_DIR/etc/hosts $DEBOOTSTRAP_DIR/tmp
 cp /etc/hosts $DEBOOTSTRAP_DIR/etc/
fi

if [ ${APTCACHER} ] ; then
 cat <<EOT > $DEBOOTSTRAP_DIR/etc/apt/apt.conf.d/01proxy
Acquire::http::Proxy "http://${APTCACHER}:3142";
EOT
 # if we are in docker and chroot and we want to have proxy resolvedi
 cp $DEBOOTSTRAP_DIR/etc/hosts $DEBOOTSTRAP_DIR/tmp
 cp /etc/hosts $DEBOOTSTRAP_DIR/etc/
fi

chroot_deb $DEBOOTSTRAP_DIR 'apt-get update'
