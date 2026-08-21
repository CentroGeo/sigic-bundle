COMPOSE_PROJECT_NAME=${1:-sigic}
REALM=$(echo "${KEYCLOAK_ISSUER:-}" | sed 's|.*/realms/||' | sed 's|/.*||')
REALM=${REALM:-sigic}
KEYCLOAK_CONTAINER="keycloak4$COMPOSE_PROJECT"
POSTGRES_CONTAINER="db4$COMPOSE_PROJECT"
BACKEND_CONTAINER="django4$COMPOSE_PROJECT"
FRONTEND_CONTAINER="frontendadmin4$COMPOSE_PROJECT"
BACKUP_PATH="backup_$COMPOSE_PROJECT/"

mkdir -p $BACKUP_PATH/keycloak
mkdir -p $BACKUP_PATH/geonode

echo "Respaldando Keycloak realm e usuarios"
docker exec $KEYCLOAK_CONTAINER /opt/keycloak/bin/kc.sh export --dir /tmp/export --realm $REALM --users different_files
docker cp $KEYCLOAK_CONTAINER:/tmp/export $BACKUP_PATH/keycloak

echo "Respaldando geonode y geoserver"
docker exec -it $BACKEND_CONTAINER sh -c 'chmod +x ./sigic_geonode/br/backup.sh'
docker exec -it $BACKEND_CONTAINER sh -c 'chmod +x manage.sh'
docker exec -it $BACKEND_CONTAINER sh -c './sigic_geonode/br/backup.sh'
docker cp $BACKEND_CONTAINER:/backup_restore/ $BACKUP_PATH/geonode

echo "Respaldando paginas de landing builder"
docker stop $FRONTEND_CONTAINER
docker run --rm \
      -v "$COMPOSE_PROJECT-landing_builder_data":/backup-volume \
      busybox \
      tar -zcvf /backup-volume/$COMPOSE_PROJECT-landing_builder_data.tar.gz -C /backup-volume .

docker restart $FRONTEND_CONTAINER
docker cp $FRONTEND_CONTAINER:/app/.data/$COMPOSE_PROJECT-landing_builder_data.tar.gz $BACKUP_PATH/
