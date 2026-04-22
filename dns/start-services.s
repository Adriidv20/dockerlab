#!/bin/sh

# 1. Arrancamos BIND9 (DNS) en segundo plano
named -u root -c /etc/bind/named.conf

# 2. Arrancamos dnsmasq (DHCP) en primer plano para mantener vivo el contenedor
dnsmasq -d