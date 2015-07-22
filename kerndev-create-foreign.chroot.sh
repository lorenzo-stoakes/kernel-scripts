#!/bin/bash
set -e; set -o pipefail

# Configurable variables.
# Console dimensions, adjust to taste, this works well on my screen!
CONSOLE_ROWS=${CONSOLE_ROWS:-50}
CONSOLE_COLS=${CONSOLE_COLS:-80}

# Passed by calling script.
username=$1 # == $SUDO_USER
password=$2 # Optional, if not provided script will prompt.

user_home=/home/$username
zsh=$user_home/.oh-my-zsh
user_zshrc=$user_home/.zshrc

guest_name=deviant

chroot_path="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Functions.

# Taken from http://unix.stackexchange.com/a/14346. Non-root version didn't work.
function inside_chroot()
{
	[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]
}

function usage()
{
	echo "usage: $0 [username] <root password>" >&2
}

# $1: path of file to set owned by $username.
function give_back()
{
	chown -R $username:$username $1
}

# Sanity checks.
if ! inside_chroot; then
	echo not inside chroot! >&2
	exit 1
fi
if [ -z "$username" ]; then
	usage
	exit 1
fi

echo Configuring system...
# We need to define PATH ourselves.
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# We want to use the network :)
systemctl -q enable dhcpcd 2>/dev/null

cat > /etc/systemd/network/eth.network <<EOF
[Match]
Name=eth0
[Network]
DHCP=yes
EOF
systemctl -q enable systemd-networkd 2>/dev/null

# We assign Google DNS servers (outside this script), so fuck this hook.
echo "nohook resolv.conf" >> /etc/dhcpcd.conf

# Assign host name.
echo $guest_name > /etc/hostname
grep -v 127.0.0.1 /etc/hosts > /etc/_hosts
echo "127.0.0.1	localhost $guest_name" > /etc/hosts
cat /etc/_hosts >> /etc/hosts
rm /etc/_hosts

echo Setting up root password...
if [ -z "$password" ]; then
	# Don't let a typo ruin our day!
	while ! passwd; do
		echo Try again!
	done
else
	echo root:$password | chpasswd
fi

echo Setting up user $username with auto-login...
useradd -m $username -G sudo >/dev/null || true
passwd -d $username >/dev/null
mkdir -p /etc/systemd/system/serial-getty@ttyAMA0.service.d
# I've found xterm works the best.
cat >/etc/systemd/system/serial-getty@ttyAMA0.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $username -s %i 115200,38400,9600 xterm
EOF
# Screen: C-a is what qemu uses, so use C-b instead.
cat >>$user_home/.screenrc <<EOF
escape ^Bb
EOF
# Create script to 'leave' dev env to prevent accidentally running `sudo
# poweroff` in the host by mistake (I've done this... more than once :)
cat >/usr/bin/leave <<EOF
#!/bin/bash
sudo poweroff
EOF
chmod +x /usr/bin/leave
mv /.ssh $user_home/ || true
give_back $user_home/.ssh

echo Configuring zsh...

# git + qemu/arm = pain, so have pre-cloned it here.
# TODO: Disable updates, fix git/qemu issue ;)
mv /oh-my-zsh $zsh
give_back $zsh
cp $zsh/templates/zshrc.zsh-template $user_zshrc

sed -i -e "/^export ZSH=/ c\\
export ZSH=$zsh
" $user_zshrc

sed -i -e "/export PATH=/ c\\
export PATH=\"$PATH\"
" $user_zshrc

# Change theme.
sed -i -e 's/robbyrussell/gallois/' $user_zshrc

# For some reason qemu is sending carriage returns... :( fix!!
cat >>$user_zshrc <<EOF
stty icrnl
stty rows $CONSOLE_ROWS cols $CONSOLE_COLS
EOF

give_back $user_zshrc

chsh -s /usr/bin/zsh $username >/dev/null

# Failing to sync causes updates to not be written correctly.
echo Syncing changes...
sync
