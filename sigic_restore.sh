#!/bin/bash
set -e

COMPOSE_PROJECT=${1:-sigic}
PREV_COMPOSE_PROJECT=${2:-$COMPOSE_PROJECT}
[ "$COMPOSE_PROJECT" = "sigic" ] && ENVFILE=".env" || ENVFILE=".env.$COMPOSE_PROJECT"
KEYCLOAK_CONTAINER="keycloak4$COMPOSE_PROJECT"
POSTGRES_CONTAINER="db4$COMPOSE_PROJECT"
BACKEND_CONTAINER="django4$COMPOSE_PROJECT"
FRONTEND_CONTAINER="frontendadmin4$COMPOSE_PROJECT"
BACKUP_PATH="backup_$COMPOSE_PROJECT"

if [ "$PREV_COMPOSE_PROJECT" != "$COMPOSE_PROJECT" ]; then
    echo "Se requiere migrar el respaldo al nuevo proyecto"
    echo "$PREV_COMPOSE_PROJECT -> $COMPOSE_PROJECT"
    cp -r "backup_$PREV_COMPOSE_PROJECT/" $BACKUP_PATH
    mv "$BACKUP_PATH/$PREV_COMPOSE_PROJECT-landing_builder_data.tar.gz" "$BACKUP_PATH/$COMPOSE_PROJECT-landing_builder_data.tar.gz"
    for config in $BACKUP_PATH/keycloak/export/$PREV_COMPOSE_PROJECT*; do mv "$config" $(echo "$config" | sed "s/$PREV_COMPOSE_PROJECT/$COMPOSE_PROJECT/g"); done
    find $BACKUP_PATH -type f -exec sed -i "s|$PREV_COMPOSE_PROJECT|$COMPOSE_PROJECT|g" {} +
    echo "Archivos migrados"
fi

SOURCE_URL=$(cat "$BACKUP_PATH/backup_metadata" | grep -E '^(STATIC_URL)=')
TARGET_URL=$(cat "$ENVFILE" | grep -E '^(STATIC_URL)=')
if [ "$SOURCE_URL" != "$TARGET_URL" ]; then
    echo "Se detectó target url diferente al backup metadata url"
    echo "$SOURCE_URL -> $TARGET_URL"
fi

echo "Restaurando Keycloak realm e usuarios"
docker cp $BACKUP_PATH/keycloak/export/ $KEYCLOAK_CONTAINER:/tmp/export
docker exec -it $KEYCLOAK_CONTAINER sh -c "find /tmp/export -type f -exec sed -i 's|$SOURCE_URL|$TARGET_URL|g' {} +"
docker exec $KEYCLOAK_CONTAINER /opt/keycloak/bin/kc.sh import --dir /tmp/export
docker restart $KEYCLOAK_CONTAINER

echo "Restaurando geonode y geoserver"
docker cp $BACKUP_PATH/geonode/backup_restore/ $BACKEND_CONTAINER:/
docker exec -it $BACKEND_CONTAINER sh -c 'chmod +x ./sigic_geonode/br/backup.sh'
docker exec -it $BACKEND_CONTAINER sh -c 'chmod +x ./sigic_geonode/br/restore.sh'
docker exec -it $BACKEND_CONTAINER sh -c 'chmod +x manage.sh'
docker exec -it $BACKEND_CONTAINER sh -c "SOURCE_URL=$SOURCE_URL TARGET_URL=$TARGET_URL ./sigic_geonode/br/restore.sh"

echo "Restaurando landing builder"
docker cp $BACKUP_PATH/$COMPOSE_PROJECT-landing_builder_data.tar.gz $FRONTEND_CONTAINER:/app/.data/
docker exec -it $FRONTEND_CONTAINER sh -c "tar -xvf /app/.data/$COMPOSE_PROJECT-landing_builder_data.tar.gz -C /app/.data"

