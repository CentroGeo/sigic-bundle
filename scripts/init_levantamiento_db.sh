#!/bin/bash
set -e

echo "🔍 Verificando base de datos Levantamiento..."
if [ "${ENABLE_LEVANTAMIENTO_DB}" != "True" ]; then
  echo "🟡 ENABLE_LEVANTAMIENTO_DB=False, no se creará la base."
  exit 0
fi

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASS="${POSTGRES_PASSWORD}"
LEVANTAMIENTO_DB_NAME="${LEVANTAMIENTO_LEVANTAMIENTO_DB_NAME:-levantamientodata}"
LEVANTAMIENTO_DB_USER="${LEVANTAMIENTO_DB_USER:-levantamientouser}"
LEVANTAMIENTO_DB_PASSWORD="${LEVANTAMIENTO_DB_PASSWORD}"

# Esperar hasta que PostgreSQL responda
until (echo > /dev/tcp/$DB_HOST/$DB_PORT) >/dev/null 2>&1; do
  echo "⏳ Esperando a PostgreSQL (${DB_HOST}:${DB_PORT})..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando existencia de la base '${LEVANTAMIENTO_DB_NAME}' y usuario '${LEVANTAMIENTO_DB_USER}'..."

EXISTS_DB=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${LEVANTAMIENTO_DB_NAME}';")
EXISTS_USER=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='${LEVANTAMIENTO_DB_USER}';")

if [ "$EXISTS_USER" != "1" ]; then
  echo "🆕 Creando usuario '${LEVANTAMIENTO_DB_USER}'..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE USER ${LEVANTAMIENTO_DB_USER} WITH PASSWORD '${LEVANTAMIENTO_DB_PASSWORD}';"
else
  echo "🔁 Usuario '${LEVANTAMIENTO_DB_USER}' ya existe, actualizando contraseña..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "ALTER USER ${LEVANTAMIENTO_DB_USER} WITH PASSWORD '${LEVANTAMIENTO_DB_PASSWORD}';"
fi

if [ "$EXISTS_DB" != "1" ]; then
  echo "🆕 Creando base de datos '${LEVANTAMIENTO_DB_NAME}' y asignando permisos..."
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE ${LEVANTAMIENTO_DB_NAME} OWNER ${LEVANTAMIENTO_DB_USER};"
else
  echo "✅ Base de datos '${LEVANTAMIENTO_DB_NAME}' ya existe."
fi

echo "🔧 Ajustando privilegios..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${LEVANTAMIENTO_DB_NAME} TO ${LEVANTAMIENTO_DB_USER};"

echo "🧩 Verificando extensión 'postgis' en la base '${LEVANTAMIENTO_DB_NAME}'..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "${LEVANTAMIENTO_DB_NAME}" -c "CREATE EXTENSION IF NOT EXISTS postgis;"

echo "✅ Base de datos '${LEVANTAMIENTO_DB_NAME}' y usuario '${LEVANTAMIENTO_DB_USER}' listos."
