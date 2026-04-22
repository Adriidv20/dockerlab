#!/bin/sh
# Iniciar el DHCP en segundo plano
dnsmasq -C /etc/dnsmasq.conf

# Iniciar el DNS (BIND9) en primer plano usando la configuración de la imagen oficial
named -g -c /etc/bind/named.conf -u bind