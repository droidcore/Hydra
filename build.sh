#!/bin/bash
#
# abyss oneplus2 build script
#
clear

# Resources
THREAD="-j4"
KERNEL="Image.gz-dtb"
DEFCONFIG="cm_oneplus2_defconfig"
DEVICE="oneplus2"

# Kernel Details
VARIANT=$(date +"%Y%m%d")
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=${HOME}/toolchains/aarch64-linux-android-4.9-kernel-linaro/bin/aarch64-linux-android-

# Paths
KERNEL_DIR="${HOME}/kernel/oneplus2"
ANYKERNEL_DIR="${HOME}/kernel/anykernel2"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE_NIGHTLY="${HOME}/kernel/out/$DEVICE/nightly"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"
KERNEL_VER=$( grep -r "EXTRAVERSION = -Abyss-" ${KERNEL_DIR}/Makefile | sed 's/EXTRAVERSION = -Abyss-//' )

# Functions
function clean_all {
		echo
		rm -rf $ANYKERNEL_DIR/$KERNEL
		rm -rf $MODULES_DIR/*
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
}

function make_zip {
		cp -vr $ZIMAGE_DIR/$KERNEL $ANYKERNEL_DIR/$KERNEL
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		cd $ANYKERNEL_DIR
		zip -r9 abyss-kernel-$DEVICE-$KERNEL_VER.zip *
		mv abyss-kernel-$DEVICE-$KERNEL_VER.zip $ZIP_MOVE_NIGHTLY
		cd $KERNEL_DIR
}

echo "    ___    __                                            ";
echo "   /   |  / /_  __  ____________                         ";
echo "  / /| | / __ \/ / / / ___/ ___/                         ";
echo " / ___ |/ /_/ / /_/ (__  |__  )                          ";
echo "/_/  |_/_.___/\__, /____/____/_ __                     __";
echo "             /____/         / //_/__  _________  ___  / /";
echo "                           / ,< / _ \/ ___/ __ \/ _ \/ / ";
echo "                          / /| /  __/ /  / / / /  __/ /  ";
echo "                         /_/ |_\___/_/  /_/ /_/\___/_/   ";
echo "                                                         ";

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		DATE_START=$(date +"%s")
		make_kernel
		if [ -f $ZIMAGE_DIR/$KERNEL ];
		then
			make_zip
		else
			echo
			echo "Kernel build failed."
			echo
		fi
		break
		;;
	n|N )
		DATE_START=$(date +"%s")
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
