#!/bin/bash
set -e

echo "🔍 Verificando base de datos IA (iadata)..."

if [ "${ENABLE_IA_DB}" != "True" ]; then
  echo "🟡 ENABLE_IA_DB=False, no se creará la base."
  exit 0
fi

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_PASS="${DB_PASSWORD}"
DB_NAME="${DB_NAME:-iadata}"
IA_USER="${IA_USER:-iauser}"
IA_PASSWORD="${IA_PASSWORD}"

# Esperar hasta que PostgreSQL responda
until (echo > /dev/tcp/$DB_HOST/$DB_PORT) >/dev/null 2>&1; do
  echo "⏳ Esperando a PostgreSQL (${DB_HOST}:${DB_PORT})..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando existencia de la base '${DB_NAME}' y usuario '${IA_USER}'..."

EXISTS_DB=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}';")
EXISTS_USER=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='${IA_USER}';")

if [ "$EXISTS_USER" != "1" ]; then
  echo "🆕 Creando usuario '${IA_USER}'..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE USER ${IA_USER} WITH PASSWORD '${IA_PASSWORD}';"
else
  echo "🔁 Usuario '${IA_USER}' ya existe, actualizando contraseña..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "ALTER USER ${IA_USER} WITH PASSWORD '${IA_PASSWORD}';"
fi

if [ "$EXISTS_DB" != "1" ]; then
  echo "🆕 Creando base de datos '${DB_NAME}' y asignando permisos..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE ${DB_NAME} OWNER ${IA_USER};"
else
  echo "✅ Base de datos '${DB_NAME}' ya existe."
fi

echo "🔧 Ajustando privilegios..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${IA_USER};"

echo "🧩 Verificando extensión 'vector' en la base '${DB_NAME}'..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "${DB_NAME}" -c "CREATE EXTENSION IF NOT EXISTS vector;"

echo "✅ Base de datos '${DB_NAME}' y usuario '${IA_USER}' listos."
