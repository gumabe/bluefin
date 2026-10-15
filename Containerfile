# Set by scripts/resolve-zfs.sh (CI and `just build`): base pinned by digest, plus the
# ucore ZFS kmods built for that exact kernel. Defaults are for ad-hoc builds only.
ARG BASE_IMAGE=ghcr.io/ublue-os/aurora-dx-nvidia-open:stable
ARG ZFS_AKMODS=ghcr.io/ublue-os/akmods-zfs:coreos-stable-44-7.2.5-200.fc44.x86_64

FROM ${ZFS_AKMODS} AS akmods-zfs

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ${BASE_IMAGE}
#FROM ghcr.io/ublue-os/bazzite-dx-nvidia:stable
#ghcr.io/wayblueorg/sway-nvidia-open
#FROM ghcr.io/ublue-os/bazzite:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  --mount=type=bind,from=akmods-zfs,src=/rpms/kmods/zfs,dst=/tmp/rpms/zfs \
  /ctx/build.sh && \
  /ctx/zfs.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
