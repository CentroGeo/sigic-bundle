#!/bin/bash
set -e

echo "🔍 Iniciando script para crear la base de datos keycloak..."

if [ "${ENABLE_KEYCLOAK_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_KEYCLOAK_PROXY=False, no se creará DB keycloak."
  exit 0
fi

until (echo > /dev/tcp/db/5432) >/dev/null 2>&1; do
  echo "⏳ Esperando a que PostgreSQL esté disponible..."
  sleep 2
done

echo "✅ PostgreSQL disponible, creando base si no existe..."

PGPASSWORD="$POSTGRES_PASSWORD" psql -h db -U postgres -d postgres <<'EOSQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak') THEN
    RAISE NOTICE 'Creando base de datos keycloak...';
    CREATE DATABASE keycloak OWNER postgres;
  ELSE
    RAISE NOTICE 'La base keycloak ya existe.';
  END IF;
END
$$;
EOSQL

echo "✅ Base de datos verificada/creada correctamente."
