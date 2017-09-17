#!/usr/bin/make -f
#
# Makefile
#
# Copyright (C) Z.OOL. <zool@zool.jpn.org> 2017
#
# This file is distriduted under the GNU Lesser General Public License v3.
# See doc/COPYING.md for more details.

# version or commit of talloc and proot

TALLOC_VERSION = 2.1.10
PROOT_COMMIT   = edc869d60c7f5b6abf67052a327ef099aded7777
#PROOT_COMMIT   = 6671bfed4ddcbd393d8ca7b2754d58e41ed9595b

# Architecture

ARCH = arm
#ARCH = x86

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

# proot-termux-fix.diff

PROOT_TERMUX_FIX_DIFF = ./proot-termux-fix.diff

# Target architecture

ifeq (${ARCH}, arm)
BUILD_HOST              = arm-linux-gnueabihf
CFLAGS                  = -mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS                = -mthumb -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS                 = -L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib
HAS_LOADER_32BIT_DEFINE = 
endif

ifeq (${ARCH}, x86-32)
BUILD_HOST              = x86_64-linux-gnu
CFLAGS                  = -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS                = -m32 -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS                 = -m32 -L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib
HAS_LOADER_32BIT_DEFINE = X86_32BIT=1
endif

ifeq (${ARCH}, x86-64)
BUILD_HOST              = x86_64-linux-gnu
CFLAGS                  = -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
CPPFLAGS                = -I${BUILD_PREFIX}/include -I/usr/${BUILD_HOST}/include
LDFLAGS                 = -L${BUILD_PREFIX}/lib -L/usr/${BUILD_HOST}/lib
HAS_LOADER_32BIT_DEFINE = HAS_LOADER_32BIT=1
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

all:	${PROOT_TERMUX_FIX_DIFF} ${ANSTXT} make_install_talloc make_install_proot

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

${PROOT_TERMUX_FIX_DIFF}:
	${ECHO} 'diff --git a/src/GNUmakefile b/src/GNUmakefile'			>  ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} 'index b74b3a3..468c000 100644' 							>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '--- a/src/GNUmakefile'										>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+++ b/src/GNUmakefile'										>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '@@ -63,8 +63,13 @@ endef'									>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' '															>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' $$(eval $$(call define_from_arch.h,,HAS_LOADER_32BIT))'	>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' '											>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+ifdef X86_32BIT'							>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+  HAS_LOADER_32BIT ='						>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+  LOADER_FLAGS_X86_32 = -m32'				>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+endif'									>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' ifdef HAS_LOADER_32BIT'					>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '   OBJECTS += loader/loader-m32-wrapped.o' >> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+  LOADER_FLAGS_X86_32 ='					>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' endif'									>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' '											>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' .DEFAULT_GOAL = proot'					>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '@@ -163,8 +168,8 @@ LOADER$$1_OBJECTS = loader/loader$$1.o loader/assembly$$1.o'	>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' $$(eval $$(call define_from_arch.h,$$1,LOADER_ARCH_CFLAGS))'	>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' $$(eval $$(call define_from_arch.h,$$1,LOADER_ADDRESS))'		>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' '																>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '-LOADER_CFLAGS$$1  += -fPIC -ffreestanding $$(LOADER_ARCH_CFLAGS$$1)'										>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '-LOADER_LDFLAGS$$1 += -static -nostdlib -Wl$$(BUILD_ID_NONE),-Ttext=$$(LOADER_ADDRESS$$1),-z,noexecstack' 	>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+LOADER_CFLAGS$$1  += $$(LOADER_FLAGS_X86_32) -fPIC -ffreestanding $$(LOADER_ARCH_CFLAGS$$1)'				>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} '+LOADER_LDFLAGS$$1 += $$(LOADER_FLAGS_X86_32) -static -nostdlib -Wl$$(BUILD_ID_NONE),-Ttext=$$(LOADER_ADDRESS$$1),-z,noexecstack'	>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' '											>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' loader/loader$$1.o: loader/loader.c'		>> ${PROOT_TERMUX_FIX_DIFF}
	${ECHO} ' 	@mkdir -p $$$$(dir $$$$@)'				>> ${PROOT_TERMUX_FIX_DIFF}

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
	${TEST} -d ./proot-${PROOT_COMMIT} || (${UNZIP} proot-${PROOT_COMMIT}.zip && ${CD} ./proot-${PROOT_COMMIT} && ${PATCH} -p1 < ../${PROOT_TERMUX_FIX_DIFF})
	(${CD} ./proot-${PROOT_COMMIT}/src && \
		${ENV} LC_ALL=C ${MAKE} ${MAKE_OPT} -f ./GNUmakefile ${HAS_LOADER_32BIT_DEFINE} LOADER_ARCH_CFLAGS="" CROSS_COMPILE=${CROSS_COMPILE} CC=${CC} LD=${CC} STRIP=${STRIP} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} \
		  CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -I. ${CPPFLAGS}" CFLAGS="-Wall -Wextra -O2" LDFLAGS="${LDFLAGS} -static -ltalloc -Wl,-z,noexecstack" V=1)
	(${CD} ./proot-${PROOT_COMMIT}/src && ${STRIP} ./proot)
	${INSTALL} -v -m 0755 ./proot-${PROOT_COMMIT}/src/proot ./proot.${ARCH}

# Build all and Clean all

clean:
	${RM} -rf ./talloc-${TALLOC_VERSION} ./proot-${PROOT_COMMIT} ${BUILD_PREFIX} ${PROOT_TERMUX_FIX_DIFF} ${ANSTXT}

distclean: clean
	${RM} -rf talloc-${TALLOC_VERSION}.tar.gz proot-${PROOT_COMMIT}.zip
