### README - How to move ROOTFS in rasbian to SATA HDD and BOOT from SDCARD with mounting SATA HDD as ROOTFS


# To move the root filesystem in Raspbian to a SATA HDD and boot from an SD card while mounting the SATA HDD as the root filesystem, follow these steps:


# 1 - Prepare the SATA HDD:

 - Verbinde die SATA HDD mit deinem Banana Pi.

 - Identifiziere die SATA HDD mit fdisk -l.

 - Erstelle eine Partition mit fdisk auf der SATA HDD.

 - Formatiere die neu erstellte SATA-Partition (e.g., ext4) mit:" sudo mkfs.ext4 /dev/sda1 ".


 Code:
```sh
sudo fdisk -l
echo -e "Konsole > Gib als SATA-HDD Ziel z.b.:' /dev/sda ' ein!"
read -p "BPI-ROOT > Setze SATA-HDD >> " hdd

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
echo "Konsole > Partition $PARTITION wurde im ext4-format erstellt."
```


# 2 - Copy the Root Filesystem:

 - Ertstelle das Verzeichnis:" /mnt/hdd" & Binde die SATA-PARTITION ein in , e.g., /mnt/hdd !

Code:
```sh
sudo mkdir -p /mnt/hdd
sudo mount "${DEVICE}1" /mnt/hdd
```

 - Kopiere das Wurzeldateisystem auf die neu eingebundene SATA-PARTITON, die auf /mnt/hdd zeigt !

Code:
```sh
sudo rsync -aHAXx --info=progress2 / /mnt/hdd
```

# 3 - Update Boot Configuration:

- Liste die HDD's PARTUUID & UUID!
- Setze die Variablen wie gebraucht!

Code:
```sh
sudo blkid
read -p "BPI-ROOT-PARTUUID > " partuuid
read -p "BPI-ROOT-UUID > " uuid
```

- Editiere die /boot/cmdline.txt datei auf der SD card um das Wurzeldateisystem treffend auf der SATA HDD's PARTUUID zu ändern!:

Code:
```sh

echo "Konsole > Änder die Zeile:" root= " to: root="${DEVICE}1""

sudo nano /boot/cmdline.txt
```

- Speichere und schließe den Editor.
- Update den Bootloader:
- Stelle sicher, dass der bootloader von der SD card auf die SATA HDD zeigt!:

```sh
sudo nano /boot/config.txt
```
- Füge hinzu uder update die Zeile:

```sh
root=/dev/sda1
```
- Speicher und beende den Editor.

- Konfiguriere die /etc/fstab Datei!

```sh
  echo -e "Konsole > 'Ändere:' /dev/mmcblk0p2  /               ext4    defaults,noatime  0       1 ' zu :' UUID=$uuid  /               ext4    defaults,noatime  0       1 ' !!!"
```


- Starte dein Banana Pi neu:

```sh
sudo reboot
```
- Dein Banana Pi sollte nun mit dem neuem Wurzeldateisystem eingebunden starten, welches auf deiner SATA HDD gespeichert ist.