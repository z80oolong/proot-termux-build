#!/usr/bin/make -f
#
# Makefile
#
# Copyright (C) Z.OOL. <zool@zool.jpn.org> 2017
#
# This file is distriduted under the GNU Lesser General Public License v3.
# See LICENSE.md for more details.

# version or commit of talloc and proot

TALLOC_VERSION = 2.1.10
PROOT_COMMIT   = edc869d60c7f5b6abf67052a327ef099aded7777

# Architecture

ARCH = arm
#ARCH = x86-32
#ARCH = x86-64

# Utilities for build

TEST    = test
ECHO    = echo
ENV     = env
RM      = rm
CD      = cd
TAR     = tar
UNZIP   = unzip
WGET    = wget
MAKE    = make
PATCH   = patch
INSTALL = install

# Install path of talloc.{so,a}

BUILD_PREFIX = ${PWD}/opt

# talloc-cross-answer.txt

ANSTXT  = ./talloc-cross-answer.txt

# Target architecture

ifeq (${ARCH}, arm)
BUILD_HOST = arm-linux-gnueabihf
CFLAGS     = -mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS   = -mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS    = -L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib
endif

ifeq (${ARCH}, x86)
BUILD_HOST = x86_64-linux-gnu
CFLAGS     = -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS   = -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS    = -L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib
endif

MAKE_OPT = -j4

# Environment for cross compile

COMPILE_PREFIX = /usr/bin
CROSS_COMPILE  = ${COMPILE_PREFIX}/${BUILD_HOST}-

CC      = ${CROSS_COMPILE}gcc
CPP     = ${CROSS_COMPILE}cpp
AR      = ${CROSS_COMPILE}ar
RANLIB  = ${CROSS_COMPILE}ranlib
STRIP   = ${CROSS_COMPILE}strip
LD      = ${CROSS_COMPILE}ld
OBJCOPY = ${CROSS_COMPILE}objcopy
OBJDUMP = ${CROSS_COMPILE}objdump

# Build talloc

${ANSTXT}:
	${ECHO} 'Checking uname sysname type: "Linux"'                         >  ${ANSTXT}
	${ECHO} 'Checking uname machine type: "do not care"'                   >> ${ANSTXT}
	${ECHO} 'Checking uname release type: "do not care"'                   >> ${ANSTXT}
	${ECHO} 'Checking uname version type: "do not care"'                   >> ${ANSTXT}
	${ECHO} 'Checking simple C program: OK'                                >> ${ANSTXT}
	${ECHO} 'building library support: OK'                                 >> ${ANSTXT}
	${ECHO} 'Checking for large file support: OK'                          >> ${ANSTXT}
	${ECHO} 'Checking for -D_FILE_OFFSET_BITS=64: OK'                      >> ${ANSTXT}
	${ECHO} 'Checking for WORDS_BIGENDIAN: OK'                             >> ${ANSTXT}
	${ECHO} 'Checking for C99 vsnprintf: OK'                               >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_SECURE_MKSTEMP: OK'                         >> ${ANSTXT}
	${ECHO} 'rpath library support: OK'                                    >> ${ANSTXT}
	${ECHO} '-Wl,--version-script support: FAIL'                           >> ${ANSTXT}
	${ECHO} 'Checking correct behavior of strtoll: OK'                     >> ${ANSTXT}
	${ECHO} 'Checking correct behavior of strptime: OK'                    >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_IFACE_GETIFADDRS: OK'                       >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_IFACE_IFCONF: OK'                           >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_IFACE_IFREQ: OK'                            >> ${ANSTXT}
	${ECHO} 'Checking getconf LFS_CFLAGS: OK'                              >> ${ANSTXT}
	${ECHO} 'Checking for large file support without additional flags: OK' >> ${ANSTXT}
	${ECHO} 'Checking for working strptime: OK'                            >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_SHARED_MMAP: OK'                            >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_MREMAP: OK'                                 >> ${ANSTXT}
	${ECHO} 'Checking for HAVE_INCOHERENT_MMAP: OK'                        >> ${ANSTXT}
	${ECHO} 'Checking getconf large file support flags work: OK'           >> ${ANSTXT}

make_install_talloc:	${ANSTXT}
	${TEST} -e ./talloc-${TALLOC_VERSION}.tar.gz || ${WGET} https://download.samba.org/pub/talloc/talloc-${TALLOC_VERSION}.tar.gz
	${TEST} -d ./talloc-${TALLOC_VERSION} || ${TAR} -zxvf talloc-${TALLOC_VERSION}.tar.gz
	(${CD} ./talloc-${TALLOC_VERSION} && \
		CC=${CC} CPP=${CPP} AR=${AR} RANLIB=${RANLIB} STRIP=${STRIP} LD=${LD} OBJCOPY=${OBJCOPY} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
		./configure --prefix=${BUILD_PREFIX} --cross-compile --cross-answers=../${ANSTXT} --disable-python --without-gettext --disable-rpath)
	(${CD} ./talloc-${TALLOC_VERSION} && ${MAKE} ${MAKE_OPT} install V=1)
	(${CD} ./talloc-${TALLOC_VERSION}/bin/default && ${AR} rsuv ./libtalloc.a ./talloc_5.o ./lib/replace/replace_2.o ./lib/replace/cwrap_2.o ./lib/replace/closefrom_2.o)
	${INSTALL} -v -m 0644 ./talloc-${TALLOC_VERSION}/bin/default/libtalloc.a  ${BUILD_PREFIX}/lib

# Build PRoot

make_install_proot:	make_install_talloc
	${TEST} -e proot-${PROOT_COMMIT}.zip || ${WGET} -O proot-${PROOT_COMMIT}.zip https://github.com/termux/proot/archive/${PROOT_COMMIT}.zip
	${TEST} -d ./proot-${PROOT_COMMIT} || ${UNZIP} proot-${PROOT_COMMIT}.zip
	(${CD} ./proot-${PROOT_COMMIT}/src && \
		${ENV} LC_ALL=C ${MAKE} ${MAKE_OPT} -f ./GNUmakefile CROSS_COMPILE=${CROSS_COMPILE} CC=${CC} LD=${CC} STRIP=${STRIP} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} \
		  CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -I. ${CPPFLAGS}" CFLAGS="-Wall -Wextra -O2" LDFLAGS="${LDFLAGS} -static -ltalloc -Wl,-z,noexecstack" V=1)
	(${CD} ./proot-${PROOT_COMMIT}/src && ${STRIP} ./proot)
	${INSTALL} -v -m 0755 ./proot-${PROOT_COMMIT}/src/proot ./proot
	${INSTALL} -v -m 0755 ./proot-${PROOT_COMMIT}/src/proot ./proot.${ARCH}

# Build all and Clean all

all:	make_install_talloc make_install_proot

clean:
	${RM} -rf ./talloc-${TALLOC_VERSION} ./proot-${PROOT_COMMIT} ${BUILD_PREFIX} ${ANSTXT} ./proot

distclean: clean
	${RM} -rf talloc-${TALLOC_VERSION}.tar.gz proot-${PROOT_COMMIT}.zip
