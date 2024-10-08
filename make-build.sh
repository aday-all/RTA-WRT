#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Modem and UsbLAN Driver
PACKAGES+=" wget kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
modemmanager modemmanager-rpcd luci-proto-modemmanager libmbim libqmi usbutils luci-proto-mbim luci-proto-ncm \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem \
kmod-phy-broadcom kmod-phylib-broadcom kmod-tg3"
PACKAGES+=" acpid attr base-files bash bc blkid block-mount blockd bsdtar busybox bzip2 \
cgi-io chattr comgt comgt-ncm containerd coremark coreutils coreutils-base64 coreutils-nohup \
coreutils-truncate curl dosfstools dumpe2fs e2freefrag e2fsprogs \
exfat-mkfs f2fs-tools f2fsck fdisk gawk getopt git gzip hostapd-common iconv iw iwinfo jq \
jshn kmod-brcmfmac kmod-brcmutil libjson-script liblucihttp \
liblucihttp-lua losetup lsattr lsblk lscpu mkf2fs openssl-util parted \
perl-http-date perlbase-file perlbase-getopt perlbase-time perlbase-unicode perlbase-utf8 \
pigz ppp ppp-mod-pppoe proto-bonding pv rename resize2fs runc tar tini ttyd tune2fs \
uclient-fetch uhttpd uhttpd-mod-ubus unzip uqmi usb-modeswitch uuidgen wget-ssl whereis \
which wwan xfs-fsck xfs-mkfs xz xz-utils ziptool zoneinfo-asia zoneinfo-core zstd \
luci luci-base luci-compat luci-lib-base \
luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio luci-mod-admin-full luci-mod-network \
luci-mod-status luci-mod-system luci-proto-bonding \
luci-proto-ppp lolcat coreutils-stty"

# Tunnel option
OPENCLASH="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
MIHOMO+="mihomo luci-app-mihomo"

PACKAGES+=" $OPENCLASH $MIHOMO"

# NAS and Hard disk tools
PACKAGES+=" kmod-usb-storage kmod-usb-storage-uas ntfs-3g"

# Bandwidth And Network Monitoring
PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart vnstat2 vnstati2 luci-app-vnstat2 iperf3"

# Material Theme
PACKAGES+=" luci-theme-material"

# PHP8
PACKAGES+=" libc php8 php8-fastcgi php8-fpm coreutils-stat zoneinfo-asia php8-cgi \
php8-cli php8-mod-bcmath php8-mod-calendar php8-mod-ctype php8-mod-curl php8-mod-dom php8-mod-exif \
php8-mod-fileinfo php8-mod-filter php8-mod-gd php8-mod-iconv php8-mod-intl php8-mod-mbstring php8-mod-mysqli \
php8-mod-mysqlnd php8-mod-opcache php8-mod-pdo php8-mod-pdo-mysql php8-mod-phar php8-mod-session \
php8-mod-xml php8-mod-xmlreader php8-mod-xmlwriter php8-mod-zip"

# Misc and some custom .ipk files
misc+=" luci-app-temp-status"

if [ "$TYPE" == "AMLOGIC" ]; then
    PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
    EXCLUDED+=" -procd-ujail"
fi

PACKAGES+=" $misc zram-swap adb luci-ssl luci-app-ramfree htop unrar luci-app-ttyd nano httping screen openssh-sftp-server"

# Exclude package (must use - before packages name)
EXCLUDED+=" -dnsmasq -libgd"

# Custom Files
FILES="files"

# Disable service
# DISABLED_SERVICES=""

# Start build firmware
make image PROFILE="$1" PACKAGES="$PACKAGES $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES"
