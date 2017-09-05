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
  cp /etc/resolv.conf $DEBOOTSTRAP_DIR/etc
  chroot_deb $DEBOOTSTRAP_DIR '/debootstrap/debootstrap --second-stage'
elif [ ${APTCACHER} ] ; then
 debootstrap $DEBIAN_RELEASE $DEBOOTSTRAP_DIR http://${APTCACHER}:3142/ftp.fr.debian.org/debian/
else
 debootstrap $DEBIAN_RELEASE $DEBOOTSTRAP_DIR
fi

echo '/dev/mmcblk0p1 / ext4 rw,relatime 0 0' > $DEBOOTSTRAP_DIR/etc/mtab

# Set hostname
echo $DEB_HOSTNAME > $DEBOOTSTRAP_DIR/etc/hostname
sed -i "1i127.0.1.1\t${DEB_HOSTNAME}" $DEBOOTSTRAP_DIR/etc/hosts

# Generate locales
chroot_deb $DEBOOTSTRAP_DIR "$APT locales"
sed -i "s/^# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
sed -i "s/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" $DEBOOTSTRAP_DIR/etc/locale.gen
chroot_deb $DEBOOTSTRAP_DIR "locale-gen en_US.UTF-8"

#chroot_deb $DEBOOTSTRAP_DIR "/usr/sbin/rsyslogd"

#chroot_deb $DEBOOTSTRAP_DIR "mount -o remount,rw -t sysfs sysfs /sys"

if [ ${CROSS} ] ; then
  # https://anonscm.debian.org/cgit/d-i/debootstrap.git/tree/scripts/sid?id=c4ad96b3972426df3d261d33a5025335fef86f79#n159
  chroot_deb $DEBOOTSTRAP_DIR "cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
echo \"All runlevel operations denied by policy\" >&2
exit 101
EOF"
  chroot_deb $DEBOOTSTRAP_DIR "chmod +x /usr/sbin/policy-rc.d"
  chroot_deb $DEBOOTSTRAP_DIR "mv /sbin/start-stop-daemon{,.REAL}"
  chroot_deb $DEBOOTSTRAP_DIR "cat > /sbin/start-stop-daemon << EOF
#!/bin/sh
echo \"Warning: Fake start-stop-daemon called, doing nothing\"
exit 0
EOF"
  chroot_deb $DEBOOTSTRAP_DIR "chmod +x /sbin/start-stop-daemon"
fi

