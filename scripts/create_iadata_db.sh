#!/bin/bash
set -e

echo "🔍 Verificando base de datos IA (iadata)..."

if [ "${ENABLE_IA_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_IA_PROXY=False, no se creará la base."
  exit 0
fi

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASS="${POSTGRES_PASSWORD}"
IA_DB="${IA_DJANGO_DB_NAME:-iadata}"
IA_USER="${IA_DJANGO_DB_USER:-iauser}"
IA_PASS="${IA_DJANGO_DB_PASSWORD}"

# Esperar hasta que PostgreSQL responda
until (echo > /dev/tcp/$DB_HOST/$DB_PORT) >/dev/null 2>&1; do
  echo "⏳ Esperando a PostgreSQL (${DB_HOST}:${DB_PORT})..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando existencia de la base '${IA_DB}' y usuario '${IA_USER}'..."

EXISTS_DB=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${IA_DB}';")
EXISTS_USER=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='${IA_USER}';")

if [ "$EXISTS_USER" != "1" ]; then
  echo "🆕 Creando usuario '${IA_USER}'..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE USER ${IA_USER} WITH PASSWORD '${IA_PASS}';"
else
  echo "✅ Usuario '${IA_USER}' ya existe."
fi

if [ "$EXISTS_DB" != "1" ]; then
  echo "🆕 Creando base de datos '${IA_DB}' y asignando permisos..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE ${IA_DB} OWNER ${IA_USER};"
else
  echo "✅ Base de datos '${IA_DB}' ya existe."
fi

echo "🔧 Ajustando privilegios..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${IA_DB} TO ${IA_USER};"

echo "🧩 Verificando extensión 'vector' en la base '${IA_DB}'..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "${IA_DB}" -c "CREATE EXTENSION IF NOT EXISTS vector;"

echo "✅ Base de datos '${IA_DB}' y usuario '${IA_USER}' listos."
