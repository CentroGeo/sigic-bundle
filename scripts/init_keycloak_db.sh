#!/bin/bash
set -e
if [ "${ENABLE_KEYCLOAK_PROXY}" != "True" ]; then
  echo "🟡 ENABLE_KEYCLOAK_PROXY=False, no se creará DB keycloak"
  exit 0
fi
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak') THEN
    CREATE DATABASE keycloak OWNER $POSTGRES_USER;
  END IF;
END
\$\$;
EOSQL
