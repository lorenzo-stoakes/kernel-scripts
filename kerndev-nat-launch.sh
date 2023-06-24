#!/bin/bash
set -e; set -o pipefail

# Original author: Xyne
# http://xyne.archlinux.ca/notes/network/dhcp_with_dns.html

# Via https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function print_usage() {
	echo "usage: $0 <WAN interface> <subnet interface> <up|down>"
}

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root." >&2
	exit 1
fi

if [[ -z $3 ]]; then
	print_usage
	exit 1
else
	wan_nic="$1"
	subnet_nic="$2"
	action="$3"
fi

mask=/24
subnet_ip=192.168.137.0$mask
server_ip=192.168.137.23$mask
iptables=$SCRIPT_DIR/idemptables
dnsmasq_pid=/run/dnsmasq.pid
dnsmasq_lease=/run/dnsmasq.lease
dnsmasq_port=0
dnsmasq_dhcp_range="192.168.137.100,192.168.137.150,6h"

source kerndev-nat-launch-subnet.sh

launch_subnet "$action"
