#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# Verbose and exit on errors
set -ex

SetupRealSensePi() {

	# Do additional tasks that are common across all images,
	# but not suitable for inclusion in install.sh
	echo "Setting up for RealSense applications..."

	# Limit the maximum length of systemd-journald logs
	mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/60-limit-log-size.conf <<EOF
# Added by Photonvision to keep the logs to a reasonable size
[Journal]
SystemMaxUse=100M
EOF

	# INSTALL REAL

	apt-get update -y
	apt-get upgrade -y

	# pyenv deps
	apt-get install -y make build-essential libssl-dev zlib1g-dev \
		libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
		xz-utils tk-dev libffi-dev \
		liblzma-dev python3-openssl git python3-dev python3-pip python3-venv \
		libssl-dev libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev v4l-utils \
		git wget cmake libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev at \
		xorg mesa-utils ffmpeg

	cd ~
	git clone --depth 1 --branch v2.56.3 https://github.com/IntelRealSense/librealsense.git

	cd librealsense
	./scripts/setup_udev_rules.sh

	mkdir build && cd build
	cmake ../ -DBUILD_EXAMPLES=true -DFORCE_RSUSB_BACKEND=true -DPYTHON_EXECUTABLE=$(which python3) -DBUILD_PYTHON_BINDINGS=true -DBUILD_GRAPHICAL_EXAMPLES=true
	make -j4
	make install

	#done with repo, cleanup
	cd ~
	rm -rf librealsense
	apt-get --yes clean
	apt-get --yes autoclean
	apt-get --yes autoremove

	# install ntcore
	cd ~
	git clone --branch 2025.2.1 https://github.com/robotpy/mostrobotpy
	cd mostrobotpy

	pip3 install -r rdev_requirements.txt
	pip3 install numpy

	# get rid of everything after pyntcore
	python3 -c '(path:=__import__("pathlib").Path("./rdev.toml")).write_text((re:=__import__("re")).match(r"^.*pyntcore.*?(?=\[)",path.read_text(),re.DOTALL)[0])'
	./rdev.sh ci run

	#done with repo, cleanup
	pip3 cache purge
	cd ~
	rm -rf mostrobotpy

	# nice to haves
	pip3 install --no-cache-dir numpy scipy opencv-python tqdm flask requests pytest

	# exploring
	pip3 install --no-cache-dir streamlit pandas black pillow
}

Main() {
	case $RELEASE in
		jammy)
			SetupRealSensePi
			;;
	esac
} # Main

Main "$@"
