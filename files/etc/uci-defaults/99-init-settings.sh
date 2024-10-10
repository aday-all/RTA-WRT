#!/bin/sh

TYPEOPENWRT="nullwrt"

if [ "$TYPEOPENWRT" == "amlogic" ]; then
chmod +x /bin/getcpu
chmod +x /etc/custom_service/start_service.sh
rm -rf /etc/profile.d/30-sysinfo.sh
chmod +x /sbin/firstboot
chmod +x /sbin/kmod
chmod +x /usr/bin/7z
chmod +x /usr/bin/cpustat
chmod +x /usr/sbin/openwrt-install-allwinner
chmod +x /usr/sbin/openwrt-openvfd
chmod +x /usr/sbin/openwrt-swap
chmod +x /usr/sbin/openwrt-tf
fi

exec > /root/setup.log 2>&1

# dont remove!
echo "Installed Time: $(date '+%A, %d %B %Y %T')"
echo "###############################################"
echo "Processor: $(ubus call system board | grep '\"system\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
echo "Device Model: $(ubus call system board | grep '\"model\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
echo "Device Board: $(ubus call system board | grep '\"board_name\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
sed -i "s#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' / ':'')+(luciversion||''),#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' build by OpenWrt [Ouc3kNF6]':''),#g" /www/luci-static/resources/view/status/include/10_system.js
sed -i "s/\(DISTRIB_DESCRIPTION='OpenWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
echo Branch version: "$(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
echo "Tunnel Installed: $(opkg list-installed | grep -e luci-app-openclash -e luci-app-passwall | awk '{print $1}' | tr '\n' ' ')"
echo "###############################################"

# Set login root password
(echo "root"; sleep 1; echo "root") | passwd > /dev/null

# Set hostname and Timezone to Asia/Jakarta
echo "Setup NTP Server and Time Zone to Asia/Jakarta"
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci -q delete system.ntp.server
uci add_list system.ntp.server="pool.ntp.org"
uci add_list system.ntp.server="id.pool.ntp.org"
uci add_list system.ntp.server="time.google.com"
uci commit system

echo "Setup WAN and LAN Interface"
# Configure Network
uci set network.lan.ipaddr="192.168.1.1"
uci del network.lan.ip6assign
uci set network.tethering=interface
uci set network.tethering.proto='dhcp'
uci set network.tethering.device='usb0'
uci del network.wan6
uci commit network

# configure Firewall
uci set firewall.@zone[1].network='tethering'
uci commit firewall

# configure DHCP
uci del dhcp.@dnsmasq[0].nonwildcard
uci del dhcp.@dnsmasq[0].noresolv
uci del dhcp.@dnsmasq[0].boguspriv
uci del dhcp.@dnsmasq[0].filterwin2k
uci del dhcp.@dnsmasq[0].filter_aaaa
uci del dhcp.@dnsmasq[0].filter_a
uci del dhcp.@dnsmasq[0].nonegcache
uci add_list dhcp.@dnsmasq[0].server='.8.8.8.8'
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.ndp
uci -q delete dhcp.lan.ra_slaac
uci -q delete dhcp.lan.ra_flags
uci commit dhcp
/etc/init.d/dnsmasq restart

# custom repo and Disable opkg signature check
echo "Setup custom Repo By kiddin9"
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz custom_arch https://dl.openwrt.ai/latest/packages/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')/kiddin9" >> /etc/opkg/customfeeds.conf

# set material as default theme
echo "Setup Default Theme"
uci set luci.main.mediaurlbase='/luci-static/material' && uci commit

echo "Setup misc settings"
# remove login password required when accessing terminal
uci set ttyd.@ttyd[0].command='/bin/bash --login'
uci commit

# remove huawei me909s usb-modeswitch
sed -i -e '/12d1:15c1/,+5d' /etc/usb-mode.json

# remove dw5821e usb-modeswitch
sed -i -e '/413c:81d7/,+5d' /etc/usb-mode.json

# Disable /etc/config/xmm-modem
uci set xmm-modem.@xmm-modem[0].enable='0'
uci commit

# setup auto vnstat database backup
sed -i 's/;DatabaseDir "\/var\/lib\/vnstat"/DatabaseDir "\/etc\/vnstat"/' /etc/vnstat.conf
mkdir -p /etc/vnstat
chmod +x /etc/init.d/vnstat_backup
bash /etc/init.d/vnstat_backup enable

# setup misc settings
chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh
chmod +x /sbin/free.sh
chmod +x /usr/bin/openclash.sh
chmod +x /usr/bin/speedtest

# configurating openclash
if opkg list-installed | grep luci-app-openclash > /dev/null; then
  echo "Openclash Detected!"
  echo "Configuring Core..."
  chmod +x /etc/openclash/core/clash
  chmod +x /etc/openclash/core/clash_tun
  chmod +x /etc/openclash/core/clash_meta
  chmod +x /usr/bin/patchoc.sh
  echo "Patching Openclash Overview"
  bash /usr/bin/patchoc.sh
  sed -i '/exit 0/i #/usr/bin/patchoc.sh' /etc/rc.local
  ln -s /etc/openclash/history/config-wrt.db /etc/openclash/cache.db
  ln -s /etc/openclash/core/clash_meta  /etc/openclash/clash
  echo "YACD and Core setup complete!"
else
  echo "No Openclash Detected."
  uci delete internet-detector.Openclash
  uci commit internet-detector
  service internet-detector restart
fi

if opkg list-installed | grep luci-app-passwall > /dev/null; then
  echo "Passwall Detected!"
else
  sed -i '/<a href="\/cgi-bin\/luci\/admin\/services\/passwall">/d' /usr/share/ucode/luci/template/themes/material/header.ut
fi

# Setting php8
sed -i -E "s|memory_limit = [0-9]+M|memory_limit = 100M|g" /etc/php.ini
uci set uhttpd.main.index_page='index.php'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci commit uhttpd

ln -s /usr/bin/php-cli /usr/bin/php

# Setting Tinyfm
ln -s / /www/tinyfm/rootfs

echo "All first boot setup complete!"
exit 0
