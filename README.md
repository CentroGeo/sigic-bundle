# sigic-bundle


git clone https://github.com/CentroGeo/sigic-bundle.git
git submodule update --init --recursive --remote
git submodule update --remote --merge --recursive


--env_type=prod default 

python3 create-envfile.py --email=info@cesarbenjamin.net --https / --externalhttps \
--hostname=geosuite.demo.cesarbenjamin.net  
--oidc_provider_url=https://geosuite.demo.cesarbenjamin.net/iam/realms/sigic
--useoidc --usefeadmin --usefeapp --useia --homepath=app




python3 create-envfile.py --externalhttps --email=info@cesarbenjamin.net --hostname=catalogoinfra.dev.geoint.mx --oidc_provider_url=https://catalogoinfra.dev.geoint.mx/iam/realms/sigic --useoidc --usellm --homepath=app 

todo:      COMPOSE_PROFILES=geonode,oidc,https,ia,ollama docker compose pull
ia remoto: COMPOSE_PROFILES=geonode,oidc,https docker compose pull

COMPOSE_PROFILES=frontend-admin,frontend-app docker compose build --no-cache
COMPOSE_PROFILES=geonode,oidc,frontend-admin,frontend-app docker compose up -d

docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm down 

docker compose build --no-cache --profile core    # postgres y nginx general (no el nginx del ia-lb)
docker compose build --no-cache --profile ia      # todo lo de ia

docker compose build --no-cache --profile ia-db     # solo la base de datos de ia sobre el postgres del bundle
docker compose build --no-cache --profile ia-lb      # solo el load balancer de ia (openresty con lua y redis)
docker compose build --no-cache --profile ia-engine  # solo el engine de ia

docker compose --profile ia up -d
docker compose --profile ia-db up -d
docker compose --profile ia-lb up -d
docker compose --profile ia-engine up -d

