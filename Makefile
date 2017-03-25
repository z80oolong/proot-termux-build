#!/usr/bin/make -f

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

BUILD_PREFIX=${PWD}/opt
#BUILD_HOST=x86_64-linux-gnu
BUILD_HOST=arm-linux-gnueabihf

CROSS_COMPILE=/usr/bin/${BUILD_HOST}-

CC=${CROSS_COMPILE}gcc
CPP=${CROSS_COMPILE}cpp
AR=${CROSS_COMPILE}ar
RANLIB=${CROSS_COMPILE}ranlib
STRIP=${CROSS_COMPILE}strip
LD=${CROSS_COMPILE}ld
OBJCOPY=${CROSS_COMPILE}objcopy
OBJDUMP=${CROSS_COMPILE}objdump

CFLAGS=-mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS=-mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS=-L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib

make_install_talloc:
	${TEST} -e ./talloc-2.1.9.tar.gz || ${WGET} https://download.samba.org/pub/talloc/talloc-2.1.9.tar.gz
	${TEST} -d ./talloc-2.1.9 || ${TAR} -zxvf talloc-2.1.9.tar.gz
	${CD} ./talloc-2.1.9 && \
		./configure --prefix=${BUILD_PREFIX} --cross-compile --cross-answers=../talloc-cross-answer.txt --disable-python --without-gettext --disable-rpath && \
		${MAKE} install V=1 && \
		(${CD} bin/default; ${AR} rsv ./libtalloc.a ./talloc_5.o ./lib/replace/replace_2.o ./lib/replace/cwrap_2.o ./lib/replace/closefrom_2.o) && \
		${INSTALL} -v -m 0644 bin/default/libtalloc.a ${BUILD_PREFIX}/lib

make_install_proot:
	${TEST} -d ./proot-termux-git && (${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git)
	${CD} ./proot-termux-git && \
		${GIT} checkout -q a01472c82ad5357c5abc9f463889256dd935941d && \
		(${CD} ./src && \
			${ENV} LC_ALL=C ${MAKE} -f ./GNUmakefile CROSS_COMPILE=${CROSS_COMPILE} \
			CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -I. ${CPPFLAGS}" \
			CFLAGS="-Wall -Wextra -O2" LDFLAGS="${LDFLAGS} -static -ltalloc -Wl,-z,noexecstack" V=1 && \
			${STRIP} ./proot)
	${INSTALL} -v -m 0755 ./proot-termux-git/src/proot .
	

git_submodule_clean_proot:
	(${GIT} submodule deinit -f ./proot-termux-git; ${GIT} ${RM} -rf ./proot-termux-git; ${RM} -rf ./proot-termux-git) || true

git_submodule_add_proot:
	${GIT} submodule add --force https://github.com/termux/proot.git ./proot-termux-git || true
	
git_clone_proot: git_submodule_clean_proot git_submodule_add_proot
	${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git

distclean:
	${RM} -rf ./proot ./opt ./talloc-2.1.9 && (cd ./proot-termux-git/src && ${MAKE} -f ./GNUmakefile distclean)

build:	make_install_talloc make_install_proot
