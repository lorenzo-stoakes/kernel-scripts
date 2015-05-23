# Kernel Development Scripts

This is a dump of my kernel development scripts. Some are rough-and-ready and
specific to my system, and some are more generic. Hopefully I'll get a chance to
clean them up over time. Generally I assume the distro I'm using (Arch Linux.)

Additionally you will need to install appropriate packages, again at some point
I will try to document the required packages.

The scripts have been expanded to include some rudimentary support for the
aarch64 architecture. To use this functionality, run `makeLinux aarch64` and
`runLinux aarch64`.

## Acknowledgements

The qemu networking code is based on [Jakub Klinkovský][lahwaacz]'s
[scripts][lahwaacz-scripts], [qemu-launcher.sh][qemu-launcher.sh] is a good
starting point for this. His code in turn uses [xyne][xyne]'s work.

## Scripts

__NOTE:__ Many of these scripts are interdependent and assume they are all
available on the `$PATH`.

### Maintaining

* `updateLinux` - Updates a list of linux trees in specific directories and on
  specific branches. This is configured to my personal setup, so you _will_ need
  to edit this script to fit your set up. The list of directories and branches
  are clearly separated from the actual code that updates so this is a quick
  task.

### Generating

* `makeLinux` - Creates a [qemu][qemu] kernel development environment. The image
  is an Arch Linux system.
* `buildLinux` - Configures and builds the kernel, optionally placing header and
  module files into the dev env image. It accepts a single optional argument
  which, if provided, specifies a cross-compile target architecture.
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
