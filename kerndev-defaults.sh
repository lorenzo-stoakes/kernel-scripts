#!/bin/bash
set -e; set -o pipefail

# This script is source'd by kerndev-shared.sh and contains config variables
# that can be set when running kerndev- scripts along with default values where
# appropriate.

default_debian_packages="netbase,ifupdown,net-tools,dhcpcd5,iproute,wget,sudo,\
zsh,curl,ca-certificates,man-db,git,pciutils,usbutils,iputils-ping,less,nano,\
kmod"

# Configuration options with default values:-

# DEBIAN_ options are used for the aarch64 build as Arch doesn't yet have an
# aarch64 build :(
DEBIAN_MIRROR=${DEBIAN_MIRROR:-http://mirror.positive-internet.com/debian}
DEBIAN_PACKAGES=${DEBIAN_PACKAGES:-$default_debian_packages}
DEBIAN_VERSION=${DEBIAN_VERSION:-jessie}
# Size of image created by kerndev-create.
IMAGE_SIZE=${IMAGE_SIZE:-30G}
# Location to store image files in.
KERNDEV_PATH=${KERNDEV_PATH:-$HOME/kerndev}
# Location containing the kernel source code.
LINUX_DEV_PATH=${LINUX_DEV_PATH:-$HOME/linux}
# QEMU settings.
QEMU_CORES=${QEMU_CORES:-4}
QEMU_RAM=${QEMU_RAM:-4G}

# Configuration options which default to being unset, included here for
# documentation:-

# If set, run a chroot script in the development image.
ACCESS_CHROOT=${ACCESS_CHROOT:-}
# kerndev-build: If set, don't run kerndev-install after building.
DONT_INSTALL=${DONT_INSTALL:-}
# If set, enable gcov configuration settings.
ENABLE_GCOV=${ENABLE_GCOV:-}
# If set, do not say 'Done!' when done :)
NO_DONE=${NO_DONE:-}
# kerndev-build: If set, forces rebuild.
REBUILD=${REBUILD:-}
# Set to define a root password, otherwise prompts for one on kerndev-create.
ROOT_PASSWORD=${ROOT_PASSWORD:-}
# If set, uses existing rootfs image on kerndev-create rather than creating a
# new one.
USE_EXISTING_IMAGE=${USE_EXISTING_IMAGE:-}
# If set, output from make is not silenced.
VERBOSE=${VERBOSE:-}
# Custom qemu settings, e.g. a USB device pass-through like
# '-usbdevice host:3.5'.
QEMU_CUSTOM_SETTINGS=${QEMU_CUSTOM_SETTINGS:-}
