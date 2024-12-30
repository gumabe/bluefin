pull:
	podman pull ghcr.io/ublue-os/bluefin-dx-nvidia:latest
build:
	podman build -t bluefin .


fullbuild: pull build
pull_aurora:
	podman pull ghcr.io/ublue-os/aurora-dx-nvidia:latest

