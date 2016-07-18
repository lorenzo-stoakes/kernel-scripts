#!/bin/bash
set -e; set -o pipefail

# This script is source'd by kerndev-shared.sh and contains config variables
# that can be set when running kerndev- scripts along with default values where
# appropriate.

debian_mirror_default=http://mirror.positive-internet.com/debian
debian_packages_default="netbase,ifupdown,net-tools,dhcpcd5,iproute,wget,sudo,\
zsh,curl,ca-certificates,man-db,git,pciutils,usbutils,iputils-ping,less,nano,\
kmod"
debian_version_default=jessie
image_size_default=30G
kerndev_path_default=$HOME/kerndev/qemu-images
linux_dev_path_default=$HOME/kerndev/kernels/linux
qemu_cores_default=4
qemu_ram_default=2G

# Configuration options with default values:-

# DEBIAN_ options are used for the aarch64 build as Arch doesn't yet have an
# aarch64 build :(
DEBIAN_MIRROR=${DEBIAN_MIRROR:-$debian_mirror_default}
DEBIAN_PACKAGES=${DEBIAN_PACKAGES:-$debian_packages_default}
DEBIAN_VERSION=${DEBIAN_VERSION:-$debian_version_default}
# Size of image created by kerndev-create.
IMAGE_SIZE=${IMAGE_SIZE:-$image_size_default}
# Location to store image files in.
KERNDEV_PATH=${KERNDEV_PATH:-$kerndev_path_default}
# Location containing the kernel source code.
LINUX_DEV_PATH=${LINUX_DEV_PATH:-$linux_dev_path_default}
# QEMU settings.
QEMU_CORES=${QEMU_CORES:-$qemu_cores_default}
QEMU_RAM=${QEMU_RAM:-$qemu_ram_default}

# Configuration options which default to being unset, included here for
# documentation:-

# If set, run a chroot script in the development image.
ACCESS_CHROOT=${ACCESS_CHROOT:-}
# kerndev-build: If set, don't run kerndev-install after building.
DONT_INSTALL=${DONT_INSTALL:-}
# If set, enable gcov configuration settings, and copy kernel source into image.
ENABLE_GCOV=${ENABLE_GCOV:-}
# If set, enable kernel support for docker.
ENABLE_DOCKER_SUPPORT=${ENABLE_DOCKER_SUPPORT:-}
# If set, do not say 'Done!' when done :)
NO_DONE=${NO_DONE:-}
# Custom qemu settings, e.g. a USB device pass-through like
# '-usbdevice host:3.5'.
QEMU_CUSTOM_SETTINGS=${QEMU_CUSTOM_SETTINGS:-}
# kerndev-build: If set, forces rebuild.
REBUILD=${REBUILD:-}
# Set to define a root password, otherwise prompts for one on kerndev-create.
ROOT_PASSWORD=${ROOT_PASSWORD:-}
# If set, uses existing rootfs image on kerndev-create rather than creating a
# new one.
USE_EXISTING_IMAGE=${USE_EXISTING_IMAGE:-}
# If set, output from make is not silenced.
VERBOSE=${VERBOSE:-}
