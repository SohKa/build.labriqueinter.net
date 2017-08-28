#!/bin/bash

# Remove useless files
chroot_deb $DEBOOTSTRAP_DIR 'apt-get clean'
rm -f $DEBOOTSTRAP_DIR/etc/resolv.conf
rm -f $DEBOOTSTRAP_DIR/etc/mtab

if [ ${CROSS} ] ; then
  rm -f $DEBOOTSTRAP_DIR/usr/bin/qemu-arm-static
fi

if [ ${APTCACHER} ] ; then
  rm -f $DEBOOTSTRAP_DIR/etc/apt/apt.conf.d/01proxy
  cp $DEBOOTSTRAP_DIR/tmp/hosts $DEBOOTSTRAP_DIR/etc/
fi
