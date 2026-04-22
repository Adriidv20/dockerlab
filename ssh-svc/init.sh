#!/bin/sh

if [ -f "/tmp/id_rsa.pub" ]; then
    # Limpiamos posibles retornos de carro de Windows (\r) al copiar la clave
    tr -d '\r' < /tmp/id_rsa.pub > /home/john/.ssh/authorized_keys
    
    # Aplicamos todos los permisos exactos que exige SSH para dejarte pasar
    chown -R john:john /home/john/.ssh
    chmod 755 /home/john
    chmod 700 /home/john/.ssh
    chmod 600 /home/john/.ssh/authorized_keys
fi

# Arrancamos el servidor SSH
exec /usr/sbin/sshd -D -e