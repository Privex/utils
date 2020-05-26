Privex Random Utilities
=======================

This repository contains a collection of small utilities we've built, which aren't big enough
to waste time creating their own independent repository for.

Most of the utilities are small Bash or ZSH shellscripts intended for use on GNU/Linux, however
some of the utilities may also work on other platforms, such as Mac OSX, or other BSD's such as FreeBSD.

To help save us time, some of our bigger utilities such as [SlotMgr](https://github.com/Privex/slotmgr) are
included as submodules in the `repos/` folder. These are automatically installed alongside the repo's utilities
in `bin/`.

Some of the utilities included:

   - `copy-bin-chroot` - Copies one or more binaries into a folder, and automatically detects any shared libraries that
   they depend on - copies the libraries into the same output folder. Simplifies installing compiled software into a
   restricted chroot.
 
   - `detect-relpath` - Returns a relative `../..` path between a parent folder and a nested subfolder.
 
   - `find-libs` - Used by various other included utilities - outputs a list of shared libraries used by a given binary
   by filtering the output of `ldd` using `sed`.
 
  - `lib-copy` -  Detects the libraries required by the binaries specified as arguments, copies the libraries in their
    original hierarchical format into `output_folder` (if not specified, defaults to `PWD`).
  
  - `mk-user-chroot` - Creates the Linux user `username` and prepares their home directory for use with an SSH chroot.
    For more detailed information and usage, run `mk-user-chroot --help`
  
  - `mockscript` - **mockscript** is a very basic "stand-in program" which can be used during development/debugging. 
    It's designed to be copied/symlinked to the name of another more "destructive" program such as 'dd' or 'fdisk'. 
    It simply prints out any data received via pipe (stdin), and any command line arguments passed to it.
  
  - `raid_part` - Quickly format one or more disks with a blank MBR or GPT Linux partition which fills all available space.

    Designed to save time and prevent human error when partitioning an array of disks for use with LVM / Software RAID.
  
  - `strip-end-slash` - A very simple utility which strips ending slashes from paths if present. Paths can be specified as
    positional arguments, or piped into stdin separated by newlines (like most standard unix utilities).

    e.g. `strip-end-slash /usr/bin/` would output `/usr/bin`. 



```sh
#################################################################
#                                                               #
#    +===================================================+      #
#    |                 © 2020 Privex Inc.                |      #
#    |               https://www.privex.io               |      #
#    +===================================================+      #
#    |                                                   |      #
#    |        Privex Random Utilities                    |      #
#    |        License: GNU GPL v3.0                      |      #
#    |                                                   |      #
#    |        Core Developer(s):                         |      #
#    |                                                   |      #
#    |          (+)  Chris (@someguy123) [Privex]        |      #
#    |                                                   |      #
#    +===================================================+      #
#                                                               #
#           Git: https://github.com/Privex/utils                #
#                                                               #
#    Copyright (C) 2020  Privex Inc. (https://www.privex.io)    #
#                                                               #
#################################################################
```

Install
-------

```sh
# Clone the repo
git clone https://github.com/Privex/utils.git
cd utils
# Run our quick install script ( by default installs everything into /usr/local/bin )
./install.sh

# If you don't want to / are unable to install into /usr/local/bin - you can override it.
# Set the environment variable UTIL_INSTALL_DIR to customise the installation folder
UTIL_INSTALL_DIR="${HOME}/.local/bin" ./install.sh

```

License
-------

All utilities included with this project are bundled under the **GNU GPL v3.0** License.

NOTE: Some utilities included via Git Submodules (folders within `repos/`) may be released under
a separate license.

Please read [LICENSE.txt](ttps://github.com/Privex/utils/blob/master/LICENSE.txt) and
[gpl-3.0.txt](ttps://github.com/Privex/utils/blob/master/gpl-3.0.txt) for more information.
