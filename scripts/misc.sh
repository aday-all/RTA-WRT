#!/bin/bash

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

#setup custom setting for openwrt and immortalwrt
sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
echo "$BASE"
sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh

if [ "$TYPE" == "AMLOGIC" ]; then
    sed -i -E "s|nullwrt|$TYPE|g" files/etc/uci-defaults/99-init-settings.sh
    rm -rf files/lib
    rm -rf files/etc/config/amlogic
    rm -rf files/etc/config/fstab
    rm -rf files/etc/custom_service
    rm -rf files/etc/profile.d
    rm -rf files/etc/banner
    rm -rf files/etc/fstab
    rm -rf files/etc/model_database.conf
    rm -rf files/lib/firmware
    rm -rf files/sbin/firstboot
    rm -rf files/sbin/kmod
    rm -rf files/usr/bin/7z
    rm -rf files/usr/sbin
fi

echo "All custom configuration setup completed!"
