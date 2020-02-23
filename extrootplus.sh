#!/bin/sh
echo "This script will ExtRoot your vera plus. Please make sure that you have an external drive plugged into the vera and that USB logging is enabled."
while true; do
    read -p "Are you ready?   " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes, no or press Ctrl + c to exit";;
    esac
done
while true; do
    read -p "Update Packages first?   " yn
    case $yn in
        [Nn]* ) break;;
        [Yy]* ) echo "arch ramips_24kec 100" >> /etc/opkg.conf
        echo "arch ramips_1004kc 200" >> /etc/opkg.conf
        echo "arch all 300" >> /etc/opkg.conf
        echo "src/gz base http://archive.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/base" >> /etc/opkg.conf
        echo "src/gz packages http://archive.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/packages" >> /etc/opkg.conf
        opkg update
        opkg install nano
        opkg install block-mount
        break;;
        * ) echo "Please answer yes, no or press Ctrl + c to exit";;
    esac
done
mkfs.ext4 /dev/sda2
mkdir -p /mnt/sda2
mount /dev/sda2 /mnt/sda2
echo "starting to copy files"
cp -a -f /bin /mnt/sda2
cp -a -f /dev /mnt/sda2
cp -a -f /etc /mnt/sda2
cp -a -f /ezmi /mnt/sda2
cp -a -f /lib /mnt/sda2
cp -a -f /mios /mnt/sda2
cp -a -f /mios_constants.sh /mnt/sda2
cp -a -f /rom /mnt/sda2
cp -a -f /root /mnt/sda2
cp -a -f /sbin /mnt/sda2
cp -a -f /storage /mnt/sda2
mkdir /mnt/sda2/sys
mkdir /mnt/sda2/proc
cp -a -f /tmp /mnt/sda2
cp -a -f /usr /mnt/sda2
cp -a -f /var /mnt/sda2
cp -a -f /www /mnt/sda2
echo "Root Copy Completed"
uci delete fstab.@mount[0]
uci delete fstab.@mount[0]
uci delete fstab.@mount[0]
uci add fstab mount
uci set fstab.@mount[0].target=/
UUID=$(block info "/dev/sda2" | cut -c18-53)
uci set fstab.@mount[0].uuid="${UUID}"
uci set fstab.@mount[0].fstype=ext4
uci set fstab.@mount[0].options=rw,sync
uci set fstab.@mount[0].enabled=1
uci set fstab.@mount[0].enabled_fsck=0
uci commit fstab
uci add fstab mount
uci set fstab.@mount[1].enabled=1
uci set fstab.@mount[1].target=/tmp/log/cmh
uci set fstab.@mount[1].fstype=ext3
uci set fstab.@mount[1].options=rw,noatime,nodiratime,errors=continue,data=ordered
uci set fstab.@mount[1].enabled_fdisk=1
uci set fstab.@mount[1].enabled_mkfs=1
uci set fstab.@mount[1].enabled_fsck=1
uci set fstab.@mount[1].label=mios
uci set fstab.@mount[1].fssize=512
uci set fstab.@mount[1].fsck_days=30
uci set fstab.@mount[1].fsck_mounts=10
uci set fstab.@mount[1].device=/dev/sda1
uci set fstab.@mount[1].label=mios
uci commit fstab
uci add fstab mount
uci set fstab.@mount[2].target=/mnt/mmcblk*
uci set fstab.@mount[2].enabled=1
uci commit fstab
umount /dev/sda2
rm -R /mnt/sda2
sed -i '2 a export PREINIT=1' /etc/rc.local
sed -i '3 a mount_root' /etc/rc.local
block info
cat /etc/config/fstab
while true; do
    read -p "Reboot?   " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
    esac
done
reboot
