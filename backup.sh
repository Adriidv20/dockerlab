#!/bin/sh

# Configuración
DB_HOST="172.20.0.20"
DB_USER="user_prod"
DB_NAME="prod_db"
BACKUP_DIR="/backups"
FECHA=$(date +%Y%m%d_%H%M%S)

echo "--- Iniciando copia de seguridad ($FECHA) ---"

# Ejecutar el volcado de la base de datos
# PGPASSWORD permite pasar la contraseña sin que el script se detenga a pedirla
PGPASSWORD='password123' pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $BACKUP_DIR/db_backup_$FECHA.sql

if [ $? -eq 0 ]; then
    echo "Copia completada con éxito: db_backup_$FECHA.sql"
else
    echo "ERROR: Falló la copia de seguridad"
fi