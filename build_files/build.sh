#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ilyaz/LACT
dnf5 -y copr enable swayfx/swayfx
dnf5 -y copr enable scottames/ghostty
#dnf5 -y install /ctx/keybase_amd64.rpm

#dnf5 -y remove zfs-fuse
#dnf5 install /zfs/*.rpm
# dnf5 install -y tmux libvirt-daemon-kvm libvirt-daemon-driver-storage-zfs \
#   libvirt-daemon-driver-storage libvirt awesome mate-settings-daemon mate-control-center \
#   mate-polkit stow firefox jetbrains-mono-fonts python3-pip flameshot fedora-release-sway-atomic \
#   sway-config-fedora terminator neovim netcat emacs-gtk+x11 emacs kitty kitty-shell-integration \
#   kitty-terminfo alacritty inotify-tools inotify-tools-devel blueman wl-clipboard wlr-randr cmake \
#   cpio meson at qt5ct qt6ct qt6-qtsvg swappy yad pipewire-utils pipewire-alsa pavucontrol swaync \
#   pcmanfm xcompmgr copyq driverctl incus-client gamescope lightdm lightdm-settings gamescope gnome-session-xsession \
#   libffi-devel libtool libX11-devel libxml2-devel lightdm lightdm-greeter \
#   sddm-conf wxGTK-devel stgit lact ncurses-devel \
#   tig sway-config-fedora hyprland nwg-dock-hyprland fedora-release-xfce

dnf5 install -y tmux fedora-release-xfce awesome qtile-extras fedora-release-sway-atomic \
  sway-config-fedora terminator neovim netcat emacs-gtk+x11 emacs libtool libffi-devel \
  libtool libX11-devel libxml2-devel pcmanfm inotify-tools inotify-tools-devel swayfx kitty kitty-shell-integration \
  kitty-terminfo stgit lact ncurses-devel wxGTK-devel tig blueman flameshot cpio cmake meson at \
  ghostty pavucontrol

# Use a COPR Example:
#
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ilyaz/LACT
#### Example for enabling a System Unit File

systemctl enable podman.socket
