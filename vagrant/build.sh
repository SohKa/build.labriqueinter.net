#!/bin/bash
set -xe 

#mkdir vagrant_brique
cd vagrant_brique
#wget https://repo.labriqueinter.net/labriqueinternet_A20LIME_latest_jessie.img.tar.xz
#tar -xf labriqueinternet_A20LIME_latest_jessie.img.tar.xz 
qemu-img convert -c -f raw -O qcow2 labriqueinternet_A20LIME_2017-02-05_jessie.img box.img
mkdir temp
sudo qemu-nbd --connect=/dev/nbd0 box.img
sudo mount /dev/nbd0p1 temp
sudo mkdir -p temp/home/vagrant/.ssh; sudo chmod 0700 temp/home/vagrant/.ssh; sudo wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O temp/home/vagrant/.ssh/authorized_keys; sudo chmod 0600 temp/home/vagrant/.ssh/authorized_keys; sudo chown -R 2000:2000 temp/home/vagrant/.ssh; echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee temp/etc/sudoers.d/vagrant;
echo -n '' | sudo tee temp/etc/fstab
echo "vagrant:$6$GeRuXxQI$xRQiyYws2.lm2WFY89Jqv.mhTgqQH/FUpctWDNNUV8nAn9kJTqM.tCY/6f.f4pvhZoPmITr9xnIomVm9uMVkA1:17367:0:99999:7:::" | sudo tee -a temp/etc/shadow
sudo sed -i 's/sudo:x:27:/sudo:x:27:vagrant/g' -i temp/etc/group
echo "vagrant:*::" | sudo tee -a temp/etc/gshadow
echo "vagrant:x:2000:2000::/home/vagrant:/bin/bash" | sudo tee -a temp/etc/passwd
echo "vagrant:x:2000:" | sudo tee -a temp/etc/group
echo mac80211_hwsim | sudo tee -a temp/etc/modules
sudo sed -i 's/mmcblk0p1/vda1/' -i temp/usr/local/bin/secondrun
sudo sed -i 's/mmcblk0/vda/' -i temp/usr/local/bin/firstrun
sudo sed -i '12 a /sbin/iptables -I INPUT -p tcp --dport 22 -j DROP' temp/usr/local/bin/firstrun
sudo cp temp/boot/initrd.img-3.16.0-4-armmp .
sudo cp temp/boot/vmlinuz-3.16.0-4-armmp .
sudo chown $USER initrd.img-3.16.0-4-armmp 
cp initrd.img-3.16.0-4-armmp initrd.img
cp vmlinuz-3.16.0-4-armmp vmlinuz
wget http://ftp.fr.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/netboot.tar.gz
gunzip netboot.tar.gz
tar xvf netboot.tar
cp debian-installer/armhf/dtbs/vexpress-v2p-ca15-tc1.dtb .
sudo umount temp
sudo qemu-nbd --disconnect /dev/nbd0
rm -r temp
cp ../conf/Vagrantfile-upstream Vagrantfile
cp ../conf/metadata.json .
tar cvzf debian8-arm-brique.box Vagrantfile vmlinuz initrd.img vexpress-v2p-ca15-tc1.dtb metadata.json box.img
vagrant box add --name brique debian8-arm-brique.box
