#!/usr/bin/make -f
#
# Makefile
#
# Copyright (C) Z.OOL. <zool@zool.jpn.org> 2017
#
# This file is distriduted under the GNU Lesser General Public License v3.
# See LICENSE.md for more details.

# Utilities for build

TEST=test
ENV=env
RM=rm
CD=cd
TAR=tar
WGET=wget
GIT=git
MAKE=make
PATCH=patch
INSTALL=install

# Install path of talloc.{so,a}

BUILD_PREFIX=${PWD}/opt

# Target architecture

BUILD_HOST=arm-linux-gnueabihf
#BUILD_HOST=x86_64-linux-gnu

# Environment for cross compile

CROSS_COMPILE=/usr/bin/${BUILD_HOST}-

CC=${CROSS_COMPILE}gcc
CPP=${CROSS_COMPILE}cpp
AR=${CROSS_COMPILE}ar
RANLIB=${CROSS_COMPILE}ranlib
STRIP=${CROSS_COMPILE}strip
LD=${CROSS_COMPILE}ld
OBJCOPY=${CROSS_COMPILE}objcopy
OBJDUMP=${CROSS_COMPILE}objdump

ifeq (${BUILD_HOST},arm-linux-gnueabihf)
CFLAGS=-mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS=-mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
else
CFLAGS=-I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS=-I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
endif
LDFLAGS=-L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib

# Build talloc 2.1.9

make_install_talloc:
	${TEST} -e ./talloc-2.1.9.tar.gz || ${WGET} https://download.samba.org/pub/talloc/talloc-2.1.9.tar.gz
	${TEST} -d ./talloc-2.1.9 || ${TAR} -zxvf talloc-2.1.9.tar.gz
	${CD} ./talloc-2.1.9 && \
		CC=${CC} CPP=${CPP} AR=${AR} RANLIB=${RANLIB} STRIP=${STRIP} LD=${LD} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} \
		./configure --prefix=${BUILD_PREFIX} --cross-compile --cross-answers=../talloc-cross-answer.txt --disable-python --without-gettext --disable-rpath && \
		${MAKE} install V=1 && \
		(${CD} bin/default; ${AR} rsuv ./libtalloc.a ./talloc_5.o ./lib/replace/replace_2.o ./lib/replace/cwrap_2.o ./lib/replace/closefrom_2.o) && \
		${INSTALL} -v -m 0644 bin/default/libtalloc.a ${BUILD_PREFIX}/lib

# Build PRoot commit a01472c8

make_install_proot:
	${TEST} -d ./proot-termux-git && (${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git)
	${CD} ./proot-termux-git && \
		${GIT} checkout -q a01472c82ad5357c5abc9f463889256dd935941d && \
		(${CD} ./src && \
			${ENV} LC_ALL=C ${MAKE} -f ./GNUmakefile CROSS_COMPILE=${CROSS_COMPILE} \
			CC=${CC} LD=${CC} STRIP=${STRIP} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} \
			CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -I. ${CPPFLAGS}" \
			CFLAGS="-Wall -Wextra -O2" LDFLAGS="${LDFLAGS} -static -ltalloc -Wl,-z,noexecstack" V=1 && \
			${STRIP} ./proot)
	${INSTALL} -v -m 0755 ./proot-termux-git/src/proot .
	
# Git clone PRoot repository

git_submodule_clean_proot:
	(cd ./proot-termux-git/src && ${MAKE} -f ./GNUmakefile distclean)
	(${GIT} submodule deinit -f ./proot-termux-git; ${GIT} ${RM} -rf ./proot-termux-git; ${RM} -rf ./proot-termux-git) || true

git_submodule_add_proot:
	${GIT} submodule add --force https://github.com/termux/proot.git ./proot-termux-git || true
	
git_clone_proot: git_submodule_clean_proot git_submodule_add_proot
	${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git

# Build all and Clean all

build:	make_install_talloc make_install_proot

distclean: git_clone_proot
	${RM} -rf ./proot ./opt ./talloc-2.1.9
