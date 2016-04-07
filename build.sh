#
#Custom build script for Vortex kernel
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#
Start=$(date +"%s")
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'
KERNEL_DIR=$PWD
zimage=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM
toolchain ()
{
clear
echo -e " "
echo -e "$gre Welcome to Vortex build system$white"
echo -e "Setting up host and user"
export KBUILD_BUILD_USER="C-Aniruddh"
export KBUILD_BUILD_HOST="Crux"
echo -e " "
echo -e "$yellow Select which toolchain you want to build with?$white"
echo -e "$yellow 1.UBERTC AARCH64$white"
echo -e "$yellow 2.SABERMOD AARCH64"
echo -e "$yellow 3.GOOGLE AARCH64"
echo -n " Enter your choice:"
read choice
case $choice in
1) export CROSS_COMPILE="/home/aniruddh/toolchain/aarch64-linux-ubertc-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/aniruddh/toolchain/aarch64-linux-ubertc-android-4.9/lib/
   STRIP="/home/aniruddh/toolchain/aarch64-linux-ubertc-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected UBERTC$white" ;;
2) export CROSS_COMPILE="/home/aniruddh/toolchain/aarch64-linux-sabermod-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/aniruddh/toolchain/aarch64-linux-sabermod-android-4.9/lib/
   STRIP="/home/aniruddh/toolchain/aarch64-linux-sabermod-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected SABERMOD$white" ;;
3) export CROSS_COMPILE="/home/aniruddh/toolchain/aarch64-linux-google-android-4.9/bin/aarch64-linux-android-"
   export LD_LIBRARY_PATH=home/aniruddh/toolchain/aarch64-linux-google-android-4.9/lib/
   STRIP="/home/aniruddh/toolchain/aarch64-linux-google-android-4.9/bin/aarch64-linux-android-strip"
   echo -e "$gre You selected GOOGLE$white" ;;
*) toolchain ;;
esac
}
toolchain
export ARCH=arm64
export SUBARCH=arm64
device ()
{
echo -e " "
echo -e "$yellow Select which device you want to build for?$white"
echo -e "$yellow 1.tomato$white"
echo -e "$yellow 2.lettuce"
echo -n " Enter your choice:"
read ch
case $ch in
1) echo -e "$gre You selected tomato$white"
   make clean
   make cyanogenmod_tomato-64_defconfig ;;
2) echo -e "$gre You selected lettuce$white"
   make clean
   make cyanogenmod_lettuce-64_defconfig ;;
*) device ;;
esac
}
device
make -j32
make Image -j32
make dtbs -j32
make modules -j32
mkdir ~/vortex_out
mkdir ~/vortex_out/tools
mkdir ~/vortex_final
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
mv arch/arm64/boot/dt.img ~/vortex_out/tools
cp drivers/staging/prima/wlan.ko ~/vortex_out/system/lib/modules/
cp fs/nls/nls_utf8.ko ~/vortex_out/system/lib/modules/
cp arch/arm64/boot/Image ~/vortex_out/tools/zImage
cd ~/vortex_out/
cd system/lib/modules/
$STRIP --strip-unneeded *.ko
cd ~/vortex_out/
case $choice in
1) zip -r Vortex-1.0-uc-lettuce.zip * ;;
2) zip -r Vortex-1.0-sm-lettuce.zip * ;;
3) zip -r Vortex-1.0-gc-lettuce.zip * ;;
*) echo -e "error" ;;
esac
mv *.zip ~/vortex_final/
cd ~/vortex/
End=$(date +"%s")
Diff=$(($End - $Start))
if ! [ -a $zimage ];
then
echo -e "$red<<Failed to compile zImage, fix the errors first>>$white"
else
echo -e "$gre<<Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds>>$white"
fi
