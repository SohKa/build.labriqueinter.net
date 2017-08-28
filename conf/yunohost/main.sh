#!/bin/bash

chroot_deb $DEBOOTSTRAP_DIR "mkdir -p /run/systemd/system/"

# Hack; install mariadb-server before yunohost to prevent falure durring yunohost install 
chroot_deb $DEBOOTSTRAP_DIR "$APT mariadb-server"

chroot_deb $DEBOOTSTRAP_DIR "$APT git"
chroot_deb $DEBOOTSTRAP_DIR "git clone https://github.com/YunoHost/install_script /tmp/install_script"
chroot_deb $DEBOOTSTRAP_DIR "cd /tmp/install_script && ./install_yunohost -a -d ${INSTALL_YUNOHOST_DIST}"

chroot_deb $DEBOOTSTRAP_DIR "rmdir /run/systemd/system/ /run/systemd/ 2> /dev/null || true"

