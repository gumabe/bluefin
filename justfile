fullbuild: pull_aurora build
pull_aurora:
	podman pull ghcr.io/ublue-os/aurora-dx-nvidia:latest

pull:
	podman pull ghcr.io/ublue-os/bluefin-dx-nvidia:latest
build:
	podman build -t registry.local.alpha-awards.com/gumabe/bluefin .



