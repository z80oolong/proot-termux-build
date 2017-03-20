#!/bin/bash
export BUILD_PREFIX=${PWD}/opt
export BUILD_HOST=arm-linux-gnueabihf
export CROSS_COMPILE=/usr/bin/${BUILD_HOST}-

export CC=${CROSS_COMPILE}gcc
export CPP=${CROSS_COMPILE}cpp
export AR=${CROSS_COMPILE}ar
export RANLIB=${CROSS_COMPILE}ranlib
export LD=${CROSS_COMPILE}ld
export CFLAGS="-mthumb -I/usr/${BUILD_HOST}/include"
export LDFLAGS="-L/usr/${BUILD_HOST}/lib"

wget https://download.samba.org/pub/talloc/talloc-2.1.9.tar.gz
tar -zxvf talloc-2.1.9.tar.gz

cd ./talloc-2.1.9

./configure --prefix=${BUILD_PREFIX} --cross-compile --cross-answers=../talloc-cross-answer.txt --disable-python --without-gettext --disable-rpath
make install V=1
(cd bin/default; ${AR} rsv ./libtalloc.a ./talloc_5.o ./lib/replace/replace_2.o ./lib/replace/cwrap_2.o ./lib/replace/closefrom_2.o)
install -v -m 0644 bin/default/libtalloc.a ${BUILD_PREFIX}/lib

cd ..

git clone https://github.com/termux/proot.git ./proot-termux-git

cd ./proot-termux-git

patch -p1 < ../proot-termux-git-fix.diff

cd src

make -f ./GNUmakefile V=1
arm-linux-gnueabihf-strip ./proot

cd ../..

install -v -m 0755 ./proot-termux-git/src/proot .
