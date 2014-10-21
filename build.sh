#!/bin/sh

# Copyright (c) 2014, Natacha Porté
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

set -e

: ${RESOURCE_DIR:=$(dirname "$0")}
: ${DEVKIT_BUILDSCRIPTS:=${PWD}/buildscripts}

if test -z "${BUILD_DKPRO_INSTALLDIR}"; then
	echo "Please set BUILD_DKPRO_INSTALLDIR" >&2
	exit 1
fi

if test -z "${BUILD_DKPRO_PACKAGE}"; then
	export BUILD_DKPRO_PACKAGE=1
elif ! test x"${BUILD_DKPRO_PACKAGE}" = x1; then
	echo "Invalid value for BUILD_DKPRO_PACKAGE: ${BUILD_DKPRO_PACKAGE}" >&2
	exit 1
fi

if test -n "${BUILD_DKPRO_SRCDIR}" \
    && test -f "${BUILD_DKPRO_SRCDIR}/buildscripts-20140402.tar.bz2" \
    && ! test -d "${DEVKIT_BUILDSCRIPTS}"; then
	DEVKIT_BUILDSCRIPTS_TAR_BZ2="${BUILD_DKPRO_SRCDIR}/buildscripts-20140402.tar.bz2"
fi

if test -f "${DEVKIT_BUILDSCRIPTS_TAR_BZ2}"; then
	rm -rf "${DEVKIT_BUILD_SCRIPTS}"
	tar xjf "${DEVKIT_BUILDSCRIPTS_TAR_BZ2}" \
	    -C "$(dirname "${DEVKIT_BUILD_SCRIPTS}")"
fi

if ! test -x "${DEVKIT_BUILDSCRIPTS}"/build-devkit.sh; then
	echo "Unable to find devkitPro buildscripts at ${DEVKIT_BUILDSCRIPTS}" >&2
	exit 1
fi

patch -p1 -d"${DEVKIT_BUILDSCRIPTS}" <"${RESOURCE_DIR}"/patch/build-ada.diff
cp -i "${RESOURCE_DIR}/patch/gcc-4.9.0.patch" \
    "${DEVKIT_BUILDSCRIPTS}/dkarm-eabi/patches/"

if test -n "${PATCH_NONGNU}"; then
	patch -p1 -d"${DEVKIT_BUILDSCRIPTS}" \
	    <"${RESOURCE_DIR}"/patch/build-nongnu.diff
	rm -f "${RESOURCE_DIR}/abort"

	(while ! test -f "${RESOURCE_DIR}/abort" \
	    -o -d "${DEVKIT_BUILDSCRIPTS}/.devkitARM/dfu-util-0.7";
	    do sleep 1; done;
	test -f "${RESPOURCE_DIR}/abort" \
	    || patch -p1 -d"${DEVKIT_BUILDSCRIPTS}/.devkitARM" \
	    <"${RESOURCE_DIR}/patch/tools-nongnu.diff" \
	    >"${RESOURCE_DIR}/patch-tools.log") &
fi

(cd "${DEVKIT_BUILDSCRIPTS}" && ./build-devkit.sh)

mkdir "${BUILD_DKPRO_INSTALLDIR}/devkitARM/lib/gcc/arm-none-eabi/4.9.0/adainclude"
cp "${RESOURCE_DIR}/rts/system.ads" "${BUILD_DKPRO_INSTALLDIR}/devkitARM/lib/gcc/arm-none-eabi/4.9.0/adainclude/"
