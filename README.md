# Kernel Development Scripts

This is a dump of my kernel development scripts. Some are rough-and-ready and
specific to my system, and some are more generic. Hopefully I'll get a chance to
clean them up over time. Generally I assume the distro I'm using (Arch Linux.)

Additionally you will need to install appropriate packages, again at some point
I will try to document the required packages.

## Acknowledgements

The qemu networking code is based on [Jakub Klinkovský][lahwaacz]'s
[scripts][lahwaacz-scripts], [qemu-launcher.sh][qemu-launcher.sh] is a good
starting point for this. His code in turn uses [xyne][xyne]'s work.

## Scripts

__NOTE:__ Many of these scripts are interdependent and assume they are all
available on the `PATH`.

### Generating

* `makeLinux` - Creates a [qemu][qemu] kernel development environment. The image
  is an Arch Linux system.
* `buildLinux` - Configures and builds the kernel, placing header and module
  files into the dev env image.
* `configLinux` - Sets kernel configuration options for the development environment.
* `rebuildLinux` - Same as `buildLinux` but runs `make mrproper` first.
* `installLinux` - Installs header and module files into the dev env image. This
  is invoked by `buildLinux` unless explicitly disabled.

### Running

* `runLinux` - Runs the kernel development environment with virtio networking.
* `debugLinux` - Connects `gdb` to a running dev env. Debugging config options
  are enabled by `buildLinux`.

### Code

* `checkStyle` - Runs `checkpatch.pl` against the specified files, ignoring line length.
* `checkStyleLines` - Runs `checkpatch.pl` against the specified files.

[qemu]:http://wiki.qemu.org/Main_Page

[lahwaacz]:https://github.com/lahwaacz
[lahwaacz-scripts]:https://github.com/lahwaacz/archlinux-dotfiles
[qemu-launcher.sh]:https://github.com/lahwaacz/archlinux-dotfiles/blob/master/Scripts/qemu-launcher.sh
[xyne]:http://xyne.archlinux.ca/notes/network/dhcp_with_dns.html
