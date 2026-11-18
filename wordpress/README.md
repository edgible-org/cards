# wordpress

## Why

WordPress runs a large share of the web, and most of it sits with a host you pay every month. [WordPress](https://wordpress.org) runs just as well on a machine you own, with the database beside it.

## What

One app, `wordpress`, on the place `wordpress`, on `none`: it is a public site. Its admin, `/wp-admin`, is on the same hostname, because WordPress sends every request to its one address; Edgible's auth is per hostname, so the admin cannot be put behind `org` on its own. WordPress's login protects it.

WordPress keeps its address in its settings, so `WP_HOME` and `WP_SITEURL` are `https://wordpress.<ORG_LABEL>.<EDGIBLE_DOMAIN>`, or `WORDPRESS_URL` on your own domain. A fresh WordPress hands its admin to whoever opens its install page first, so the card publishes it on `org` first: only your Edgible organization reaches it while you answer WordPress's own setup (its language, the site's title, your admin and password). Then you open it to everyone.

The images are `wordpress:7.1.4-php8.3-apache`, `mariadb:11.8.9`, and `wordpress:cli-2.12.0-php8.3`. To use it in a card, copy the four services, the `x-wordpress-env` block, the three volumes, card.yml's `secrets:` and `setup:`, and the `WORDPRESS_` lines.

Your posts, pages, users and settings are in the database volume `wordpress-db-data`; uploads, themes and plugins are in `wordpress-files`; the database password is in `wordpress-secrets`. Back up all three. Minimum recommended for the place `wordpress`: 384 MB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p wordpress
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C wordpress cards-main/wordpress
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the part after the app name in a hostname `edgible app list` prints. There are no passwords to fill: Start makes the database's on the machine, and you choose the admin's in WordPress's setup.

```bash
nano wordpress/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py wordpress
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml pull
docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml up -d --wait
docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 377 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. wordpress/card.env
set +a
device_id=$(edgible device list --json | python3 -c '
import json, sys
name = sys.argv[1]
found = [d for d in json.load(sys.stdin) if d["name"] == name]
if len(found) != 1:
    sys.exit("need exactly one device named " + name + " (" + ", ".join(d["status"] + " " + d["id"] for d in found) + ")")
print(found[0]["id"])
' "$DEVICE")
edgible app create existing \
  --non-interactive \
  --name wordpress \
  --port "$WORDPRESS_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up wordpress

Publish put `wordpress` on `org`, so only your Edgible organization reaches it. Open `https://<wordpress hostname>`, sign in with Edgible, and finish the app's own setup there. Use a password manager for the admin's password: the site is public once you open it.

When it is finished, this prints `done`:

```bash
set -a
. wordpress/card.env
set +a
COMPOSE="docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml"
$COMPOSE --profile cli run --rm -T wordpress-cli wp core is-installed && echo done
```

Then switch it to `none`. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update wordpress --auth-modes none
```

## Verify

`wordpress` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<wordpress hostname>"
```

That prints `200`: the installed site. Sign in at `https://<wordpress hostname>/wp-admin` with the admin you made in Set up.

WordPress cannot send email from most home machines, so its "Lost your password?" link may not work. To set a new password for a user, on the machine: `docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml --profile cli run --rm -T wordpress-cli wp user update <user> --prompt=user_pass`.

The rest of the setup is in the [WordPress docs](https://wordpress.org/documentation/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete wordpress --yes
```

### 2. Stop

```bash
docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `wordpress-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=wordpress); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file wordpress/card.env -f wordpress/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf wordpress
```
