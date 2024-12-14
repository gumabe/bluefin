build:
	podman pull ghcr.io/ublue-os/bluefin-dx-nvidia:latest
	podman build -t bluefin .

pull_aurora:
	podman pull ghcr.io/ublue-os/aurora-dx-nvidia:latest

