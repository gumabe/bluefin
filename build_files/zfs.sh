#!/bin/bash
# Install ZFS from ublue-os/akmods-zfs (mounted at /tmp/rpms/zfs by the Containerfile).
# Adapted from Aurora's build_scripts/base/zfs.sh, removed in ublue-os/aurora#2918.

set -ouex pipefail

KERNEL="$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | tail -n1)"

dnf5 -y install \
    /tmp/rpms/zfs/kmod-zfs-"${KERNEL}"-*.rpm \
    /tmp/rpms/zfs/libnvpair[0-9]-*.rpm \
    /tmp/rpms/zfs/libuutil[0-9]-*.rpm \
    /tmp/rpms/zfs/libzfs[0-9]-*.rpm \
    /tmp/rpms/zfs/libzpool[0-9]-*.rpm \
    /tmp/rpms/zfs/python3-pyzfs-*.rpm \
    /tmp/rpms/zfs/zfs-*.rpm \
    pv

depmod -a "${KERNEL}"
echo "zfs" >/usr/lib/modules-load.d/zfs.conf

# Fail the build rather than ship an image whose zfs module doesn't match its kernel
modinfo -k "${KERNEL}" zfs >/dev/null
