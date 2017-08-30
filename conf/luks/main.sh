#!/bin/bash

#umount_dir $DEBOOTSTRAP_DIR
#chroot_deb $DEBOOTSTRAP_DIR 'apt-get update'
#chroot_deb $DEBOOTSTRAP_DIR 'apt-get upgrade -y --force-yes'

echo 'aes' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'aes_x86_64' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'aes_generic' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'dm-crypt' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'dm-mod' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'sha256' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'sha256_generic' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'lrw' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'xts' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'crypto_blkcipher' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'gf128mul' >> $DEBOOTSTRAP_DIR/etc/initramfs-tools/modules
echo 'root    /dev/mmcblk0p2  none    luks' >> $DEBOOTSTRAP_DIR/etc/crypttab
echo '/dev/mapper/root        /       ext4    defaults        0       1' > $DEBOOTSTRAP_DIR/etc/fstab
echo '/dev/mmcblk0p1  /boot   ext4    defaults        0       2' >> $DEBOOTSTRAP_DIR/etc/fstab
sed -i -e 's#DEVICE=#DEVICE=eth0#' $DEBOOTSTRAP_DIR/etc/initramfs-tools/initramfs.conf
cp $DIR/conf/luks/scripts/initramfs/cryptroot $DEBOOTSTRAP_DIR/etc/initramfs-tools/hooks/cryptroot
cp $DIR/conf/luks/scripts/initramfs/httpd $DEBOOTSTRAP_DIR/etc/initramfs-tools/hooks/httpd
cp $DIR/conf/luks/scripts/initramfs/httpd_start $DEBOOTSTRAP_DIR/etc/initramfs-tools/scripts/local-top/httpd
cp $DIR/conf/luks/scripts/initramfs/httpd_stop $DEBOOTSTRAP_DIR/etc/initramfs-tools/scripts/local-bottom/httpd
cp $DIR/conf/luks/scripts/initramfs/stunnel $DEBOOTSTRAP_DIR/etc/initramfs-tools/hooks/stunnel
cp $DIR/conf/luks/scripts/initramfs/stunnel.conf $DEBOOTSTRAP_DIR/etc/initramfs-tools/
cp $DIR/conf/luks/scripts/initramfs/stunnel_start $DEBOOTSTRAP_DIR/etc/initramfs-tools/scripts/local-top/stunnel
cp $DIR/conf/luks/scripts/initramfs/stunnel_stop $DEBOOTSTRAP_DIR/etc/initramfs-tools/scripts/local-bottom/stunnel
mkdir -p $DEBOOTSTRAP_DIR/etc/initramfs-tools/root
cp -r $DIR/conf/luks/scripts/initramfs/www $DEBOOTSTRAP_DIR/etc/initramfs-tools/root/

# stunnel bug with truncated files
echo 'deb http://ftp.fr.debian.org/debian jessie-backports main' > $DEBOOTSTRAP_DIR/etc/apt/sources.list.d/jessie-backports.list
chroot_deb $DEBOOTSTRAP_DIR 'apt-get update'
chroot_deb $DEBOOTSTRAP_DIR "$APT -t jessie-backports stunnel4"

chroot_deb $DEBOOTSTRAP_DIR "$APT dropbear busybox cryptsetup"

echo 'LINUX_KERNEL_CMDLINE="console=ttyS1 hdmi.audio=EDID:0 disp.screen0_output_mode=EDID:1280x720p60 root=/dev/mapper/root cryptopts=target=root,source=/dev/mmcblk0p2,cipher=aes-xts-plain64,size=256,hash=sha1 rootwait sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_no_mali_mem_reserve sunxi_fb_mem_reserve=0 panic=10 loglevel=6 consoleblank=0"' > $DEBOOTSTRAP_DIR/etc/default/flash-kernel

chroot_deb $DEBOOTSTRAP_DIR "update-initramfs -k all -u"
