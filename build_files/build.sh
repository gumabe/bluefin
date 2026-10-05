#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

FEDORA_PACKAGES=(
    android-tools
    bcc
    bpftop
    bpftrace
    cascadia-code-fonts
    cockpit-bridge
    cockpit-machines
    cockpit-networkmanager
    cockpit-ostree
    cockpit-podman
    cockpit-selinux
    cockpit-storaged
    cockpit-system
    dbus-x11
    edk2-ovmf
    flatpak-builder
    genisoimage
    git-subtree
    git-svn
    iotop
    libvirt
    libvirt-nss
    nicstat
    numactl
    osbuild-selinux
    p7zip
    p7zip-plugins
    podman-compose
    podman-machine
    podman-tui
    qemu
    qemu-char-spice
    qemu-device-display-virtio-gpu
    qemu-device-display-virtio-vga
    qemu-device-usb-redirect
    qemu-img
    qemu-system-x86-core
    qemu-user-binfmt
    qemu-user-static
    rocm-hip
    rocm-opencl
    rocm-smi
    sysprof
    incus
    incus-agent
    incus-tools
    virtiofsd
    cloud-utils
    lxc
    tiptop
    trace-cmd
    udica
    util-linux-script
    virt-manager
    virt-v2v
    virt-viewer
    ydotool
    zsh
)

dnf5 -y install "${FEDORA_PACKAGES[@]}"


dnf5 config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
#sudo dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
dnf5 -y install --enablerepo=docker-ce-stable \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    docker-model-plugin

# this installs a package from fedora repos
dnf5 -y copr enable ublue-os/staging
#dnf5 -y copr enable ilyaz/LACT
dnf5 -y copr enable swayfx/swayfx
dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable erikreider/SwayNotificationCenter
dnf5 -y copr enable errornointernet/quickshell
dnf5 -y copr enable alternateved/cliphist
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


dnf5 install -y g++
dnf5 group install -y cosmic-desktop cosmic-desktop-apps development-tools

# wxGTK-devel (below) needs libGLU-devel, i.e. GL/glu.h, which only Fedora's
# mesa-libGLU-devel ships. Without it wx/configure prints "No GLU headers found, wx
# will NOT be usable" and Erlang/OTP builds end up without the wx application.
# Bazzite excludes `mesa-*` on its *fedora*, *negativo17* and *staging* repos to
# protect its own mesa build, and that glob also swallows mesa-libGLU-devel. Install
# just this one package with the excludes bypassed; mesa itself is untouched. On
# non-Bazzite bases there is no exclude and this is a plain install.
dnf5 install -y --setopt="*.exclude=" mesa-libGLU-devel

# Two -devel packages from the bluebox branch's list are deliberately NOT carried over
# here, because bluebox builds on Aurora while this image builds on Bazzite, which
# swaps several Fedora runtimes for Terra forks whose -devel subpackages do not exist:
#   * libEGL-devel   -> only Fedora's mesa-libEGL-devel provides it, and that needs
#                       Fedora's mesa-libEGL, which the mesa-* exclude blocks and which
#                       Terra's mesa-libEGL 1:26.2.2-3 already replaces. libglvnd-devel
#                       is used instead -- it is what actually ships EGL/egl.h.
#   * wireplumber-devel -> requires Fedora's wireplumber, which Conflicts: with the
#                       installed terra-wireplumber. No Terra -devel variant exists.

dnf5 install -y tmux python3 fedora-release-xfce awesome qtile-extras fedora-release-sway-atomic \
  sway-config-fedora terminator neovim netcat emacs-gtk+x11 emacs libtool libffi-devel \
  libtool libX11-devel libxml2-devel pcmanfm inotify-tools inotify-tools-devel swayfx kitty kitty-shell-integration \
  kitty-terminfo stgit ncurses-devel tig blueman flameshot cpio cmake meson at ninja \
  ghostty pavucontrol nwg-dock musl-gcc gcc clang cmake alsa-lib-devel fontconfig-devel wayland-devel libxcb-devel \
  libxkbcommon-x11-devel openssl-devel libzstd-devel vulkan-loader sqlite-devel jq git \
  tar perl-FindBin perl-IPC-Cmd perl-File-Compare perl-File-Copy mold driverctl chromium \
  fop swaync below SwayNotificationCenter niri cava quickshell \
  qt6-qtbase-devel qt6-qtdeclarative-devel cmake gcc-c++ cliphist musl-libc-static \
  google-noto-sans-fonts plocate Thunar wlsunset thunar-vcs-plugin thunar-volman gtkhash-thunar thunar-media-tags-plugin \
  wxGTK-devel wxGTK-gl unixODBC-devel lksctp-tools-devel libxslt java-latest-openjdk-devel \
  butane ignition nm-applet testdisk nmap gparted ddrescue htop waypipe xdg-desktop-portal translate-shell \
  grim slurp wl-clipboard tesseract tesseract-langpack-eng ImageMagick zbar wf-recorder ffmpeg \
  cockpit-image-builder git-lfs curl kernel-tools noctalia \
  jemalloc-devel json-devel libcap-ng-devel libcurl-devel libglvnd-devel libjxl-devel libqalculate-devel \
  librsvg2-devel libseccomp-devel libsecret-devel libsndfile-devel libsodium-devel md4c-devel pam-devel \
  pipewire-devel polkit-devel sdbus-cpp-devel stb_image_resize2-devel stb_image_write-devel \
  tomlplusplus-devel wayland-protocols-devel


#dnf5 -y install @core @base-graphical @workstation-product @container-management @hardware-support @printing @gnome-desktop @firefox

# Use a COPR Example:
#
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/staging
#dnf5 -y copr disable ilyaz/LACT
#dnf5 -y copr enable ilyaz/LACT
dnf5 -y copr disable swayfx/swayfx
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable erikreider/SwayNotificationCenter
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable alternateved/cliphist
#### Example for enabling a System Unit File

systemctl enable podman.socket
