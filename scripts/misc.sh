#!/bin/bash

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

#setup custom setting for openwrt and immortalwrt
sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
echo "$BASE"
sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh

if [ "$TYPE" == "AMLOGIC" ]; then
    sed -i -E "s|nullwrt|$TYPE|g" files/etc/uci-defaults/99-init-settings.sh
fi

echo "All custom configuration setup completed!"
