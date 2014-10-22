This project aims at building an Ada cross compiler for the Nintendo DS.

It is based on [devkitARM][1], which is a cross compiler based on gcc and a
set of tools, targeting Nintendo GBA and DS, but only provides C, C++, and
Objective-C front ends.

[1]: http://devkitpro.org/ "devkitPor.org - Portal"

The project also borrows heavily from [avr-ada][2] as a successful example
for Ada front-end integration in an existing gcc-based tool chain.

[2]: http://sourceforge.net/apps/mediawiki/avr-ada/index.php?title=Main_Page

## Usage

This project has been developed and tested on a FreeBSD 9.2 host, using
gcc-aux 4.9.0 native compiler (from FreeBSD ports), `devkitARM` release 42
(based on `buildscripts` 2014-04-02) and targets a Nintendo DSlite unit.

The following command lines have been used to produce a working image.

### Cross-compiler build

	PATH=/usr/local/gcc-aux/bin:${PATH} \
	    cflags=-I/usr/local/include ldflags=-L/usr/local/lib \
	    BUILD_DKPRO_INSTALLDIR=/home/nat/devkitada \
	    BUILD_DKPRO_SRCDIR=/home/nat/tmp/devkit/distfiles \
	    PATCH_NONGNU=yes \
	    sh build.sh

The first two lines are probably specific to my FreeBSD setup: the first
one puts gcc-aux 4.9.0 first in the path, so it is used for all building,
while the second one sets up search paths for auxiliary libraries like gmp.

`BUILD_DKPRO_INSTALLDIR` specifies the install directory of the tools, and
is passed directly to devkitPro build scripts. It is subsequently used to
install the RTS inside the installed compiler directories.

`BUILD_DKPRO_SRCDIR` is optional and passed directly to devkitPro build
scripts, it points to a directory where downloaded tarballs are stores
(which is a very useful cache when iterating on the build process).

`PATCH_NONGNU` when non empty apply extra patches to devkitPro scripts and
libraries, so they work in a non-GNU environment. These patches do the
following:

  - fix `#!/bin/bash` shebangs,
  - use `gmake` instead of `make` in the only instance where autodetection
    of `gmake` is ignored,
  - explicitly use `-` input file when a tarball is piped into `tar` for
    extraction,
  - don't build `stlink` (not sure exactly why I can't build it properly,
    but it doesn't seem very useful).

### Example build

Since there is currently no functional Ada RTS, the example replaces a C
source at the earliest point, falling back to C-style link, and using the
install path above. The flags are taken directly from `devkitARM` example
makefiles.

Compile:

	/home/nat/devkitada/devkitARM/bin/arm-none-eabi-gcc \
	    -c -march=armv5te -mtune=arm946e-s -fomit-frame-pointer \
	    -ffast-math -mthumb -mthumb-interwork \
	    -o ada_test.o ada_test.adb

Link:

	/home/nat/devkitada/devkitARM/bin/arm-none-eabi-gcc \
	    -specs=ds_arm9.specs -g -mthumb -mthumb-interwork \
	    ada_test.o -L/home/nat/devkitada/libnds/lib -lnds9 \
	    -o ada_test.elf

Image integration:

	DEVKITPRO=/home/nat/devkitada DEVKITARM=/home/nat/devkitada/devkitARM \
	    /home/nat/devkitada/devkitARM/bin/ndstool \
	    -c ada_test.nds -9 ada_test.elf \
	    -b /home/nat/devkitada/libnds/icon.bmp "Ada test;manually built;"

When run, the test procedure shows a frame counter followed by the keypad
status word.

## Roadmap

This project is still very young and a lot of work remains. The current
plan includes the following actions:

  - build a minimal RTS for the ARM9
  - make it so that the linked object file for each processor is built
    using a cross `gnatmake` and a `.gpr` file
  - bind or rewrite `devkitARM` libraries
  - build a RTS for ARM7 if we don't leave it to `libnds`

Stretch goals:

  - find a way to build the target image in a single command
    (maybe with `gprbuild` ?)
  - expand the RTS with new features (maybe aim for Ravenscar concurrency?)
  - build and run ACATS
