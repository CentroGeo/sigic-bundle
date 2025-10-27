#!/bin/bash
set -e

echo "🔍 Comprobando si se debe crear la base de datos Keycloak..."

if [ "${ENABLE_KEYCLOAK_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_KEYCLOAK_PROXY=False, no se creará DB keycloak"
  exit 0
fi

until pg_isready -h 127.0.0.1 -U "$POSTGRES_USER" || pg_isready -h db -U "$POSTGRES_USER"; do
  echo "⏳ Esperando a que PostgreSQL esté disponible..."
  sleep 2
done

echo "✅ PostgreSQL disponible, verificando base de datos keycloak..."

psql -v ON_ERROR_STOP=1 -h db -U "$POSTGRES_USER" -d postgres <<-EOSQL
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
