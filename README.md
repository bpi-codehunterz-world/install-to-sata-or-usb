

<b style="color:red;">**How to move ROOTFS in rasbian to SATA HDD and BOOT from SDCARD with mounting SATA HDD as ROOTFS**</b>

[color="red"[GERMAN: Für die deutsche Anleitung, lies die im Docs-Ordner sich befindene LIESMICH.md Datei![/color]
ENGLISCH: The Whole README is saved in the Docs-folder too!

To move the root filesystem in Raspbian or Armbian to a SATA-HDD/SSD/NVMe or USB-Stick and boot from an SD card while mounting the SATA HDD as the root filesystem, follow these steps:


1 - Prepare the SATA HDD:

 - Connect the SATA HDD to your Raspberry Pi.

 - Identify the SATA HDD by running fdisk -l in the terminal.

 - Create a partition on the SATA HDD using fdisk1.

 - Format the partition to a Linux filesystem (e.g., ext4) using mkfs.ext4 /dev/sda1.


 Code:
```sh
sudo fdisk -l
echo -e "Console > Enter for exp.: /dev/sda !"
read -p "BPI-ROOT > Set Sata HDD > " hdd

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
```


2 - Copy the Root Filesystem:

 - Mount the SATA HDD partition to a directory, e.g., /mnt/hdd:

Code:
```sh
sudo mkdir -p /mnt/hdd
sudo mount "${DEVICE}1" /mnt/hdd
```

 - Copy the root filesystem from the SD card to the SATA HDD:

Code:
```sh
sudo rsync -aHAXx --info=progress2 / /mnt/hdd
```

3 - Update Boot Configuration:

- Show the sata HDD's PARTUUID & UUID!
- Set Variables as needed!

Code:
```sh
sudo blkid
read -p "BPI-ROOT-PARTUUID > " partuuid
read -p "BPI-ROOT-UUID > " uuid
```

- Edit the /boot/cmdline.txt file on the SD card to change the root filesystem to the SATA HDD's PARTUUID!:

Code:
```sh

echo "Change the line:" root= " to: root="${DEVICE}1""

sudo nano /boot/cmdline.txt
```

- Save and exit the editor.

- Update the Bootloader:

- Ensure the bootloader on the SD card points to the SATA HDD:

```sh
sudo nano /boot/config.txt
```
- Add or update the line:

```sh
root=/dev/sda1
```
- Save and exit the editor.

- Configure the /etc/fstab file!

```sh
  echo -e "Console > Change:' /dev/mmcblk0p2  /               ext4    defaults,noatime  0       1 ' to :' UUID=$uuid  /               ext4    defaults,noatime  0       1 ' !!!"
```

- Reboot:

- Reboot your Banana Pi:

```sh
sudo reboot
```
- Your Banana Pi should now boot from the SD card and mount the SATA HDD as the root filesystem.
