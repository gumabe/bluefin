#!/usr/bin/env bash
# Pin the base image to a digest and find the ublue-os/akmods-zfs image built for
# exactly that kernel. Aurora dropped ZFS (ublue-os/aurora#2918), but ucore still
# builds ZFS kmods against the same Fedora kernel RPMs, so we borrow those.
#
# Prints KEY=VALUE lines (BASE_IMAGE, ZFS_AKMODS) suitable for $GITHUB_ENV
# or for `--build-arg`. Exits non-zero if no ZFS build exists for the base kernel,
# so CI fails and the previously published image stays in place.
set -euo pipefail

BASE="${1:-ghcr.io/ublue-os/aurora-dx-nvidia-open:stable}"
ZFS_REPO="ghcr.io/ublue-os/akmods-zfs"
ZFS_FLAVORS=(${ZFS_FLAVORS:-coreos-stable coreos-testing})

inspect=$(skopeo inspect --retry-times 3 "docker://${BASE}")
digest=$(jq -r '.Digest' <<<"$inspect")
kernel=$(jq -r '.Labels["ostree.linux"]' <<<"$inspect")
fedora=$(sed -E 's/.*\.fc([0-9]+)\..*/\1/' <<<"$kernel")

for flavor in "${ZFS_FLAVORS[@]}"; do
    ref="${ZFS_REPO}:${flavor}-${fedora}-${kernel}"
    if skopeo inspect --retry-times 3 --raw "docker://${ref}" >/dev/null 2>&1; then
        echo "BASE_IMAGE=${BASE%:*}@${digest}"
        echo "Base kernel ${kernel}, using ${ref}" >&2
        echo "ZFS_AKMODS=${ref}"
        exit 0
    fi
done

echo "No ${ZFS_REPO} build for kernel ${kernel} (tried: ${ZFS_FLAVORS[*]})" >&2
exit 1
