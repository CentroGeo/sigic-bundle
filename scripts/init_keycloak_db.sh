#!/bin/bash
set -e

echo "🔍 Comprobando si se debe crear la base de datos Keycloak..."

if [ "${ENABLE_KEYCLOAK_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_KEYCLOAK_PROXY=False, no se creará DB keycloak"
  exit 0
fi

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"

# Esperar disponibilidad del socket TCP
until (echo > /dev/tcp/$DB_HOST/$DB_PORT) >/dev/null 2>&1; do
  echo "⏳ Esperando a que PostgreSQL esté disponible en ${DB_HOST}:${DB_PORT}..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando base de datos keycloak..."

# Ejecutar SQL para crear base si no existe
# Requiere tener el cliente psql dentro del contenedor (tu imagen de GeoNode lo trae)
psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -U "$POSTGRES_USER" -d postgres <<-EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak') THEN
    RAISE NOTICE 'Creando base de datos keycloak...';
    CREATE DATABASE keycloak OWNER $POSTGRES_USER;
  ELSE
    RAISE NOTICE 'Base de datos keycloak ya existe, omitiendo creación.';
  END IF;
END
\$\$;
EOSQL

echo "✅ Verificación finalizada."
