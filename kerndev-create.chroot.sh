#!/bin/bash
set -e; set -o pipefail

# Configurable variables.
# Console dimensions, adjust to taste, this works well on my screen!
CONSOLE_ROWS=${CONSOLE_ROWS:-50}
CONSOLE_COLS=${CONSOLE_COLS:-80}

# Passed by calling script.
username=$1 # == $SUDO_USER
password=$2 # Optional, if not provided script will prompt.

# Functions.

# Taken from http://unix.stackexchange.com/a/14346. Non-root version didn't work.
function inside_chroot()
{
	[[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]
}

function usage()
{
	echo "usage: $0 [username] <root password>" >&2
}

# Sanity checks.
if ! inside_chroot; then
	echo not inside chroot! >&2
	exit 1
fi
if [[ -z "$username" ]]; then
	usage
	exit 1
fi

echo Configuring system...
# We want to use the network :)
pacman -S --noconfirm dhcpcd &>/dev/null
systemctl -q enable dhcpcd
# Retrieve wget so we can set it as the transfer command in a moment.
pacman -S --noconfirm wget &>/dev/null
# We assign Google DNS servers (outside this script), so fuck this hook.
echo "nohook resolv.conf" >> /etc/dhcpcd.conf
# No delay for incorrect password reattempt. Pet peeve!
sed -i 's/try_first_pass/try_first_pass nodelay/' /etc/pam.d/system-auth
echo tux > /etc/hostname

# Now get the packages we want.
echo Installing packages...
pacman -Sy --noconfirm strace zsh lsof openssh patch git &>/dev/null
# We don't need the linux package, we link to the kernel via a qemu switch.
pacman -R --noconfirm linux &>/dev/null || true

echo Setting up root password...
if [[ -z "$password" ]]; then
	# Don't let a typo ruin our day!
	while ! passwd; do
	echo Try again!
	done
else
	echo root:$password | chpasswd
fi

echo Setting up user $username with auto-login...
useradd -m $username -G wheel >&/dev/null || true
passwd -d $username >/dev/null
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
mkdir -p /etc/systemd/system/serial-getty@ttyS0.service.d
# I've found xterm works the best.
cat >/etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $username -s %i 115200,38400,9600 xterm
EOF

# Create script to 'leave' dev env to prevent accidentally running `sudo
# poweroff` in the host by mistake (I've done this... more than once :)
cat >/usr/bin/leave <<EOF
#!/bin/bash
sudo poweroff
EOF
chmod +x /usr/bin/leave
mv /.ssh /home/$username/
chown -R $username:$username /home/$username/.ssh

echo Configuring zsh...
user_zshrc=/home/$username/.zshrc

# Install oh-my-zsh
rm -rf /tmp/ls__omz
sudo -u $username git clone https://aur.archlinux.org/oh-my-zsh-git.git /tmp/ls__omz &>/dev/null
cd /tmp/ls__omz
sudo -u $username makepkg -si --noconfirm &>/dev/null
cp /usr/share/oh-my-zsh/zshrc $user_zshrc
echo ZSH_THEME=\"gallois\" > $user_zshrc
chsh -s /usr/bin/zsh $username >/dev/null

# For some reason qemu is sending carriage returns... :( fix!!
cat >>$user_zshrc <<EOF
stty icrnl
stty rows $CONSOLE_ROWS cols $CONSOLE_COLS
EOF
chown $username:$username $user_zshrc

# Failing to sync causes updates to not be written correctly.
echo Syncing changes...
sync
