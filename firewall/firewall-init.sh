#!/bin/sh
set -e

# --- 1. LIMPIEZA Y POLÍTICA ---
iptables -F
iptables -t nat -F
iptables -P FORWARD ACCEPT # Temporalmente ACCEPT para probar que el túnel funciona

# --- 2. CONFIGURACIÓN WIREGUARD ---
echo "Configurando WireGuard..."
mkdir -p /etc/wireguard
# Generamos llaves fijas para que no cambien en cada reinicio
SERVER_PRIV="yP9vW+y8O+Vq2H8Y8T6w0l4C1E3M9u7N+h3x1Z5A8E8="
USER1_PUB="tJ6mN+u8P+Wq3I9Z9U7x1m5D2F4N+v8O/i4y2A6B9F9="

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV

[Peer]
PublicKey = $USER1_PUB
AllowedIPs = 10.8.0.2/32
EOF

wg-quick up wg0

# --- 3. REGLA MÁGICA (NAT) ---
# Esto es lo que hacía que fallara el ping. Lo ponemos global.
iptables -t nat -A POSTROUTING -j MASQUERADE

echo "VPN y NAT Listos. Esperando tráfico..."
tail -f /dev/null