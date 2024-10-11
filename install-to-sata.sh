#!/bin/bash
# install-to-sata.sh

# Author:  hexzhen3x7
# Version: 0.1.2
# Website: https://codehunterz.world
# Github:  https://github.com/bpi-codehunterz-world/Install-To-Sata
# Description: This is a setup-script to move your root-filesystem to a sata-hdd and edit the boot-configs to boot at next time with the fresh-copied rootfs, contained on the sata-hdd mounted!



echo -e "Console > Installing dependencies!!!"
sudo apt-get install -y fdisk sudo nano tree dialog

reset;

echo -e "BPI-BOOT > Configuring to boot from SATA HDD!"


sudo fdisk -l
read -p "BPI-BOOT > Set Sata HDD > " hdd

DEVICE=$hdd
PARTITION="${DEVICE}1"

fdisk_commands=$(cat <<EOF
n
p
1
t
83

w
EOF
)

echo "$fdisk_commands" | sudo fdisk $DEVICE
sudo mkfs.ext4 $PARTITION
echo "Console > Partition $PARTITION created in ext4 format."

sudo mount "${DEVICE}1" /mnt


echo -e "Console > Copying FS!"
sudo rsync -a --info=progress2 / /mnt




echo -e "BPI-BOOT > Listing BLKID now!"
sudo blkid

read -p "BPI-BOOT > SATA UUID > " uuid
echo -e "BPI-BOOT > $uuid" 

echo -e "BPI-BOOT > Edit now /boot/cmdline, /boot/bananapi/bpi-m2u/linux/1080p/uEnv.txt, /boot/bananapi/bpi-m2u/linux/720p/uEnv.txt, /boot/bananapi/bpi-m2u/linux/lcd7/uEnv.txt & /mnt/etc/fstab !"

sudo mkdir ~/boot_bak
sudo cp -r /boot ~/boot_bak
sudo rm -rf /boot/cmdline.txt


sudo blkid
read -p "Partition PARTUUID > " partuuid

cat <<EOF > /boot/cmdline.txt
dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=$partuuid rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
EOF

read -p "Partition 1 (exp.: /dev/sda1) > " part
cat <<EOF > /boot/bananapi/bpi-m2u/linux/1080p/uEnv.txt
#
## uEnv.txt
#
bpi=bananapi
board=bpi-m2u
chip=r40
service=linux
#
##
#
kernel=uImage
initrd=uInitrd
#
##
#
kaddr=0x47000000
rdaddr=0x49000000
#
##
#
#root=/dev/ram
root=$part rootfstype=ext4 rw rootwait bootmenutimeout=10 datadev=sda1 data=/dev/mmcblk0p3
console=earlyprintk=sunxi-uart,0x01c28000 console=tty1 console=ttyS0,115200n8 no_console_suspend consoleblank=0
bootopts=enforcing=1 initcall_debug=0 loglevel=8 init=/init cma=256M panic=10 fsck.mode=force fsck.repair=yes overlaytype=overlayfs
volumioarg=imgpart=$part imgfile=/volumio_current.sqsh rw rootwait
#
# from sys_config.fex
#
#;output_type  (0:none; 1:lcd; 2:tv; 3:hdmi; 4:vga)
#;output_mode  (used for tv/hdmi output, 0:480i 1:576i 2:480p 3:576p 4:720p50 5:720p60 6:1080i50 7:1080i60 8:1080p24 9:1080p50 10:1080p60 11:pal 14:ntsc)
#
# output HDMI 480P (type:3 mode:2)
# output HDMI 720P (type:3 mode:5)
# output HDMI 1080P (type:3 mode:10)
# output LCD7/LCD5  (type:1 mode:5)
otype=3
omode=10
#
##
#
abootargs=setenv bootargs board=${board} console=${console} root=${root} service=${service} bpiuser=${bpiuser} mac_addr=${mac_addr} ${bootopts} disp.screen0_output_type=${otype} disp.screen0_output_mode=${omode} disp.screen1_output_type=${otype} disp.screen1_output_mode=${omode}
#
#abootargs=setenv bootargs board=${board} console=${console} ${volumioarg} service=${service} bpiuser=${bpiuser} ${bootopts}
#
##
#
ahello=echo Banana Pi ${board} chip: $chip Service: $service bpiuser: ${bpiuser}
#
##
#
aboot=if fatload $device $partition $rdaddr ${bpi}/${board}/${service}/uInitrd; then bootm $kaddr $rdaddr ; else bootm $kaddr; fi
#
##
#
aload_kernel=fatload $device $partition $kaddr ${bpi}/${board}/${service}/${kernel}
#
##
#
uenvcmd=run ahello abootargs aload_kernel aboot
#
## END
EOF

cat <<EOF > /boot/bananapi/bpi-m2u/linux/720p/uEnv.txt
#
## uEnv.txt
#
bpi=bananapi
board=bpi-m2u
chip=r40
service=linux
#
##
#
kernel=uImage
initrd=uInitrd
#
##
#
kaddr=0x47000000
rdaddr=0x49000000
#
##
#
#root=/dev/ram
root=$part rootfstype=ext4 rw rootwait bootmenutimeout=10 datadev=sda1 data=/dev/mmcblk0p3
console=earlyprintk=sunxi-uart,0x01c28000 console=tty1 console=ttyS0,115200n8 no_console_suspend consoleblank=0
bootopts=enforcing=1 initcall_debug=0 loglevel=8 init=/init cma=256M panic=10 fsck.mode=force fsck.repair=yes overlaytype=overlayfs
volumioarg=imgpart=$part imgfile=/volumio_current.sqsh rw rootwait
#
# from sys_config.fex
#
#;output_type  (0:none; 1:lcd; 2:tv; 3:hdmi; 4:vga)
#;output_mode  (used for tv/hdmi output, 0:480i 1:576i 2:480p 3:576p 4:720p50 5:720p60 6:1080i50 7:1080i60 8:1080p24 9:1080p50 10:1080p60 11:pal 14:ntsc)
#
# output HDMI 480P (type:3 mode:2)
# output HDMI 720P (type:3 mode:5)
# output HDMI 1080P (type:3 mode:10)
# output LCD7/LCD5  (type:1 mode:5)
otype=3
omode=5
#
##
#
abootargs=setenv bootargs board=${board} console=${console} root=${root} service=${service} bpiuser=${bpiuser} mac_addr=${mac_addr} ${bootopts} disp.screen0_output_type=${otype} disp.screen0_output_mode=${omode} disp.screen1_output_type=${otype} disp.screen1_output_mode=${omode}
#
#abootargs=setenv bootargs board=${board} console=${console} ${volumioarg} service=${service} bpiuser=${bpiuser} ${bootopts}
#
##
#
ahello=echo Banana Pi ${board} chip: $chip Service: $service bpiuser: ${bpiuser}
#
##
#
aboot=if fatload $device $partition $rdaddr ${bpi}/${board}/${service}/uInitrd; then bootm $kaddr $rdaddr ; else bootm $kaddr; fi
#
##
#
aload_kernel=fatload $device $partition $kaddr ${bpi}/${board}/${service}/${kernel}
#
##
#
uenvcmd=run ahello abootargs aload_kernel aboot
#
## END
#
EOF

cat <<EOF > /boot/bananapi/bpi-m2u/linux/lcd7/uEnv.txt
#
## uEnv.txt
#
bpi=bananapi
board=bpi-m2u
chip=r40
service=linux
#
##
#
kernel=uImage
initrd=uInitrd
#
##
#
kaddr=0x47000000
rdaddr=0x49000000
#
##
#
#root=/dev/ram
root=$part rootfstype=ext4 rw rootwait bootmenutimeout=10 datadev=sda1 data=/dev/mmcblk0p3
console=earlyprintk=sunxi-uart,0x01c28000 console=tty1 console=ttyS0,115200n8 no_console_suspend consoleblank=0
bootopts=enforcing=1 initcall_debug=0 loglevel=8 init=/init cma=256M panic=10 fsck.mode=force fsck.repair=yes overlaytype=overlayfs
volumioarg=imgpart=$part imgfile=/volumio_current.sqsh rw rootwait
#
# from sys_config.fex
#
#;output_type  (0:none; 1:lcd; 2:tv; 3:hdmi; 4:vga)
#;output_mode  (used for tv/hdmi output, 0:480i 1:576i 2:480p 3:576p 4:720p50 5:720p60 6:1080i50 7:1080i60 8:1080p24 9:1080p50 10:1080p60 11:pal 14:ntsc)
#
# output HDMI 480P (type:3 mode:2)
# output HDMI 720P (type:3 mode:5)
# output HDMI 1080P (type:3 mode:10)
# output LCD7/LCD5  (type:1 mode:5)
otype=1
omode=4
#
##
#
abootargs=setenv bootargs board=${board} console=${console} root=${root} service=${service} bpiuser=${bpiuser} mac_addr=${mac_addr} ${bootopts} disp.screen0_output_type=${otype} disp.screen0_output_mode=${omode} disp.screen1_output_type=${otype} disp.screen1_output_mode=${omode}
#
#abootargs=setenv bootargs board=${board} console=${console} ${volumioarg} service=${service} bpiuser=${bpiuser} ${bootopts}
#
##
#
ahello=echo Banana Pi ${board} chip: $chip Service: $service bpiuser: ${bpiuser}
#
##
#
aboot=if fatload $device $partition $rdaddr ${bpi}/${board}/${service}/uInitrd; then bootm $kaddr $rdaddr ; else bootm $kaddr; fi
#
##
#
aload_kernel=fatload $device $partition $kaddr ${bpi}/${board}/${service}/${kernel}
#
##
#
uenvcmd=run ahello abootargs aload_kernel aboot
#
## END
#
EOF