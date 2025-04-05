#!/bin/bash

# check cgroup
if [ ! -f /proc/1/ns/cgroup ]; then 
    echo -n 'InitNotOk';
    exit;
fi

# check selinux
SELINUX=$(grep -E '^SELINUX=' /etc/selinux/config | cut -d= -f2)
if [ "$SELINUX" != "disabled" ]; then
    echo -n 'InitNotOk';
    exit;
fi

# check kernel
KERNEL_VERSION=`grubby --default-kernel`
if [ "$KERNEL_VERSION" != "/boot/vmlinuz-6.4.4-1.el7.elrepo.x86_64" ]; then
    echo -n "InitNotOk";
    exit;
fi
echo -n "InitOk"
