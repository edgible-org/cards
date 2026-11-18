# gotify

## Why

Your scripts, backups and self-hosted apps need a way to tell your phone that something happened, without sending it through a third-party service. [Gotify](https://gotify.net) takes a plain HTTP request with an application token and pushes it to its Android app and web interface. It has no iOS app of its own, so on an iPhone choose ntfy instead.

## What

One Gotify container with its own users, application tokens and message store, on one machine. It is published on auth mode `none`, because the Android app and your scripts cannot sign in to Edgible. Gotify's own login is on, self-registration is off, and the admin is made on the first start with a password this machine generated, so Gotify's default login never exists and nobody can claim the first visit. Each sender then gets its own application token, and each phone its own user. Notifications can show on a locked screen, so keep messages short and say only that something happened.

The volume `gotify-data` holds the database (users, application tokens, messages) and uploaded images. The admin's password is in the volume `gotify-secrets`. Minimum recommended for the place `gotify`: 64 MB of memory and 1 GB of disk, on an arm64, amd64 or 32-bit arm machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p gotify
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C gotify cards-main/gotify
```

### 2. Edit card.env

Set `DEVICE`. `GOTIFY_DEFAULTUSER_NAME` is the admin's name, used only at the first start.

```bash
nano gotify/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py gotify
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file gotify/card.env -f gotify/docker-compose.yml pull
docker compose --env-file gotify/card.env -f gotify/docker-compose.yml up -d --wait
docker compose --env-file gotify/card.env -f gotify/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Gotify makes the admin at its first start from the password this machine generated, so no setup page is ever public. Show the password on the machine with `docker compose --env-file gotify/card.env -f gotify/docker-compose.yml run --rm gotify-secrets show GOTIFY_DEFAULTUSER_PASS`. Sign in to the web interface, create an application for each sender (its token is what a script sends, as `curl "https://<address>/message?token=<token>" -F title=Backup -F message=failed`), and a user for each phone. In the Android app, set the server to your Gotify address and sign in as that user.

### 5. Publish

```bash
set -euo pipefail
set -a
. gotify/card.env
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
  --name gotify \
  --port "$GOTIFY_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`gotify` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<gotify hostname>"
```

Publishing with no token (`curl -d message=hi https://<address>/message`) answers `401`, and signing in as the admin in the web interface works.

The rest of the setup is in the [Gotify docs](https://gotify.net/docs/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete gotify --yes
```

### 2. Stop

```bash
docker compose --env-file gotify/card.env -f gotify/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=gotify); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file gotify/card.env -f gotify/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf gotify
```
