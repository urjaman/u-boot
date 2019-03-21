#!/bin/sh
set -e
FLSZ=4194304
ENVFILE=env.bin
if [ -e $ENVFILE ]; then
	ENVSZ=$(stat --printf='%s' $ENVFILE)
else
	ENVSZ=0
fi
./tools/mkimage -n rk3288 -T rkspi -d spl/u-boot-spl.bin spl-in.bin
dd if=spl-in.bin of=spl-out.bin bs=64K conv=sync
dd if=/dev/zero bs=64K count=1 | tr '\0' '\377' > ff64k.bin
cat spl-out.bin ff64k.bin u-boot.img > rk-spi-in.bin
SZ=$(stat --printf='%s' rk-spi-in.bin)
PADSZ=$(expr $FLSZ - $SZ - $ENVSZ)
dd if=/dev/zero count=1 bs=$PADSZ | tr '\0' '\377' > ffpad.bin
if [ -e $ENVFILE ]; then
	cat rk-spi-in.bin ffpad.bin env.bin > rk-spi-out.bin
else
	cat rk-spi-in.bin ffpad.bin > rk-spi-out.bin
fi
rm spl-out.bin rk-spi-in.bin ff64k.bin ffpad.bin
