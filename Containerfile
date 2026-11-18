# Aurora with the NVIDIA 580 driver, for Pascal cards (GTX 10xx) that the
# current open-module driver in the -nvidia-open images no longer supports.
# See build_files/nvidia-lts.sh. FEDORA_VERSION must match the base; the build
# fails loudly when Aurora moves to a new Fedora release so it can be bumped here.
# (No BASE_IMAGE arg: main's shared workflow passes an empty one on this branch.)
ARG FEDORA_VERSION=45
ARG KERNEL_FLAVOR=ogc-lts

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-x86_64 AS akmods
FROM ghcr.io/ublue-os/akmods-nvidia-lts:${KERNEL_FLAVOR}-${FEDORA_VERSION}-x86_64 AS akmods-nvidia

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/aurora-dx:stable

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  --mount=type=bind,from=akmods,src=/,dst=/tmp/akmods \
  --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/akmods-rpms \
  /ctx/nvidia-lts.sh && \
  /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
