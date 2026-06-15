IGNITION_CONFIG="/var/home/mathias/tools/gumabe/alphacore/ucore.ign"
IMAGE="/var/home/mathias/tools/gumabe/alphacore/myos.qcow2"
#IMAGE="/var/home/mathias/.local/share/libvirt/images/fedora-coreos-43.20260105.3.0-qemu.x86_64.qcow2"
# for x86/aarch64:
IGNITION_DEVICE_ARG="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"

echo $IMAGE
# qemu-kvm -m 2048 -cpu host -nographic -snapshot \
qemu-kvm -m 2048 -cpu host -nographic -snapshot \
    -drive "if=virtio,file=${IMAGE}" ${IGNITION_DEVICE_ARG} \
    -nic user,model=virtio,hostfwd=tcp::2222-:22
