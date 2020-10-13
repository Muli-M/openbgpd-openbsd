openbgpd-openbsd
----------------

This repository creates a site-local binary Debian/Ubuntu package
providing standalone `openbgpd` from [portable OpenBGPd](https://github.com/openbgpd-portable/openbgpd-portable).

The following packages are needed to build it on Ubuntu:
    build-essential, make, git, autoconf, libtool, dpkg-dev, git-buildpackage, fakeroot, libssl-dev

Just type `make` to create .deb package.

