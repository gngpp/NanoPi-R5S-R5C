#!/bin/bash

OPENWRTROOT=$(pwd)
export OPENWRTROOT

pushd ../build/opkg
sed -i "s/subtarget/$SUBTARGET/g" distfeeds*.conf
sed -i "s/target\//$TARGET\//g" distfeeds*.conf
sed -i "s/platform/$PLATFORM/g" distfeeds*.conf
popd

mkdir -p files/etc/uci-defaults/
cp ../build/scripts/init-settings.sh files/etc/uci-defaults/99-init-settings

mkdir -p files/etc/opkg
cp ../build/opkg/distfeeds-packages-server.conf files/etc/opkg/distfeeds.conf.server

mkdir -p files/etc/opkg/keys
cp ../build/opkg/1035ac73cc4e59e3 files/etc/opkg/keys/1035ac73cc4e59e3

if [ -n "$KMODS_IN_FIRMWARE" ] && [ "$KMODS_IN_FIRMWARE" == "true" ]; then
    mkdir -p files/www/snapshots
    cp -r bin/targets files/www/snapshots
    cp ../build/opkg/distfeeds-18.06-local.conf files/etc/opkg/distfeeds.conf
else
    cp ../build//opkg/distfeeds-18.06-remote.conf files/etc/opkg/distfeeds.conf
fi

cp files/etc/opkg/distfeeds.conf.server files/etc/opkg/distfeeds.conf.mirror
sed -i "s/http:\/\/192.168.123.100:2345\/snapshots/https:\/\/openwrt.cc\/snapshots\/$(date +"%Y-%m-%d")\/lean/g" files/etc/opkg/distfeeds.conf.mirror

make package/install -j$(nproc) || make package/install -j1 V=s
make target/install -j$(nproc) || make target/install -j1 V=s

pushd bin/targets/rockchip/armv8
rm -rf openwrt-rockchip-armv8.manifest
rm -rf openwrt-rockchip-armv8-rootfs.tar.gz
rm -rf config.buildinfo
rm -rf packages-server.zip
mv openwrt-rockchip-armv8-friendlyarm_nanopi-$MODEL-ext4-sysupgrade.img.gz $VERSION-$MODEL-ext4-sysupgrade.img.gz
mv openwrt-rockchip-armv8-friendlyarm_nanopi-$MODEL-squashfs-sysupgrade.img.gz $VERSION-$MODEL-squashfs-sysupgrade.img.gz
popd
make checksum
mv bin/targets/rockchip/armv8/sha256sums bin/targets/rockchip/armv8/$VERSION-$MODEL-sha256sums
