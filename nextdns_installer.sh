#!/bin/bash
NEXTDNS_CONFIG=your_nextdns_config_id_here
NEXTDNS_DISCOVERY=your_routers_ip_here
NEXTDNS_LISTEN=your_host_ip_here:53
TZ=your_timezone_here

sudo timedatectl set-timezone $TZ
sudo timedatectl set-ntp true

wget -qO - https://nextdns.io/repo.gpg | sudo apt-key add -
echo "deb https://nextdns.io/repo/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list

sudo apt-get update && sudo apt-get dist-upgrade -yqq
sudo apt-get install nextdns -yqq

# systemd-resolved conflicts with nextdns so we disable it
sudo systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved

sudo nextdns install \
    -config $NEXTDNS_CONFIG \
    -discovery-dns $NEXTDNS_DISCOVERY \
    -listen $NEXTDNS_LISTEN \
    -report-client-info \
    -setup-router \

# set the hostname and write /etc/hosts so ubuntu doesn't complain about not finding the local host name
sudo hostnamectl set-hostname ubuntu
echo -e "127.0.0.1 localhost\n127.0.1.1 ubuntu.local ubuntu\n# The following lines are desirable for IPv6 capable hosts\n::1 localhost ip6-localhost ip6-loopback\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" | sudo tee /etc/hosts