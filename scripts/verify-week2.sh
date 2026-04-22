#!/bin/sh

echo "--- INICIANDO VERIFICACIÓN SEMANA 2 ---"

# 1. Comprobar si las redes existen
echo ""
echo "[1] Verificando redes Docker:"

for net in vpn_net services_net production_net development_net; do
    if docker network ls | grep -q "$net"; then
        echo "  - Red $net: OK"
    else
        echo "  - Red $net: NO ENCONTRADA"
    fi
done

# 2. Comprobar que el Firewall tiene IP Forwarding habilitado
echo ""
echo "[2] Verificando configuración del Firewall:"
if docker exec firewall cat /proc/sys/net/ipv4/ip_forward | grep -q "1"; then
    echo "  - IP Forwarding: OK"
else
    echo "  - IP Forwarding: DESACTIVADO"
fi

# 3. Prueba de conectividad básica (Ping al Firewall desde VPN)
echo ""
echo "[3] Probando conectividad con el nodo central (Firewall):"
if docker exec vpn_test ping -c 1 172.10.0.2 > /dev/null 2>&1; then
    echo "  - Conexión VPN -> Firewall: EXITOSA"
else
    echo "  - Conexión VPN -> Firewall: FALLIDA"
fi

echo ""
echo "--- FIN DE LA VERIFICACIÓN ---"