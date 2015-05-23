#!/bin/bash
set -e; set -o pipefail

# Shared functions, to be `source`d by other scripts.

# Displays parameteters with command name prepended, outputted to stderr.
# $@: message to display.
function error()
{
	echo $(basename $0): $@ >&2
}

# Displays parameteters with command name prepended, outputted to stderr, then
# exits with error status.
# $@: message to display.
function fatal()
{
	error $@
	exit 1
}

# Pushes directory onto pushd stack without outputting anything.
# $1: Directory to add to pushd stack.
function push()
{
	pushd $1 >/dev/null
}

# Pops directory off pushd stack without outputting anything.
function pop()
{
	popd >/dev/null
}

# Pushes into linux dev directory (at $LINUX_DEV_PATH), assumes this variable is
# available.
function push_linux()
{
	push $LINUX_DEV_PATH
}

# Pushes into kernel dev directory (at $KERNDEV_PATH), assumes this variable is
# available.
function push_kerndev()
{
	push $KERNDEV_PATH
}

# Replaces the current script with an elevated version of itself.
# If parameters are to be preserved, needs to be passed $@.
function elevate()
{
	if [ $EUID != 0 ]; then
		exec sudo -E $0 $@
		exit $?
	fi
}

# Checks whether the specified binaries are available on the $PATH.
# $@: Binaries to check.
function checkExists()
{
	for f in $@; do
	if ! (which $f &>/dev/null) then
		fatal "Can't find required binary '$f' on path"
	fi
	done
}

# Attempt to unmount /mnt, ignore any failures.
function unmount()
{
	umount /mnt &>/dev/null || true
}

# Give ownership of the specified directory to the user (assumes $SUDO_USER is
# available!)
# $1: Directory to 'give back' to user $SUDO_USER.
function give_back()
{
	[ -z "$SUDO_USER" ] && error "give_back: SUDO_USER not defined." || \
		chown -R $SUDO_USER:$SUDO_USER $1
}

# Run make with specified arguments and $make_opts. If $VERBOSE is set, output
# to controlling terminal, otherwise redirect to /dev/null.
# $@: make arguments.
function mak()
{
	[ -z $VERBOSE ] && out="null" || out="tty"

	make $make_opts $@ >/dev/$out
}
