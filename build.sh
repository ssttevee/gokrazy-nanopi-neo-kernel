cat <<EOF | time docker run --platform linux/arm -v "$PWD:/tmp/buildresult" -i alpine
set -ex


apk add alpine-sdk xz flex bison gmp-dev mpc1-dev mpfr-dev python3 py3-setuptools swig python3-dev openssl-dev gnutls-dev u-boot-tools

# this makes compile fail when on wrong arch
export ARCH=arm



# compile kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.8.tar.xz
tar xJf linux-6.14.8.tar.xz

make -C linux-6.14.8 -j$(nproc) sunxi_defconfig
make -C linux-6.14.8 -j$(nproc) mod2noconfig
cat <<CFG >> linux-6.14.8/.config
CONFIG_SQUASHFS=y
CONFIG_TUN=y
CONFIG_IPV6=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_IPV4=y
CONFIG_NF_TABLES_IPV6=y
CONFIG_NFT_NAT=y
CONFIG_NFT_MASQ=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_IPV4=y
CONFIG_NF_NAT_IPV6=y
CONFIG_NFT_CT=y
CONFIG_NFT_COUNTER=y
CONFIG_NFT_META=y
CFG
make -C linux-6.14.8 olddefconfig
make -C linux-6.14.8 -j$(nproc) zImage dtbs modules
make -C linux-6.14.8 modules_install INSTALL_MOD_PATH=/tmp/buildresult
cp linux-6.14.8/arch/arm/boot/dts/allwinner/sun8i-h3-nanopi-neo.dtb /tmp/buildresult/
cp linux-6.14.8/arch/arm/boot/zImage /tmp/buildresult/vmlinuz



# compile u-boot
wget https://ftp.denx.de/pub/u-boot/u-boot-2025.04.tar.bz2
tar xf u-boot-2025.04.tar.bz2

make -C u-boot-2025.04 nanopi_neo_defconfig
make -C u-boot-2025.04 -j$(nproc)
cp u-boot-2025.04/u-boot-sunxi-with-spl.bin /tmp/buildresult/



# compile u-boot boot script
mkimage -C none -A arm -T script -d /tmp/buildresult/boot.cmd /tmp/buildresult/boot.scr


EOF

