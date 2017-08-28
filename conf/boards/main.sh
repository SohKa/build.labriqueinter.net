#!/bin/bash

chroot_deb $DEBOOTSTRAP_DIR "$APT linux-image-armmp u-boot-tools ca-certificates openssh-server ntp parted locales vim-nox bash-completion rng-tools"

echo 'HRNGDEVICE=/dev/urandom' >> $DEBOOTSTRAP_DIR/etc/default/rng-tools
echo '. /etc/bash_completion' >> $DEBOOTSTRAP_DIR/root/.bashrc

# Debootstrap optimisations from igorpecovnik
# change default I/O scheduler, noop for flash media, deadline for SSD, cfq for mechanical drive
cat <<EOT >> $DEBOOTSTRAP_DIR/etc/sysfs.conf
block/mmcblk0/queue/scheduler = noop
#block/sda/queue/scheduler = cfq
EOT

# flash media tunning
if [ -f "$DEBOOTSTRAP_DIR/etc/default/tmpfs" ]; then
  sed -e 's/#RAMTMP=no/RAMTMP=yes/g' -i $DEBOOTSTRAP_DIR/etc/default/tmpfs
  sed -e 's/#RUN_SIZE=10%/RUN_SIZE=128M/g' -i $DEBOOTSTRAP_DIR/etc/default/tmpfs
  sed -e 's/#LOCK_SIZE=/LOCK_SIZE=/g' -i $DEBOOTSTRAP_DIR/etc/default/tmpfs
  sed -e 's/#SHM_SIZE=/SHM_SIZE=128M/g' -i $DEBOOTSTRAP_DIR/etc/default/tmpfs
  sed -e 's/#TMP_SIZE=/TMP_SIZE=1G/g' -i $DEBOOTSTRAP_DIR/etc/default/tmpfs
fi

# Generate locales
sed -i "s/^# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
sed -i "s/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
chroot_deb $DEBOOTSTRAP_DIR "locale-gen en_US.UTF-8"

# Update timezone
echo 'Europe/Paris' > $DEBOOTSTRAP_DIR/etc/timezone
chroot_deb $DEBOOTSTRAP_DIR "dpkg-reconfigure -f noninteractive tzdata"

# Add fstab for root
chroot_deb $DEBOOTSTRAP_DIR "echo '/dev/mmcblk0p1 / ext4     defaults        0       1' >> /etc/fstab"
# Configure tty
cat <<EOT > $DEBOOTSTRAP_DIR/etc/init/ttyS0.conf
start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty --noclear 115200 ttyS0
EOT
chroot_deb $DEBOOTSTRAP_DIR 'cp /lib/systemd/system/serial-getty@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service'
chroot_deb $DEBOOTSTRAP_DIR 'sed -e s/"--keep-baud 115200,38400,9600"/"-L 115200"/g -i /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service'
chroot_deb $DEBOOTSTRAP_DIR "sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config"

# Good right on some directories
chroot_deb $DEBOOTSTRAP_DIR 'chmod 1777 /tmp/'
chroot_deb $DEBOOTSTRAP_DIR 'chgrp mail /var/mail/'
chroot_deb $DEBOOTSTRAP_DIR 'chmod g+w /var/mail/'
chroot_deb $DEBOOTSTRAP_DIR 'chmod g+s /var/mail/'

# Jessie Stuff TOREMOVE
#chroot_deb $DEBOOTSTRAP_DIR "wget -P /tmp/ https://repo.labriqueinter.net/u-boot/u-boot-sunxi_latest_armhf.deb"
#chroot_deb $DEBOOTSTRAP_DIR "dpkg -i /tmp/u-boot-sunxi_latest_armhf.deb"

# Set hostname
echo $DEB_HOSTNAME > $DEBOOTSTRAP_DIR/etc/hostname
sed -i "1i127.0.1.1\t${DEB_HOSTNAME}" $DEBOOTSTRAP_DIR/etc/hosts

# Add 'olinux' for root password and force to change it at first login
chroot_deb $DEBOOTSTRAP_DIR '(echo olinux;echo olinux;) | passwd root'
chroot_deb $DEBOOTSTRAP_DIR 'chage -d 0 root'

