#!/bin/bash
# Put the NVIDIA 580 driver on a non-NVIDIA Aurora base.
#
# 580 is the last NVIDIA branch that supports Pascal (GTX 10xx); the open kernel
# modules used by Aurora's -nvidia-open images need Turing or newer. Universal Blue
# still builds the 580 closed modules as ghcr.io/ublue-os/akmods-nvidia-lts, but only
# against their ogc-lts kernel (the one Bazzite ships), not Aurora's Fedora kernel.
# So this script swaps the kernel for that one, reinstalls the base's extra kmods
# built for it (ghcr.io/ublue-os/akmods), and then runs Universal Blue's own
# nvidia-install.sh, the same way their images do.
#
# Expects (bind-mounted by the Containerfile):
#   /tmp/akmods       ghcr.io/ublue-os/akmods:<flavor>-<fedora>-x86_64
#   /tmp/akmods-rpms  ghcr.io/ublue-os/akmods-nvidia-lts:<flavor>-<fedora>-x86_64
set -ouex pipefail

COMMON=/tmp/akmods
export AKMODNV_PATH=/tmp/akmods-rpms

source "${AKMODNV_PATH}/kmods/nvidia-vars"   # KERNEL_VERSION, NVIDIA_AKMOD_VERSION, ...
NEW_KVER="${KERNEL_VERSION}"

# Both akmods images are rebuilt daily and must have been built for the same kernel.
# If one lags behind the other, fail; the previous image stays published.
COMMON_KVER=$(rpm -qp --qf '%{VERSION}-%{RELEASE}.%{ARCH}' "${COMMON}"/kernel-rpms/kernel-core-*.rpm)
if [[ "${COMMON_KVER}" != "${NEW_KVER}" ]]; then
    echo "akmods kernel ${COMMON_KVER} != akmods-nvidia-lts kernel ${NEW_KVER}" >&2
    exit 1
fi
if [[ "${NEW_KVER}" != *".fc$(rpm -E %fedora)."* ]]; then
    echo "Kernel ${NEW_KVER} is not built for Fedora $(rpm -E %fedora)" >&2
    exit 1
fi

OLD_KVER=$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n')
if [[ $(wc -l <<<"${OLD_KVER}") -ne 1 ]]; then
    echo "Expected exactly one kernel in the base, found: ${OLD_KVER}" >&2
    exit 1
fi

### Remove the base kernel and every package that ships modules for it
mapfile -t OLD_PKGS < <(find "/usr/lib/modules/${OLD_KVER}" -type f -print0 |
    xargs -0 rpm -qf --qf '%{NAME}\n' 2>/dev/null | grep -v 'not owned' | sort -u)
mapfile -t OLD_PKGS < <(printf '%s\n' "${OLD_PKGS[@]}" kernel kernel-devel kernel-devel-matched |
    sort -u | xargs rpm -q --qf '%{NAME}\n' 2>/dev/null | grep -v 'not installed' || true)
echo "Removing: ${OLD_PKGS[*]}"
rpm -e --nodeps "${OLD_PKGS[@]}"
rm -rf "/usr/lib/modules/${OLD_KVER}"

### Install the LTS kernel and the base's kmods rebuilt for it
# The kernel's posttrans hooks try to build an initramfs, which fails in a container
# build (and dnf5 treats that as fatal). Stub them out for the install, as Universal
# Blue's own images do; the initramfs is generated explicitly below.
HOOKS=(/usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/50-dracut.install)
for h in "${HOOKS[@]}"; do
    [[ -e "${h}" ]] || continue
    mv "${h}" "${h}.bak"
    printf '#!/bin/sh\nexit 0\n' >"${h}"
    chmod +x "${h}"
done
dnf5 -y install "${COMMON}"/kernel-rpms/*.rpm
for h in "${HOOKS[@]}"; do
    [[ -e "${h}.bak" ]] && mv -f "${h}.bak" "${h}"
done
# The kernel scriptlets still drop files in /boot; bootc populates it at deploy time.
find /boot -mindepth 1 -delete

KMODS=()
MISSING=()
for pkg in "${OLD_PKGS[@]}"; do
    [[ "${pkg}" == kmod-* ]] || continue
    rpm=$(compgen -G "${COMMON}/rpms/kmods/${pkg}-${NEW_KVER}-*.rpm" || true)
    if [[ -n "${rpm}" ]]; then KMODS+=("${rpm}"); else MISSING+=("${pkg}"); fi
done
if [[ ${#KMODS[@]} -gt 0 ]]; then
    dnf5 -y install "${KMODS[@]}"
fi
if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "WARNING: no ${NEW_KVER} build of: ${MISSING[*]} (dropped from the image)"
fi

### NVIDIA 580 driver, installed by Universal Blue's own script
# Aurora's mesa comes from negativo17's fedora-multimedia repo, which the published
# image ships disabled. The script installs 32-bit mesa and expects that repo to be
# on (as it is in Aurora's own build); otherwise Fedora's older i686 mesa is picked
# and conflicts with the installed x86_64 one. Enable it just for the install.
dnf5 config-manager setopt fedora-multimedia.enabled=1
IMAGE_NAME=aurora-dx bash "${AKMODNV_PATH}/ublue-os/nvidia-install.sh"
dnf5 config-manager setopt fedora-multimedia.enabled=0

### Initramfs for the new kernel (bootc images ship it inside the kernel dir)
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "${NEW_KVER}" --reproducible --zstd -v --add ostree \
    -f "/usr/lib/modules/${NEW_KVER}/initramfs.img"
chmod 0600 "/usr/lib/modules/${NEW_KVER}/initramfs.img"

# Sanity checks: one kernel, nvidia module present and matching the userspace driver.
[[ "$(ls /usr/lib/modules)" == "${NEW_KVER}" ]]
modinfo -k "${NEW_KVER}" -F version nvidia | grep -qx "${NVIDIA_AKMOD_VERSION%-*}"
