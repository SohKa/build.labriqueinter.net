#!/bin/bash

set -e
set -x

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

cd /opt/sunxi-debian && git pull

# Remove '-s' option if you want to compile using GIT (for kernel and u-boot)
/opt/sunxi-debian/olinux/create_sunxi_boot_files.sh -l Labriqueinter.net \
 -t /srv/olinux/sunxi -s | tee /srv/olinux/sunxi.log

/opt/sunxi-debian/olinux/create_arm_debootstrap.sh -i /srv/olinux/sunxi/ \
 -t /srv/olinux/debootstrap -p -y | tee /srv/olinux/debootstrap.log

cp /srv/olinux/sunxi.log /srv/olinux/debootstrap.log /srv/olinux/debootstrap/root/
# partitioning doesn't work with losetup on my board...
#/opt/sunxi-debian/olinux/create_device.sh -d img -s 1200 \
# -t /srv/olinux/yunohost_lime.img -b /srv/olinux/debootstrap

# Lime1 archive
tar --same-owner --preserve-permissions -cvf \
 /srv/olinux/labriqueinternet_lime1_"$(date '+%d-%m-%Y')".tar \
 -C /srv/olinux/debootstrap .

# Lime2 archive (change symlink) 
cd /srv/olinux/debootstrap && rm boot/board.dtb &&
	ln -s boot/dtb/sun7i-a20-olinuxino-lime2.dtb boot/board.dtb
# Lime2 archive
tar --same-owner --preserve-permissions -cvf \
 /srv/olinux/labriqueinternet_lime2_"$(date '+%d-%m-%Y')".tar \
 -C /srv/olinux/debootstrap .


