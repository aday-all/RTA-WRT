#!/bin/bash

# OpenClash
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"

# Mihomo
mihomo_api="https://api.github.com/repos/rtaserver/OpenWrt-mihomo-Mod/releases"
mihomo_file="mihomo_${ARCH_3}"
mihomo_file_down="$(curl -s ${mihomo_api} | grep "browser_download_url" | grep -oE "https.*${mihomo_file}.*.tar.gz" | head -n 1)"
                       
# Output download information
echo "Installing OpenClash, Mihomo"
echo "Downloading OpenClash package"
wget ${openclash_file_down} -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download OpenClash package."
    exit 1
fi

# Unzip Passwall packages
echo "Downloading Mihomo package"
wget "${mihomo_file_down}" -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download Mihomo package."
    exit 1
fi

# Extract Mihomo package
tar -xzvf packages/"mihomo_${ARCH_3}.tar.gz" -C packages && rm packages/"mihomo_${ARCH_3}.tar.gz"
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to extract Mihomo package."
    exit 1
fi

echo "Download and extraction complete."