#!/bin/bash

TARGET=$DIR_BUILD/labriqueinternet_${NAME}_"$(date '+%Y-%m-%d')"_${DEBIAN_RELEASE}${INSTALL_YUNOHOST_TESTING}${ENCRYPTED}.img
MNT1=$DIR_BUILD/dest
MNT2=$DIR_BUILD/source
IMGSIZE=1500
DEVICE=img

mkdir -p $MNT1
mkdir -p $MNT2

echo "[INFO] Create image."
rm -f ${TARGET}
# create image file
dd if=/dev/zero of=${TARGET} bs=1MB count=$IMGSIZE status=noxfer

# find first avaliable free device
DEVICE=$(losetup -f)
IMGSIZE="100%"

# mount image as block device
losetup $DEVICE ${TARGET}

finish() {
  echo "[INFO] Umount"
  losetup -d $DEVICE
}
trap finish EXIT

sync

echo "[INFO] Partitioning"
parted --script $DEVICE mklabel msdos
parted --script $DEVICE mkpart primary ext4 2048s ${IMGSIZE}
parted --script $DEVICE align-check optimal 1

# I know UUUgly hack...
sleep 20
partprobe $DEVICE 

DEVICEP1=${DEVICE}p1
DEVICEP2=${DEVICE}p2

echo "[INFO] Formating"
# create filesystem
if mke2fs -V 2>&1 | grep -q ' 1\.42\.'; then
  mkfs.ext4 $DEVICEP1 >/dev/null 2>&1
else
  mkfs.ext4 -O ^metadata_csum,^64bit $DEVICEP1
fi

# tune filesystem
tune2fs -o journal_data_writeback $DEVICEP1

finish() {
  echo "[INFO] Umount"
  umount $MNT1
  losetup -d $DEVICE
}
trap finish EXIT

echo "[INFO] Mount filesystem"
mount -t ext4 $DEVICEP1 $MNT1

echo "[INFO] Copy bootstrap files"
cp -ar ${DEBOOTSTRAP_DIR}/* $MNT1/
sync

echo "[INFO] Write sunxi-with-spl"
dd if=$MNT1/usr/lib/u-boot/${U_BOOT}/u-boot-sunxi-with-spl.bin of=${DEVICE} bs=1024 seek=8
sync

umount $MNT1

echo "[INFO] zerofree"
zerofree $DEVICEP1  
losetup -d $DEVICE

