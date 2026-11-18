# librephotos

## Why

Your family's photos are the data you least want on someone else's servers, and the most expensive to keep there. [LibrePhotos](https://docs.librephotos.com) is a photo library that finds people by face, places on a map, and objects and scenes by name, on a machine you own.

## What

One app, `librephotos`, on the place `librephotos`, on `none`. LibrePhotos' own login protects it, so its phone and desktop clients, which cannot get past an Edgible sign-in, can reach it. Nobody can sign up: LibrePhotos makes the admin itself when it starts, with a password made on the machine, so no first page is ever open to a stranger, and Start turns off sign-up before anything is published. The admin adds everyone else.

It runs the single-container image LibrePhotos publishes, `librephotos`, which serves the web app and the API, with Postgres beside it as `librephotos-db`. Face recognition, place names and scene search run inside that container, so give it memory and let the first scan finish: it can take hours on a large library. The images are pinned to `1.6.0` and Postgres 18.

To use it in a card, copy the `librephotos-secrets`, `librephotos` and `librephotos-db` services, the volumes, card.yml's `secrets:`, and the `LIBREPHOTOS_` lines.

Photos you upload live in the volume `librephotos-photos`, thumbnails and the app's keys in `librephotos-media`, the database in `librephotos-db-data`, and machine-learning models in `librephotos-cache`. Back up the first three together. The disk below is LibrePhotos' own documented minimum for thumbnails, the database and models: add room for your photos. Minimum recommended for the place `librephotos`: 4 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p librephotos
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C librephotos cards-main/librephotos
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. `LIBREPHOTOS_ADMIN_EMAIL` may stay empty. There are no passwords to fill: Start makes them on the machine.

```bash
nano librephotos/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py librephotos
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file librephotos/card.env -f librephotos/docker-compose.yml pull
docker compose --env-file librephotos/card.env -f librephotos/docker-compose.yml up -d --wait
docker compose --env-file librephotos/card.env -f librephotos/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

```bash
sh librephotos/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the librephotos card: close sign-up, so only the admin can make accounts.
# Run it after Start and before Publish, from the directory that holds librephotos/:
#   sh librephotos/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# LibrePhotos made the admin at start, with the human secret librephotos-secrets made.
LIBREPHOTOS_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps librephotos-secrets show LIBREPHOTOS_ADMIN_PASSWORD)

B="http://127.0.0.1:$LIBREPHOTOS_PORT"
H='Content-Type: application/json'
token=$(curl -fsS -X POST "$B/api/auth/token/obtain" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$LIBREPHOTOS_ADMIN_PASSWORD\"}" \
  | sed -n 's/.*"access":"\([^"]*\)".*/\1/p')
[ -n "$token" ] || { echo "the admin could not sign in"; exit 1; }
curl -fsS -X POST "$B/api/sitesettings" -H "$H" -H "Authorization: Bearer $token" \
  -d '{"allow_registration":false,"allow_upload":true}' >/dev/null
curl -fsS "$B/api/sitesettings" -H "Authorization: Bearer $token" | tr -d ' ' | grep -q '"allow_registration":false' \
  || { echo "sign-up is still open"; exit 1; }
echo "sign-up is closed; the admin is admin, with LIBREPHOTOS_ADMIN_PASSWORD"
```

### 5. Publish

```bash
set -euo pipefail
set -a
. librephotos/card.env
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
  --name librephotos \
  --port "$LIBREPHOTOS_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`librephotos` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<librephotos hostname>"
```

That prints `200`: the web app, with no Edgible sign-in. Sign in with the user name `admin` and the password from the command under What, then open the admin area to set the folder LibrePhotos scans and to add the people who will use it. Anyone who is not added cannot make an account.

The rest of the setup is in the [LibrePhotos docs](https://docs.librephotos.com).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete librephotos --yes
```

### 2. Stop

```bash
docker compose --env-file librephotos/card.env -f librephotos/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `librephotos-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=librephotos); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file librephotos/card.env -f librephotos/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf librephotos
```
