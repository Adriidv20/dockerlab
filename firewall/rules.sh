# 1. Limpiamos reglas anteriores
iptables -F
iptables -t nat -F

# 2. POLÍTICA POR DEFECTO (Prohibir todo)
iptables -P FORWARD DROP

# 3. PERMITIR TRÁFICO DE RETORNO (Vital para que funcionen las respuestas)
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# PERMITIR CONSULTAS DNS DESDE CUALQUIER RED HACIA EL SERVIDOR DNS
iptables -A FORWARD -d 172.20.0.10 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -d 172.20.0.10 -p tcp --dport 53 -j ACCEPT
# 4. EXCEPCIÓN: BACKUPS BBDD (Las flechas verdes de tu imagen)
# Dejar que el NAS (172.20.0.30) consulte Postgres en Producción (puerto 5432)
iptables -A FORWARD -s 172.20.0.30 -d 172.30.0.0/24 -p tcp --dport 5432 -j ACCEPT
# Dejar que el NAS consulte MySQL en Desarrollo (puerto 3306)
iptables -A FORWARD -s 172.20.0.30 -d 172.40.0.0/24 -p tcp --dport 3306 -j ACCEPT

# 5. PERMITIR REGLA GENERAL: Services <-> Development
iptables -A FORWARD -s 172.20.0.0/24 -d 172.40.0.0/24 -j ACCEPT
iptables -A FORWARD -s 172.40.0.0/24 -d 172.20.0.0/24 -j ACCEPT

# 6. ENMASCARAMIENTO (NAT)
iptables -t nat -A POSTROUTING -j MASQUERADE