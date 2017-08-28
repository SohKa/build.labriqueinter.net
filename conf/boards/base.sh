#!/bin/bash

chroot_deb $DEBOOTSTRAP_DIR "$APT ca-certificates openssh-server ntp parted locales vim-nox bash-completion rng-tools"


