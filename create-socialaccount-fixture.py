# create-socialaccount-fixture.py
import json
import os
import re


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

    # validar JSON (mínimo)
    data = json.loads(rendered)

    out = path.replace(".template", "")
    with open(out, "w") as f:
        json.dump(data, f, indent=2)

    print(f"OK: {out}")


def main():
    base_dir = os.path.dirname(os.path.realpath(__file__))

    env_path = os.path.join(base_dir, ".env")

    template_path = os.path.join(
        base_dir,
        "overrides",
        "geonode",
        "fixtures",
        "socialaccount.json.template"
    )

    env = parse_env(env_path)
    values = build_replacements(env)

    process_file(template_path, values)


if __name__ == "__main__":
    main()