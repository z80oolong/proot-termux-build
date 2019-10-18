#!/bin/sh

wget_command=`which wget`
PROOT_VERSION="5.1.0.114"
PROOT_URL="https://github.com/z80oolong/proot-termux-build/releases/download/v${PROOT_VERSION}"

case $1 in
    proot.arm)
        PROOT="proot.arm"
	ARCH="arm"
	;;
    proot.x86-32)
        PROOT="proot.x86-32"
	ARCH="x86-32"
	;;
    proot-cross.arm)
        PROOT="proot-cross.arm"
	ARCH="arm"
	;;
    proot-cross.x86-32)
        PROOT="proot-cross.x86-32"
	ARCH="x86-32"
	;;
    *)
        echo "Usage: download-proot.sh [proot.arm|proot.x86-32|proot-cross.arm|proot-cross.x86-32]"
	exit 1
	;;
esac

PROOT_URL="${PROOT_URL}/${PROOT}"

${wget_command} -O ./proot-${PROOT_VERSION}.${ARCH} ${PROOT_URL}

chmod 0700 ./proot-${PROOT_VERSION}.${ARCH}

exit 0
