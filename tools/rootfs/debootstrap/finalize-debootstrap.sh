#!/bin/bash
# Clean up the file system installed by debootstrap
#
# Use i386+squeeze as an example:
#
# ---------------------------------------
# debootstrap --verbose --arch i386 --foreign squeeze /opt/rootfs/x86/ http://mirrors.163.com/debian
# cp /usr/bin/qemu-i386-static /opt/rootfs/x86/usr/bin
# chroot /opt/rootfs/x86
# ---------------------------------------
#
# Note:
# 1. About ARCH 
# Please check the right <ARCH> name from the following page
# http://mirrors.ustc.edu.cn/debian/dists/squeeze/
# 		Contents-<ARCH>.gz
# The candidates include: i386,mips,mipsel,armel,powerpc,amd64,ia64,sparc,s390
#
# 2. About Mirror sites
# Different mirror sites support different archs, please check it carefully
# More available mirror sites include:
#	http://www.debian.org/mirror/list
# 3. About Debian releases
# Seems mipsel doesn't work with squeeze, please try testing instead, for more,
# please see: http://mirrors.ustc.edu.cn/debian/dists/
# may include: lenny,testing,wheezy...

./debootstrap/debootstrap --second-stage

apt-get clean
find /var/lib/apt/lists -type f -delete
rm -r /dev/.udev
: > /etc/hostname
: > /etc/resolv.conf
ln -s /dev/null /etc/blkid.tab
ln -s /proc/mounts /etc/mtab
: > /etc/udev/rules.d/70-persistent-net.rules
echo 'APT { Install-Recommends "false"; };' > /etc/apt/apt.conf.d/no-recommends
sed -i -e '/^RAM\(RUN\|LOCK\)=/ s/^\(.*\)=.*$/\1=yes/' /etc/default/rcS

cat <<EOF > /etc/default/locale
#  File generated by update-locale
LANG=en_US.UTF-8
EOF

cat <<EOF > /etc/hosts
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback
#iface lo inet6 loopback
EOF

cat <<EOF > /etc/fstab
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>                     <d><p>
/dev/root       /               auto    relatime                       0  0

tmpfs           /tmp            tmpfs   nodev,nosuid,noexec,size=32M   0  0
tmpfs           /var/tmp        tmpfs   nodev,nosuid,noexec,size=8M    0  0
EOF

cat <<EOF > /etc/apt/sources.list
#deb http://ftp.uk.debian.org/debian/ squeeze main contrib non-free
#deb-src http://ftp.uk.debian.org/debian/ squeeze main contrib non-free

#deb http://security.debian.org/ squeeze/updates main contrib non-free
#deb-src http://security.debian.org/ squeeze/updates main contrib non-free

#deb http://ftp.uk.debian.org/debian squeeze-updates main
#deb-src http://ftp.uk.debian.org/debian squeeze-updates main

#deb http://ftp.sjtu.edu.cn/debian squeeze-updates main
deb http://debian.ustc.edu.cn/debian squeeze main contrib non-free

EOF

cat <<EOF > /etc/resolv.conf

# Generated by NetworkManager
domain domain
search domain
nameserver 202.106.0.20
nameserver 192.168.0.233
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 4.3.2.1 

EOF

[ -z "$SUDO_USER" ] && SUDO_USER=falcon

useradd $SUDO_USER -m -r -s /bin/bash

apt-get update

yes | apt-get install vim build-essential

apt-get clean

apt-get autoremove
