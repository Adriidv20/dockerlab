#!/bin/sh
set -eu

ip route add 172.10.0.0/24 via 172.30.0.2 2>/dev/null || true
ip route add 172.20.0.0/24 via 172.30.0.2 2>/dev/null || true
ip route add 172.40.0.0/24 via 172.30.0.2 2>/dev/null || true

echo "prod_test listo"
ip route

tail -f /dev/null