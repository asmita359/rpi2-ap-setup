#!/bin/bash
#
# This version uses September 2017 august stretch image, please use this image
#
# This is the script modified by Ishan, to match his needs.

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

apt-get remove --purge hostapd
apt-get update
apt-get upgrade
apt-get install hostapd dnsmasq


#specyfying dhcp range of the interface wlan0

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=192.168.70.2,192.168.70.50,255.255.255.0,12h
EOF


# editing hostapd file with necessary config

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=Password123
ssid=EvilS-AP
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
EOF


#sed is used to delete 'allow-hotplug wlan0', 'iface wlan0 inet manual' and 
" 'wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' lines from /etc/network/interfaces

sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces#

# replace #DAEMON_CONF line to specify our hostapd config

sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd


# adding required static ip to wlan0


cat >> /etc/network/interfaces <<EOF
# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
	address 192.168.70.1
	netmask 255.255.255.0
	network 192.168.70.0
	broadcast 192.168.70.255

EOF

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf   #disallow raspberry pi to automatically get ip for wlan0

systemctl enable hostapd
systemctl enable dnsmasq

sudo service hostapd start
sudo service dnsmasq start

echo "All done! Please reboot"