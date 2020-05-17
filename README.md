# JPEG Quant Smooth

This program tries to recreate lost precision of DCT coefficients based on quantization table from jpeg image.
Output saved as jpeg image with quantization set to 1 (like jpeg saved with 100% quality). You can save smoothed image with original quantization tables resulting in same DCT coefficients as in original image.

You may not notice jpeg artifacts on the screen without zooming in, but you may notice them after printing. Also, when editing compressed images, artifacts can accumulate, but if you use this program before editing - the result will be better.

The original project page is [here](https://github.com/ilyakurdyukov/jpeg-quantsmooth).

## WebAssembly

Web version available [here](https://ilyakurdyukov.github.io/jpeg-quantsmooth/).
Images are processed locally on your computer.
Without multithreading and SIMD optimizations it runs slower than native code.

- Click the "Load" button or drag-n-drop JPEG image into the browser window. After processing is complete, you can save the result by clicking the "Save" button. You can edit the *filename* field before saving. The *options* field is passed to the *wasm* code when you initiate a processing by loading a file.

## Usage

`jpegqs [options] input.jpg output.jpg`

## Options

`-q, --quality n` Quality setting (0-6, default is 3)  
`-n, --niter n` Number of iterations (default is 3)  
`-t, --threads n` Set the number of CPU threads to use  
`-o, --optimize` Option for libjpeg to produce smaller output file  
`-v, --verbose n` Print libjpeg debug output  
`-i, --info n` Print quantsmooth debug output (default is 15)  
Use the sum of flags: 0 - silent, 1/2/4 - various information, 8 - processing time, 16 - SIMD type.
`-p, --cpu n` Use to lower the SIMD type if CPU detection fails:  
0 - auto, 1 - scalar, 2 - SSE2, 3 - AVX2, 4 - AVX512.
(`x86` build selects between modes 1-3, `x86_64` from 2-4)

- The processing time includes only the smoothing algorithm, jpeg reading and writing time is not included.
- More iterations can make the result look like CG art, can make the photos look unnatural.

The quality setting sets a combination of flags for processing:

3. default
4. adds `DIAGONALS` flag  
smoother diagonal edges, ~1.5 times slower
5. adds `JOINT_YUV` flag  
chroma channels will depend from luminance, better color consistency
6. adds `UPSAMPLE_UV` flag  
non-blurring chroma upsampling, unlike `fancy upsampling` from *libjpeg*

- levels 0-2 is the same as 4-6, but with `LOW_QUALITY` flag  
~10 times faster, but the quality is lower  
`LOW_QUALITY` implies `DIAGONALS` (always set)

## Examples

- Images 3x zoomed.

<p align="center"><b>
Original images:<br>
<img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/text_orig.png"> <img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/lena_orig.png"><br>
JPEG with quality increasing from 8% to 98%:<br>
<img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/text_jpg.png"> <img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/lena_jpg.png"><br>
After processing:<br>
<img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/text_new.png"> <img src="https://ilyakurdyukov.github.io/jpeg-quantsmooth/images/lena_new.png"><br>
</b></p>

## Buliding on Linux

If your system have *libjpeg* development package installed, just type `make`.
Tested with `libjpeg-turbo8-dev` package from Ubuntu-18.04.

### Building with libjpeg sources

1. Download and extract *libjpeg* sources:
    1. *libjpeg*, for example version 6b  
    `wget https://www.ijg.org/files/jpegsrc.v6b.tar.gz`  
    `tar -xzf jpegsrc.v6b.tar.gz`
    2. *libjpeg-turbo*, for example version 2.0.4  
    `wget -O libjpeg-turbo-2.0.4.tar.gz https://sourceforge.net/projects/libjpeg-turbo/files/2.0.4/libjpeg-turbo-2.0.4.tar.gz`  
    `tar -xzf libjpeg-turbo-2.0.4.tar.gz`

- For a *libjpeg* (not *turbo*) you can build `jpegqs` in a simpler way:  
`make JPEGSRC=jpeg-6b`  
This uses static configuration from `jconfig.h`, which should work for common systems.  
The following items are not needed if you do so.  

2. Configure and build *libjpeg*:
    1. For *libjpeg* and *libjpeg-turbo-1.x.x*:  
    `(cd jpeg-6b && ./configure && make all)`
    2. For *libjpeg-turbo-2.x.x* `./configure` script is replaced with `cmake`:  
    `(cd libjpeg-turbo-2.0.4 && mkdir -p .libs && (cd .libs && cmake -G"Unix Makefiles" .. && make all))`

3. Tell `make` where to find *libjpeg* includes and `libjpeg.a`  
`make JPEGLIB="-Ijpeg-6b jpeg-6b/libjpeg.a`  
For a newer versions `libjpeg.a` is located in a `.libs/` dir.

### libjpeg build helper

The `jpegqs` makefile can download sources, extract and compile `libjpeg` for you. Replace `%VER%` with a version.

- libjpeg: `make jpeg-%VER%/libjpeg.a`
Tested versions: 6b, 7, 8d, 9c
- libjpeg-turbo:`make libjpeg-turbo-%VER%/libjpeg.a`
Tested versions: 1.0.0, 1.4.2, 1.5.3, 2.0.4

It will print you link to archive which you need to download, or you can allow the downloads by adding `WGET_CMD=wget` to the `make` command line.

## Building on Windows

Get [MSYS2](https://www.msys2.org/), install needed packages with pacman and build with __release.sh__.
If you are not familiar with building unix applications on windows, then you can download program from [releases](https://github.com/ilyakurdyukov/jpeg-quantsmooth/releases).

## Alternatives and comparison

Similar projects, and how I see them after some testing.

[**jpeg2png**](https://github.com/victorvde/jpeg2png):  
&nbsp;✔️ good documentation and math model  
&nbsp;✔️ has tuning options  
&nbsp;✔️ better at deblocking low quality JPEG images  
&nbsp;❓ little blurry in default mode (compared to <b>quantsmooth</b>), but can be tuned  
&nbsp;➖ 10 to 20 times slower  
&nbsp;➖ less permissive license (GPL-3.0)  

**jpeg2png** can provide roughly same quality (better in not common cases), but significantly slower.

[**knusperli**](https://github.com/google/knusperli):  
&nbsp;✔️ more permissive license (Apache-2.0)  
&nbsp;➖ you can hardly see any improvements on the image  
&nbsp;➖ no performance optimizations (but roughly same speed as for <b>quantsmooth</b> with optimizations)  
&nbsp;➖ no any command line options  
&nbsp;➖ uncommon build system  

**knusperli** is good for nothing, in my opinion.
