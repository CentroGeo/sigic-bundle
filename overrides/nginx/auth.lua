local oidc = require("resty.openidc")

local oidc_config_url = os.getenv("SOCIALACCOUNT_OIDC_ID_TOKEN_ISSUER")

if not oidc_config_url then
    ngx.log(ngx.ERR, "No se encontró la variable de entorno OIDC_CONFIG_URL")
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
else
    ngx.log(ngx.NOTICE, "OIDC_CONFIG_URL = ", oidc_config_url)
end

-- Si la URL no termina en /.well-known/openid-configuration, la concatenamos
if not oidc_config_url:match("%.well%-known/openid%-configuration$") then
    -- eliminar barra final si existe, para evitar doble slash
    oidc_config_url = oidc_config_url:gsub("/$", "")
    oidc_config_url = oidc_config_url .. "/.well-known/openid-configuration"
end

local opts = {
    discovery = oidc_config_url,
    ssl_verify = "yes",
    cafile = "/etc/ssl/certs/ca-certificates.crt",
    timeout = 10000
}

local res, err = oidc.bearer_jwt_verify(opts)

if err then
    ngx.status = 401
    ngx.say('{"error": "Authentication failed: ' .. (err or "unknown") .. '"}')
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end