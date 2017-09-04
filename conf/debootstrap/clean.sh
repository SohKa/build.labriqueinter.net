#!/bin/bash

# Remove useless files
chroot_deb $DEBOOTSTRAP_DIR 'apt-get clean'
mv $DEBOOTSTRAP_DIR/etc/resolv.conf.old $DEBOOTSTRAP_DIR/etc/resolv.conf || true
rm -f $DEBOOTSTRAP_DIR/etc/mtab

chroot_deb $DEBOOTSTRAP_DIR "mv /sbin/start-stop-daemon{.REAL,}"
chroot_deb $DEBOOTSTRAP_DIR "rm /usr/sbin/policy-rc.d"

if [ ${CROSS} ] ; then
  rm -f $DEBOOTSTRAP_DIR/usr/bin/qemu-arm-static
fi

if [ ${APTCACHER} ] ; then
  rm -f $DEBOOTSTRAP_DIR/etc/apt/apt.conf.d/01proxy
  cp $DEBOOTSTRAP_DIR/tmp/hosts $DEBOOTSTRAP_DIR/etc/
fi

