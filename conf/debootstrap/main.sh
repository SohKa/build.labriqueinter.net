#!/bin/bash

# Debootstrap
if [ ${CROSS} ] ; then
  if ! mount | grep -q binfmt_misc ; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    bash ${REP}/contrib/binfmt-misc-arm.sh unregister
    bash ${REP}/contrib/binfmt-misc-arm.sh
  fi
  if [ ${APTCACHER} ] ; then
    debootstrap --arch=armhf --foreign $DEBIAN_RELEASE $DEBOOTSTRAP_DIR http://${APTCACHER}:3142/ftp.fr.debian.org/debian/
  else
    debootstrap --arch=armhf --foreign $DEBIAN_RELEASE $DEBOOTSTRAP_DIR
  fi
  cp /usr/bin/qemu-arm-static $DEBOOTSTRAP_DIR/usr/bin/
  mv $DEBOOTSTRAP_DIR/etc/resolv.conf $DEBOOTSTRAP_DIR/etc/resolv.conf.old
  cp /etc/resolv.conf $DEBOOTSTRAP_DIR/etc
  chroot_deb $DEBOOTSTRAP_DIR '/debootstrap/debootstrap --second-stage'
elif [ ${APTCACHER} ] ; then
 debootstrap $DEBIAN_RELEASE $DEBOOTSTRAP_DIR http://${APTCACHER}:3142/ftp.fr.debian.org/debian/
else
 debootstrap $DEBIAN_RELEASE $DEBOOTSTRAP_DIR
fi

echo '/dev/mmcblk0p1 / ext4 rw,relatime 0 0' > $DEBOOTSTRAP_DIR/etc/mtab

# Generate locales
chroot_deb $DEBOOTSTRAP_DIR "$APT locales"
sed -i "s/^# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
sed -i "s/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
chroot_deb $DEBOOTSTRAP_DIR "locale-gen en_US.UTF-8"
