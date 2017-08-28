#!/bin/bash

echo 'LINUX_KERNEL_CMDLINE="console=ttyS1 hdmi.audio=EDID:0 disp.screen0_output_mode=EDID:1280x720p60 root=/dev/mmcblk0p1 rootwait sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_no_mali_mem_reserve sunxi_fb_mem_reserve=0 panic=10 loglevel=6 consoleblank=0"' > $DEBOOTSTRAP_DIR/etc/default/flash-kernel

mkdir -p $DEBOOTSTRAP_DIR/etc/flash-kernel
echo $FLASH_KERNEL > $DEBOOTSTRAP_DIR/etc/flash-kernel/machine
chroot_deb $DEBOOTSTRAP_DIR "$APT flash-kernel u-boot u-boot-tools"
echo $FLASH_KERNEL > $DEBOOTSTRAP_DIR/etc/flash-kernel/machine
chroot_deb $DEBOOTSTRAP_DIR "update-initramfs -k all -u"

# Use dhcp on boot
cat <<EOT > $DEBOOTSTRAP_DIR/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
  post-up ip a a fe80::42:babe/128 dev eth0

auto usb0
allow-hotplug usb0
iface usb0 inet dhcp
EOT

