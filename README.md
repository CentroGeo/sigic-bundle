# sigic-bundle


git clone https://github.com/CentroGeo/sigic-bundle.git
git submodule update --init --recursive --remote

python3 create-envfile.py --env_type=dev --email=info@cesarbenjamin.net --hostname=geosuite.demo.cesarbenjamin.net --https --enable_keycloak_proxy --oidc_provider_url=https://geosuite.demo.cesarbenjamin.net/iam