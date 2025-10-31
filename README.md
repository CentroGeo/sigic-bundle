# sigic-bundle


git clone https://github.com/CentroGeo/sigic-bundle.git
git submodule update --init --recursive --remote
git submodule update --remote --merge --recursive


--env_type=prod default 

python3 create-envfile.py --email=info@cesarbenjamin.net --https / --externalhttps \
--hostname=geosuite.demo.cesarbenjamin.net  
--oidc_provider_url=https://geosuite.demo.cesarbenjamin.net/iam/realms/sigic
--useoidc --usefeadmin --usefeapp --usellm --homepath=app



python3 create-envfile.py --externalhttps --email=info@cesarbenjamin.net --hostname=catalogoinfra.dev.geoint.mx --oidc_provider_url=https://catalogoinfra.dev.geoint.mx/iam/realms/sigic --useoidc --usellm --homepath=app 

docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm down 

docker compose --profile oidc --profile llm --profile frontend-admin --profile frontend-pub build --no-cache
docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm up -d --remove-orphans