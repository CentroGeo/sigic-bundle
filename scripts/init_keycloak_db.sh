#!/bin/bash
set -e

echo "🔍 Verificando base de datos Keycloak..."

if [ "${ENABLE_OIDC_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_OIDC_PROXY=False, no se creará la base."
  exit 0
fi

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${POSTGRES_USER:-postgres}"

# Esperar hasta que PostgreSQL responda
until (echo > /dev/tcp/$DB_HOST/$DB_PORT) >/dev/null 2>&1; do
  echo "⏳ Esperando a PostgreSQL (${DB_HOST}:${DB_PORT})..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando existencia de la base keycloak..."

EXISTS=$(PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='keycloak';")

if [ "$EXISTS" != "1" ]; then
  echo "🆕 Creando base de datos 'keycloak'..."
  PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE keycloak OWNER $DB_USER;"
else
  echo "✅ Base de datos 'keycloak' ya existe, omitiendo creación."
fi

echo "✅ Finalizado correctamente."
