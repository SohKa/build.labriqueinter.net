#!/bin/bash

# Debootstrap
if [ ${CROSS} ] ; then
  if ! mount | grep -q binfmt_misc ; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    bash ${REP}/contrib/binfmt-misc-arm.sh unregister
    bash ${REP}/contrib/binfmt-misc-arm.sh
  fi
  cp /usr/bin/qemu-arm-static $DEBOOTSTRAP_DIR/usr/bin/
fi
mv $DEBOOTSTRAP_DIR/etc/resolv.conf $DEBOOTSTRAP_DIR/etc/resolv.conf.old
cp /etc/resolv.conf $DEBOOTSTRAP_DIR/etc
