#!/bin/bash

if [ ${CROSS} ] ; then
  # Warning! Crappy hack; install mysql-server before yunohost to prevent falure durring yunohost install

  chroot_deb $DEBOOTSTRAP_DIR "debconf-set-selections << EOF
mysql-server-5.5 mysql-server/root_password password yunohost
mysql-server-5.5 mysql-server/root_password_again password yunohost
mariadb-server-10.0 mysql-server/root_password password yunohost
mariadb-server-10.0 mysql-server/root_password_again password yunohost
EOF"

  chroot_deb $DEBOOTSTRAP_DIR "$APT mysql-server"
  chroot_deb $DEBOOTSTRAP_DIR "$APT mariadb-server"
  chroot_deb $DEBOOTSTRAP_DIR "dpkg --list |grep \"^rc\" | cut -d \" \" -f 3 | xargs dpkg --purge"
fi

chroot_deb $DEBOOTSTRAP_DIR "$APT git"
chroot_deb $DEBOOTSTRAP_DIR "git clone https://github.com/YunoHost/install_script /tmp/install_script"
chroot_deb $DEBOOTSTRAP_DIR "cd /tmp/install_script && ./install_yunohost -a -d ${INSTALL_YUNOHOST_DIST}"
