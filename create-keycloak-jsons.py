# -*- coding: utf-8 -*-
import json
import os
import re
import sys


def parse_env(path):
    env = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


def build_replacements(env):
    return {
        "nginxbaseurl": env["NGINX_BASE_URL"],

        "kcadm_cid": env["ADMIN_KEYCLOAK_CLIENT_ID"],
        "kcadm_secret": env["ADMIN_KEYCLOAK_CLIENT_SECRET"],

        "kcapp_cid": env["APP_KEYCLOAK_CLIENT_ID"],
        "kcapp_secret": env["APP_KEYCLOAK_CLIENT_SECRET"],

        "kcgn_cid": env["SOCIALACCOUNT_OIDC_CLIENT_ID"],
        "kcgn_secret": env["SOCIALACCOUNT_OIDC_CLIENT_SECRET"],
    }


def render(content, values):
    for k, v in values.items():
        content = re.sub(r"\{" + re.escape(k) + r"\}", v, content)
    return content


def process_file(path, values):
    with open(path) as f:
        content = f.read()

    rendered = render(content, values)

    # validar JSON
    json.loads(rendered)

    out = path.replace(".template", "")
    with open(out, "w") as f:
        f.write(rendered)

    print(f"OK: {out}")


def main():
    env = parse_env(".env")
    values = build_replacements(env)

    base = "keycloakcfg"

    for name in os.listdir(base):
        if name.endswith(".json.template"):
            process_file(os.path.join(base, name), values)


if __name__ == "__main__":
    main()