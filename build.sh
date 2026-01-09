#!/bin/bash

GCC_VERSION=14.2.0
GLIBC_VERSION=2.41
BINUTILS_VERSION=2.44
GDB_VERSION=10.2

LANGUAGES=c,c++,fortran

FOLDER_VERSION=64
KERNEL=kernel8
ARCH=armv8-a+fp+simd
TARGET=aarch64-linux-gnu

BUILDDIR=/tmp
DOWNLOADDIR=$BUILDDIR/build_toolchains
INSTALLDIR=$BUILDDIR/cross-pi-gcc-$GCC_VERSION-$FOLDER_VERSION
SYSROOTDIR=$BUILDDIR/cross-pi-gcc-$GCC_VERSION-$FOLDER_VERSION/$TARGET/libc

mkdir -p $DOWNLOADDIR
mkdir -p $INSTALLDIR

cd $DOWNLOADDIR

if [ ! -d "linux" ]; then
	git clone --depth=1 https://github.com/raspberrypi/linux
fi

if [ ! -d "gcc-$GCC_VERSION" ]; then
	wget -q https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

	tar xf gcc-$GCC_VERSION.tar.gz
	rm -f gcc-$GCC_VERSION.tar.gz

	mkdir -p gcc-$GCC_VERSION/build

	cd gcc-$GCC_VERSION
	sed -i 's/#include <limits.h>/#include <linux\/limits.h>/' libsanitizer/asan/asan_linux.cpp # patch

	contrib/download_prerequisites
	rm -f *.tar.*
	cd $DOWNLOADDIR
fi

if [ ! -d "binutils-$BINUTILS_VERSION" ]; then
	wget -q https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.bz2

	tar xf binutils-$BINUTILS_VERSION.tar.bz2
  rm -rf binutils-$BINUTILS_VERSION.tar.bz2

  mkdir -p binutils-$BINUTILS_VERSION/build
fi

if [ ! -d "glibc-$GLIBC_VERSION" ]; then
	wget -q https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.bz2

	tar xf glibc-$GLIBC_VERSION.tar.bz2
	rm -rf glibc-$GLIBC_VERSION.tar.bz2

	mkdir -p glibc-$GLIBC_VERSION/build
fi

if [ ! -d "gdb-$GDB_VERSION" ]; then
	wget -q https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.xz

	tar xf gdb-$GDB_VERSION.tar.xz
	rm -rf gdb-$GDB_VERSION.tar.xz

	mkdir -p gdb-$GDB_VERSION/build
fi

PATH=$BUILDDIR/cross-pi-gcc-$GCC_VERSION-$FOLDER_VERSION/bin:$PATH

echo "Building Kernel Headers ..."
cd $DOWNLOADDIR/linux
make -s ARCH=arm64 INSTALL_HDR_PATH=$SYSROOTDIR/usr headers_install
mkdir -p $SYSROOTDIR/usr/lib

echo "Building Binutils ..."
rm -rf $DOWNLOADDIR/binutils-$BINUTILS_VERSION/build/*
cd $DOWNLOADDIR/binutils-$BINUTILS_VERSION/build

../configure --target=$TARGET --prefix= --with-arch=$ARCH --with-sysroot=/$TARGET/libc --with-build-sysroot=$SYSROOTDIR --disable-multilib
make -s -j$(nproc)
make -s install-strip DESTDIR=$INSTALLDIR

echo "Building GCC and glibc ..."
rm -rf $DOWNLOADDIR/gcc-$GCC_VERSION/build/*
cd $DOWNLOADDIR/gcc-$GCC_VERSION/build

../configure --prefix= --target=$TARGET --enable-languages=$LANGUAGES --with-sysroot=/$TARGET/libc --with-build-sysroot=$SYSROOTDIR --with-arch=$ARCH --disable-multilib
make -s -j$(nproc) all-gcc
make -s install-strip-gcc DESTDIR=$INSTALLDIR

rm -rf $DOWNLOADDIR/glibc-$GLIBC_VERSION/build/*
cd $DOWNLOADDIR/glibc-$GLIBC_VERSION/build

../configure --prefix=/usr --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-arch=$ARCH --with-sysroot=/$TARGET/libc --with-build-sysroot=$SYSROOTDIR --with-headers=$SYSROOTDIR/usr/include --with-lib=$SYSROOTDIR/usr/lib --disable-multilib libc_cv_forced_unwind=yes
make -s install-bootstrap-headers=yes install-headers DESTDIR=$SYSROOTDIR
make -s -j$(nproc) csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o $SYSROOTDIR/usr/lib
$TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $SYSROOTDIR/usr/lib/libc.so
touch $SYSROOTDIR/usr/include/gnu/stubs.h $SYSROOTDIR/usr/include/bits/stdio_lim.h

cd $DOWNLOADDIR/gcc-$GCC_VERSION/build
make -s -j$(nproc) all-target-libgcc
make -s install-target-libgcc DESTDIR=$INSTALLDIR

cd $DOWNLOADDIR/glibc-$GLIBC_VERSION/build
make -s -j$(nproc)
make -s install DESTDIR=$SYSROOTDIR

cd $DOWNLOADDIR/gcc-$GCC_VERSION/build
make -s -j$(nproc)
make -s install-strip DESTDIR=$INSTALLDIR

cd $DOWNLOADDIR"/gcc-"$GCC_VERSION
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >$(dirname $($TARGET-gcc -print-libgcc-file-name))/include-fixed/limits.h

echo "Building GDB ..."
rm -rf $DOWNLOADDIR/gdb-$GDB_VERSION/build/*
cd $DOWNLOADDIR/gdb-$GDB_VERSION/build

../configure --prefix= --target=$TARGET --with-arch=$ARCH --with-float=hard
make -s -j$(nproc)
make -s install DESTDIR=$INSTALLDIR

echo "Creating TAR archive ..."
cd $BUILDDIR
tar czf cross-gcc-$GCC_VERSION-pi_$FOLDER_VERSION.tar.gz cross-pi-gcc-$GCC_VERSION-$FOLDER_VERSION
mkdir -p /app/build
mv cross-gcc-$GCC_VERSION-pi_$FOLDER_VERSION.tar.gz /app/build
