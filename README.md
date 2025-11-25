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

docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile ia down 

docker compose --profile oidc --profile ia --profile frontend-admin --profile frontend-pub build --no-cache
docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile ia up -d --remove-orphans



python3 create-envfile.py --email=info@cesarbenjamin.net \          # o el email del administrador, para ia no es relevante este dato
--https / --externalhttps \                                         # solo uno de los dos o ninguno, para usar http no usar ninguno, si se va apublicar detras de un proxy externo con https usar --externalhttps
--hostname=geosuite.demo.cesarbenjamin.net \                        # el hostname publico del despliegue
--oidc_provider_url=https://iam.dev.geoint.mx/iam/realms/sigic  \   # la url del proveedor oidc y su realm
--useia                                                             # para habilitar el componente de inteligencia artificial 



docker compose build --no-cache --profile core    # postgres y nginx general (no el nginx del ia-lb)
docker compose build --no-cache --profile ia      # todo lo de ia

docker compose build --no-cache --profile ia-db     # solo la base de datos de ia sobre el postgres del bundle
docker compose build --no-cache --profile ia-lb      # solo el load balancer de ia (openresty con lua y redis)
docker compose build --no-cache --profile ia-engine  # solo el engine de ia

docker compose --profile ia up -d
docker compose --profile ia-db up -d
docker compose --profile ia-lb up -d
docker compose --profile ia-engine up -d

