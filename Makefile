#!/usr/bin/env make
TEST=test
RM=rm
CD=cd
TAR=tar
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

CFLAGS="-mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include"
LDFLAGS="-L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib"

make_install_talloc:
	${TEST} -e ./talloc-2.1.9.tar.gz || wget https://download.samba.org/pub/talloc/talloc-2.1.9.tar.gz
	${TEST} -e ./talloc-2.1.9 || ${TAR} -zxvf talloc-2.1.9.tar.gz
	${CD} ./talloc-2.1.9 && \
	./configure --prefix=${BUILD_PREFIX} --cross-compile --cross-answers=../talloc-cross-answer.txt --disable-python --without-gettext --disable-rpath && \
	${MAKE} install V=1 && \
	(${CD} bin/default; ${AR} rsv ./libtalloc.a ./talloc_5.o ./lib/replace/replace_2.o ./lib/replace/cwrap_2.o ./lib/replace/closefrom_2.o) && \
	${INSTALL} -v -m 0644 bin/default/libtalloc.a ${BUILD_PREFIX}/lib

make_install_proot:
	${TEST} -d ./proot-termux-git && (${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git)
	${CD} ./proot-termux-git && \
	(${GIT} checkout a01472c8 || ${GIT} checkout -b a01472c8 a01472c8) && \
	${PATCH} -p1 < ../proot-termux-git-fix.diff && \
	(${CD} ./src && ${MAKE} -f ./GNUmakefile V=1 && ${STRIP} ./proot) && \
	${PATCH} -p1 -R < ../proot-termux-git-fix.diff
	${INSTALL} -v -m 0755 ./proot-termux-git/src/proot .
	

git_submodule_clean_proot:
	(${GIT} submodule deinit -f ./proot-termux-git; ${GIT} ${RM} -rf ./proot-termux-git; ${RM} -rf ./proot-termux-git) || true

git_submodule_add_proot:
	${GIT} submodule add --force https://github.com/termux/proot.git ./proot-termux-git
	
git_clone_proot: git_submodule_add_proot
	${GIT} submodule init ./proot-termux-git; ${GIT} submodule update ./proot-termux-git

distclean:
	${RM} -rf ./proot ./opt ./talloc-2.1.9 && (cd ./proot-termux-git/src && ${MAKE} -f ./GNUmakefile distclean)

build:	make_install_talloc make_install_proot
