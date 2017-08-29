**[BUG REPORTS SHOULD BE OPENED HERE](https://dev.yunohost.org)**

# How to Build

This README describes how we currently build the Internet Cube images. You can choose between two methods: with a dedicated cube for building, or with a virtualization layer on your laptop.

## Images to Produce

For now, we support only 2 boards: Olimex LIME and Olimex LIME2. We produce 2 images for each board: for encrypted installations and for non-encrypted ones.

Example of image filenames (e.g. with build on December 1st, 2017 for Debian Jessie):

* LIME non-encrypted: *labriqueinternet_A20LIME_2017-12-01_jessie.img.tar.xz*
* LIME encrypted: *labriqueinternet_A20LIME_encryptedfs_2017-12-01_jessie.img.tar.xz*
* LIME2 non-encrypted: *labriqueinternet_A20LIME2_2017-12-01_jessie.img.tar.xz*
* LIME2 encrypted: *labriqueinternet_A20LIME2_encryptedfs_2017-12-01_jessie.img.tar.xz*

Respecting the format of the filenames is important to ensure the compatibility with *install-sd.sh*.

For generating (optional) GPG signatures, please ask on the *La Brique Internet*'s mailing list.

## Building With Virtualization

### Prepare a Docker Environment for Building

On your own laptop (with [Docker available](https://docs.docker.com/engine/installation/linux/docker-ce/debian/#install-docker-ce)):

```shell
sudo apt install git docker-ce
mkdir -p /tmp/build-labriqueinternet/{git,aptcacher,build}/
git clone https://github.com/labriqueinternet/build.labriqueinter.net.git /tmp/build-labriqueinternet/git/

sudo docker build -t debian:armhf -f /tmp/build-labriqueinternet/git/Dockerfile /tmp/build-labriqueinternet/git/
```

### Images Building

Build the images:

```shell
sudo docker run -d --name build-labriqueinternet-aptcacher -v /tmp/build-labriqueinternet/:/tmp/ debian:armhf apt-cacher-ng ForeGround=1 CacheDir=/tmp/aptcacher/
time sudo docker run --privileged -i -t -h build.labriqueinter.net --name build-labriqueinternet-main --link build-labriqueinternet-aptcacher:aptcacher -v /tmp/build-labriqueinternet/git/:/srv/ -v /tmp/build-labriqueinternet/build/:/srv/build/ debian:armhf bash /srv/build.sh -c -y -p aptcacher -e -b lime,lime2
```

After something like 30 minutes, the four images produced are available in */tmp/build-labriqueinternet/build/*.

When you have finished, you can clean your laptop:

```shell
sudo docker stop build-labriqueinternet-aptcacher
sudo docker rm build-labriqueinternet-main
sudo docker rm build-labriqueinternet-aptcacher
sudo rm -rf /tmp/build-labriqueinternet/
```

## Building With Native Platform

### Prepare a Dedicated Cube for Building

Choose a dedicated Internet Cube (or just a SD card), and use it to build the four images in the same time. Using a LIME or LIME2 does not matter.

Prepare your building Cube:

```shell
apt install git -y --force-yes
git clone https://github.com/labriqueinternet/build.labriqueinter.net.git /opt/build.labriqueinter.net
cd /opt/build.labriqueinter.net && time bash init.sh
```

### Images Building

On your building Cube, just do (you should execute this line in a *screen*/*tmux*):

```shell
cd /opt/build.labriqueinter.net && bash build.sh -e -b lime,lime2
```

After something like 30 minutes, the four images produced are available in */srv/build/*.

## Installing the New Images

Now you can follow [tutorials](https://repo.labriqueinter.net) to install a new Internet Cube.

## Going Further (bonus)

### With YunoHost Testing

The stable version of YunoHost is installed by default, but you can install the testing one, adding this option to the call of *build.sh*:

```shell
-d testing
```

## With Custom *u-boot*

During the images creation, this DEB package is download and installed:

 *https://repo.labriqueinter.net/u-boot/u-boot-sunxi_latest_armhf.deb*

This is the official Debian version of *u-boot-sunxi*, but with [some patches](https://github.com/labriqueinternet/build.labriqueinter.net/tree/master/u-boot/patches) specific to LIME/LIME2. If you want to build your own version, or update this one, you just have to execute [this script](https://github.com/labriqueinternet/build.labriqueinter.net/blob/master/u-boot/uboot_makedeb.sh) on your building Cube.

Then, just edit *conf/boards/main.sh* in order to use your own version of the DEB package, rather than the online one. Finally, rebuild the images.
