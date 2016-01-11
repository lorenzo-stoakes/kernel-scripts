#!/bin/bash
set -e; set -o pipefail

# Author: Jakub Klinkovský (Lahwaacz)
# https://github.com/lahwaacz

# Modified by Lorenzo Stoakes, with gratitude to Jakub's fine work!

########## Functions ##########

# Uncomment the following line to get debug output.
#DEBUG_OUTPUT=1
function say()
{
	[ -n "$DEBUG_OUTPUT" ] && echo $@ || true
}

function error()
{
	echo $@ >&2
}

## Check if a string represents a network interface
# $1: potential interface name
function is_interface()
{
	[[ -d "/sys/class/net/$1" ]]
}

## Create new TAP interface
# $1: name of the interface to create
function create_tap()
{
	if ! is_interface "$1"; then
		say "Creating TAP interface '$1'"
		ip tuntap add "$1" mode tap user "$username"
		ip link set dev "$1" up
	fi
}

## Delete TAP interface
# $1: name of the interface to delete
function del_tap()
{
	say "Deleting TAP interface '$1'"
	ip link set dev "$1" down
	ip tuntap del "$1" mode tap
}

## Check if the bridge has any interface
# $1: bridge interface name
function bridge_is_empty()
{
	[[ $(ls "/sys/class/net/$1/brif" | wc -w) == "0" ]]
}

## Create bridge interface if it does not exist
# $1: bridge interface name
function create_br()
{
	if is_interface "$1"; then
		if [[ ! -d "/sys/class/net/$1/brif" ]]; then
			error "Interface '$1' already exists and is not a bridge"
			exit 1
		fi
	else
		say "Creating bridge interface '$1'"
	brctl addbr "$1"
		#ip link add name "$1" type bridge
		ip link set dev "$1" up

		# Xyne's excellent script to launch NAT
		say "Starting NAT"
		kerndev-nat-launch.sh "$wan_nic" "$1" up
	fi
}

## Delete bridge interface if it exists and has no interface
# $1: bridge interface name
function del_br()
{
	if bridge_is_empty "$1"; then
		# Xyne's excellent script to kill NAT
		say "Stopping NAT"
		kerndev-nat-launch.sh "$wan_nic" "$1" down

		say "Deleting bridge interface '$1'"
		ip link set dev "$1" down
		ip link delete "$1" type bridge
	fi
}

## Add interface to the bridge
# $1: bridge interface name
# $2: name of the interface to add
function br_add_iface()
{
	say "Adding interface '$2' to bridge '$1'"
	ip link set dev "$2" promisc on up
	ip addr flush dev "$2" scope host #&>/dev/null
	ip addr flush dev "$2" scope site #&>/dev/null
	ip addr flush dev "$2" scope global #&>/dev/null
	#brctl addif $1 $2
	ip link set dev "$2" master "$1"
	# skip forwarding delay
	#bridge link set dev "$2" state 3
	#brctl setfd "$2" 0
}

## Remove interface from the bridge
# $1: bridge interface name
# $2: name of the interface to remove
function br_rm_iface()
{
	say "Removing interface '$2' from bridge '$1'"
	ip link set "$2" promisc off down
	ip link set dev "$2" nomaster
}

########## Main ###############

function print_qemu_tap_helper_usage()
{
	error "usage: $0 <username> <TAP interface> <bridge interface> <WAN interface> <up|down>"
	error "  <TAP interface> and <bridge interface> will be created,"
	error "  NAT from <WAN interface> to <bridge interface> will be set up"
}

if [[ $EUID -ne 0 ]]; then
	error "This script must be run as root."
	exit 1
fi

if [[ -z $4 ]]; then
	print_qemu_tap_helper_usage
	exit 1
else
	username="$1"
	tap_nic="$2"
	br_nic="$3"
	wan_nic="$4"
	action="$5"
fi

# exit on errors
set -e

case "$action" in
	up)
		create_br "$br_nic"
		create_tap "$tap_nic"
		br_add_iface "$br_nic" "$tap_nic"
	;;
	down)
		br_rm_iface "$br_nic" "$tap_nic"
		del_tap "$tap_nic"
		del_br "$br_nic"
	;;
	*)
		print_qemu_tap_helper_usage
		exit 1
	;;
esac
