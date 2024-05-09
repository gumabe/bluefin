#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree uninstall libvirt-daemon-kvm zfs-fuse libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt
rpm-ostree install /tmp/rpms/zfs/*.rpm pv tmux
rpm-ostree install libvirt-daemon-kvm libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt awesome mate-settings-daemon mate-control-center mate-polkit
find /lib/modules/
depmod -A ${KERNEL}
# this would install a package from rpmfusion
# rpm-ostree install vlc
#### Example for enabling a System Unit File

systemctl enable podman.socket
