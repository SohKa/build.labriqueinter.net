#!/bin/bash

mkdir -p $DEBOOTSTRAP_DIR/etc/flash-kernel
echo $FLASH_KERNEL > $DEBOOTSTRAP_DIR/etc/flash-kernel/machine
chroot_deb $DEBOOTSTRAP_DIR "$APT flash-kernel u-boot u-boot-tools"
echo $FLASH_KERNEL > $DEBOOTSTRAP_DIR/etc/flash-kernel/machine
chroot_deb $DEBOOTSTRAP_DIR "update-initramfs -k all -u"

echo 'b53_mdio' > $DEBOOTSTRAP_DIR/etc/modules
install -m 444 -o root -g root $DIR/conf/boards/bananapir1/scripts/br0 $DEBOOTSTRAP_DIR/etc/network/interfaces.d/
install -m 444 -o root -g root $DIR/conf/boards/bananapir1/scripts/wifi $DEBOOTSTRAP_DIR/etc/network/interfaces.d/
install -m 444 -o root -g root $DIR/conf/boards/bananapir1/scripts/wire $DEBOOTSTRAP_DIR/etc/network/interfaces.d/
install -m 755 -o root -g root $DIR/conf/boards/bananapir1/scripts/interface_up.sh $DEBOOTSTRAP_DIR/etc/network/
install -m 755 -o root -g root $DIR/conf/boards/bananapir1/scripts/interface_down.sh $DEBOOTSTRAP_DIR/etc/network/
