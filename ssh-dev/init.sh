#!/bin/bash

# Generamos el secreto 2FA solo la primera vez
if [ ! -f /home/john/.google_authenticator ]; then
    
    # Le inyectamos "-1" para que salte la validación inicial y guarde el archivo
    echo "-1" | su john -c "google-authenticator -t -d -f -r 3 -R 30 -w 3" > /tmp/ga_output 2>&1
    
    if [ -f /home/john/.google_authenticator ]; then
        # Extraer la clave secreta
        SECRET=$(head -n 1 /home/john/.google_authenticator)
        
        echo "========================================================="
        echo "  CONFIGURACIÓN DE SEGURIDAD 2FA LISTA"
        echo "  Usuario: john"
        echo "  Contraseña: password123"
        echo "  CLAVE SECRETA GOOGLE AUTHENTICATOR: $SECRET"
        echo "  Abre la app de Google Authenticator, elige 'Introducir"
        echo "  clave de configuración' y pega el código anterior."
        echo "========================================================="
    else
        echo "Hubo un error generando el código. Logs de error:"
        cat /tmp/ga_output
    fi
fi

# Arrancar SSH
exec /usr/sbin/sshd -D -e