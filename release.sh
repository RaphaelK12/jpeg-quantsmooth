#!/bin/sh
jpeg=${1:-"jpeg-6b"}
bits=${2:-""}

lib="-ljpeg -static"
[ -d $jpeg ] && lib="-DWITH_JPEGSRC -I$jpeg $jpeg/libjpeg.a -static"

# test -d winlib$bits && lib="$lib -Lwinlib$bits"
omp="libgomp.a"
test "$omp" && test -d winlib$bits && omp="winlib$bits/$omp"

test -f ldscript$bits.txt && link="-Wl,-T,ldscript$bits.txt" || link=

# make JPEGLIB="$lib" SIMD=avx2 MFLAGS="-municode" APPNAME="jpegqs${bits}_avx2" clean app
# make JPEGLIB="$lib" SIMD=sse2 MFLAGS="-municode" APPNAME="jpegqs${bits}_sse2" clean app
# make JPEGLIB="$lib" SIMD=none MFLAGS="-O3 -municode" APPNAME="jpegqs${bits}_none" clean app

rm -f "winlib$bits/libgomp.a"
make LIBMINIOMP="$omp" JPEGLIB="$lib" SIMD=select MFLAGS="-municode -fno-asynchronous-unwind-tables" APPNAME="jpegqs${bits}" LFLAGS="$link" clean all

