#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1
curl -o /etc/yum.repos.d/refi64-webapp-manager-fedora.repo "https://copr.fedorainfracloud.org/coprs/refi64/webapp-manager/repo/fedora-${RELEASE}/refi64-webapp-manager-fedora-${RELEASE}.repo"

rpm --import https://packagecloud.io/filips/FirefoxPWA/gpgkey
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo



# this installs a package from fedora repos
rpm-ostree uninstall libvirt-daemon-kvm zfs-fuse libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt
rpm-ostree install /tmp/rpms/zfs/*.rpm pv tmux
rpm-ostree install libvirt-daemon-kvm libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt awesome mate-settings-daemon mate-control-center mate-polkit stow firefox jetbrains-mono-fonts python3-pip firefoxpwa webapp-manager flameshot fedora-release-sway-atomic sway-config-fedora terminator neovim netcat

depmod -A ${KERNEL}

# this would install a package from rpmfusion
# rpm-ostree install vlc
#### Example for enabling a System Unit Filexargs flatpa
#find /tmp/
#cat /tmp/flatpaks.txt |xargs -i flatpak --system install -y {}

systemctl enable podman.socket
