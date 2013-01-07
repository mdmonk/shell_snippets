#!/bin/sh

if [ `id -un` != "root" ]; then
  echo "Not executed as root, re-executing myself with sudo...."
  exec sudo sh $0
fi

DEVICEPATH=`dirname $0`/container.bin
MNTDIR=`mktemp -d`
LOOPDEV=`losetup -f`

losetup "$LOOPDEV" "$DEVICEPATH"
cryptsetup luksOpen "$LOOPDEV" cryptedContainer
mount -t vfat -o nodev,noexec,nosuid,gid=100,umask=007,codepage=850,iocharset=iso8859-15,shortname=mixed,quiet /dev/mapper/cryptedContainer "$MNTDIR"
echo "-------------------------------------------"
echo "Encrypted container mounted at $MNTDIR"
echo
echo "Press any key to unmount"
echo "-------------------------------------------"
read key
umount "$MNTDIR"
rmdir "$MNTDIR"
cryptsetup luksClose cryptedContainer
losetup -d $LOOPDEV
echo "done"
