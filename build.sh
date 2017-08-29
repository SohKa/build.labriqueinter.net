#!/bin/bash

######################
#    Debootstrap     #
######################

set -e
set -x

show_usage() {
cat <<EOF
# NAME

  $(basename $0) -- Script to create labriqueinternet for several boards 

# OPTIONS

  -b            coma-separated list of olinux boards    (default: all)
  -a            add packages to deboostrap
  -n            hostname                                (default: olinux)
  -t            target directory for debootstrap        (default: ./tmp/debootstrap)
  -y            install yunohost (doesn't work with cross debootstrap)
  -r            debian release                          (default: jessie)
  -d            yunohost distribution                   (default: stable)
  -c            cross debootstrap
  -p            use and set aptcacher proxy
  -e            configure for encrypted partition       (default: false)

EOF
exit 1
}

DEBIAN_RELEASE=jessie
DIR=/srv/build-labriqueinternet/src
BUILD_DIR=/srv/build-labriqueinternet/build
DEBOOTSTRAP_DIR=$BUILD_DIR/debootstrap
DEB_HOSTNAME=olinux
REP=$(dirname $0)
APT='DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes'
INSTALL_YUNOHOST_DIST='stable'
BOARDS="all"
FORCE_DEBOOTSTRAP=no
INSTALL_YUNOHOST=yes

while getopts ":a:b:n:t:d:r:ycp:e" opt; do
  case $opt in
    b)
      BOARDS=$OPTARG
      ;;
    a)
      PACKAGES=$OPTARG
      ;;
    n)
      DEB_HOSTNAME=$OPTARG
      ;;
    t)
      DEBOOTSTRAP_DIR=$OPTARG
      ;;
    y)
      INSTALL_YUNOHOST=yes
      ;;
    d)
      INSTALL_YUNOHOST_DIST=$OPTARG
      ;;
    r)
      DEBIAN_RELEASE=$OPTARG
      ;;
    c)
      CROSS=yes
      ;;
    p)
      APTCACHER=$OPTARG
      ;;
    e)
      ENCRYPT=yes
      ;;
    \?)
      show_usage
      ;;
  esac
done


OPTIND=1

chroot_deb (){
  LC_ALL=C LANGUAGE=C LANG=C chroot $1 /bin/bash -c "$2"
}


mount_dir (){
  mount --bind /proc $1/proc
  mount --bind /sys $1/sys
  mount --bind /dev $1/dev
  mount --bind /dev/pts $1/dev/pts
}

umount_dir (){
  # Umount proc, sys, and dev
  umount -l "$1"/proc
  umount -l "$1"/sys
  umount -l "$1"/dev/pts
  umount -l "$1"/dev
}

finish(){
  umount_dir $DEBOOTSTRAP_DIR
}
trap finish EXIT

mkdir -p $DIR $BUILD_DIR

if [ "${INSTALL_YUNOHOST_DIST}" != stable ]; then
  INSTALL_YUNOHOST_TESTING="-testing"
fi

# deboostrap
if [ ! -d $DEBOOTSTRAP_DIR ] || [ $FORCE_DEBOOTSTRAP == 'yes' ]; then
  rm -rf $DEBOOTSTRAP_DIR && mkdir -p $DEBOOTSTRAP_DIR
  . $DIR/conf/debootstrap/main.sh
  . $DIR/conf/debootstrap/apt.sh
else
  . $DIR/conf/debootstrap/arm.sh
fi

mount_dir $DEBOOTSTRAP_DIR

if [ ! -d "$DEBOOTSTRAP_DIR/etc/yunohost" ] && [ $INSTALL_YUNOHOST == 'yes' ]; then
  . $DIR/conf/yunohost/main.sh
fi

BASE_DEBOOTSTRAP_DIR=${DEBOOTSTRAP_DIR}

if [ ${BOARDS} == "all" ]; then
  BOARD_LIST=($(ls -d $DIR/conf/boards/*/))
else
  BOARD_LIST=(${BOARDS//,/ })
fi

. $DIR/conf/boards/main.sh
. $DIR/conf/labriqueinternet/main.sh

umount_dir $DEBOOTSTRAP_DIR

if [ $BOARDS != 'none' ]; then

  # Configure each boards
  for i in "${BOARD_LIST[@]}"; do
    . ${i}config.sh
    rm -rf ${BASE_DEBOOTSTRAP_DIR}-${NAME}
    cp -ra $BASE_DEBOOTSTRAP_DIR ${BASE_DEBOOTSTRAP_DIR}-${NAME}
    DEBOOTSTRAP_DIR=${BASE_DEBOOTSTRAP_DIR}-${NAME}
    . ${i}main.sh
    if [ $ENCRYPT ]; then
      rm -rf ${BASE_DEBOOTSTRAP_DIR}-${NAME}-encrypted
      cp -ra ${BASE_DEBOOTSTRAP_DIR}-${NAME} ${BASE_DEBOOTSTRAP_DIR}-${NAME}-encrypted
      DEBOOTSTRAP_DIR=${BASE_DEBOOTSTRAP_DIR}-${NAME}-encrypted
      . $DIR/conf/luks/main.sh
    fi
  done

  # Clean debootstrap directories
  for i in $BUILD_DIR/debootstrap*/ ; do
    DEBOOTSTRAP_DIR=$i
    . $DIR/conf/debootstrap/clean.sh
  done 

  # Create img
  for i in "${BOARD_LIST[@]}"; do
    . ${i}config.sh
    DEBOOTSTRAP_DIR=${BASE_DEBOOTSTRAP_DIR}-${NAME}
    . $DIR/conf/images/main.sh
    if [ $ENCRYPT ]; then
      ENCRYPTED="-encrypted"
      DEBOOTSTRAP_DIR=${BASE_DEBOOTSTRAP_DIR}-${NAME}-encrypted
      . $DIR/conf/images/main.sh
      unset ENCRYPTED
    fi
  done

fi

finish(){
  exit 0
}

exit 0
