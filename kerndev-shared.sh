#!/bin/bash
set -e; set -o pipefail

source kerndev-functions.sh
source kerndev-defaults.sh

# Fixup the LINUX_DEV_PATH.
LINUX_DEV_PATH="$(find_base_linux_path $LINUX_DEV_PATH)"
