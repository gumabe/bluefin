#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1
#curl -o /etc/yum.repos.d/refi64-webapp-manager-fedora.repo "https://copr.fedorainfracloud.org/coprs/refi64/webapp-manager/repo/fedora-${RELEASE}/refi64-webapp-manager-fedora-${RELEASE}.repo"
#curl -o /etc/yum.repos.d/solopasha-hyprland-fedora-41.repo "https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-41/solopasha-hyprland-fedora-41.repo"
#rpm-ostree install hyprland
copr="cjuniorfox/hyprland-shell solopasha/hyprland tofik/sway"
for i in ${copr}; do
    MAINTAINER="${i%%/*}"
    REPOSITORY="${i##*/}"
    curl --output "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPOSITORY}.repo" --remote-name \
    "https://copr.fedorainfracloud.org/coprs/${MAINTAINER}/${REPOSITORY}/repo/fedora-${RELEASE}/${MAINTAINER}-${REPOSITORY}-fedora-${RELEASE}.repo"
done

#rpm --import https://packagecloud.io/filips/FirefoxPWA/gpgkey
#echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo



# this installs a package from fedora repos
#rpm-ostree uninstall libvirt-daemon-kvm libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt
#rpm-ostree install /tmp/rpms/zfs/*.rpm pv tmux
rpm-ostree install libvirt-daemon-kvm libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-storage libvirt awesome mate-settings-daemon mate-control-center mate-polkit stow firefox jetbrains-mono-fonts python3-pip flameshot fedora-release-sway-atomic sway-config-fedora terminator neovim netcat sddm-wayland-sway swaylock sway-contrib emacs-gtk+x11 emacs kitty kitty-shell-integration kitty-terminfo alacritty inotify-tools inotify-tools-devel blueman hyprland hyprland-plugins wl-clipboard wlr-randr cliphist eww-git hypridle hyprlock hyprshot waypaper 

rpm-ostree install hyprland-shell-config 
#wol-changer  

#Install COPR packages from tofik/sway
rpm-ostree install sway-audio-idle-inhibit

# Remove the Firefox related packages (will be installed over flatpak)
rpm-ostree override remove firefox-langpacks firefox

depmod -A ${KERNEL}

# this would install a package from rpmfusion
# rpm-ostree install vlc
#### Example for enabling a System Unit Filexargs flatpa
#find /tmp/
#cat /tmp/flatpaks.txt |xargs -i flatpak --system install -y {}
echo zfs > /etc/modules-load.d/zfs.conf
systemctl enable podman.socket
