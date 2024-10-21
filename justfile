build:
	podman pull ghcr.io/ublue-os/bluefin-dx-nvidia:latest
	podman build -t bluefin .
