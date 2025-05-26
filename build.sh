cat <<EOF | docker run --platform linux/arm -v .:/tmp/buildresult --rm -it alpine

apk add alpine-sdk xz flex bison gmp-dev mpc1-dev mpfr-dev python3 py3-setuptools swig python3-dev openssl-dev gnutls-dev u-boot-tools

# this makes compile fail when on wrong arch
export ARCH=arm



# compile kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.8.tar.xz
tar xJf linux-6.14.8.tar.xz

make -C linux-6.14.8 -j$(nproc) sunxi_defconfig
make -C linux-6.14.8 -j$(nproc) mod2noconfig
echo "CONFIG_SQUASHFS=y" >> linux-6.14.8/.config
echo "CONFIG_TUN=y" >> linux-6.14.8/.config
make -C linux-6.14.8 olddefconfig
make -C linux-6.14.8 -j$(nproc) zImage dtbs modules
make -C linux-6.14.8 modules_install INSTALL_MOD_PATH=/tmp/buildresult
cp linux-6.14.8/arch/arm/boot/dts/allwinner/sun8i-h3-nanopi-neo.dtb linux-6.14.8/arch/arm/boot/zImage /tmp/buildresult/vmlinuz



# compile u-boot
git clone https://source.denx.de/u-boot/u-boot.git --branch v2025.04 --depth 1 --single-branch

make -C u-boot nanopi_neo_defconfig
make -C u-boot -j$(nproc) u-boot-sunxi-with-spl.bin
cp u-boot/u-boot-sunxi-with-spl.bin /tmp/buildresult/



# compile u-boot boot script
mkimage -C none -A arm -T script -d /tmp/buildresult/boot.cmd /tmp/buildresult/boot.scr


EOF

