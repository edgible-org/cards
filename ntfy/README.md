# ntfy

## Why

Your scripts, backups and self-hosted apps need a way to tell your phone that something happened, without sending it through a third-party service. [ntfy](https://github.com/binwiederhier/ntfy) takes a plain HTTP request on a topic and pushes it to the phone apps (Android and iPhone) and the web app.

## What

One ntfy container with its own message cache and login database, on one machine. It is published on auth mode `none`, because phone apps and scripts cannot sign in to Edgible. ntfy's own access control is on and denies everyone by default, self-sign-up is off, and `prepare.sh` makes one admin before Publish. Each sender and phone then gets its own login or token, and only the topics you grant. Notifications can show on a locked screen, so keep messages short and say only that something happened.

The volume `ntfy-data` holds the message cache, attachments and the login database (users, tokens and access rules). The admin's password is in the volume `ntfy-secrets`. Minimum recommended for the place `ntfy`: 128 MB of memory and 1 GB of disk, on an arm64, amd64 or 32-bit arm machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p ntfy
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C ntfy cards-main/ntfy
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. `NTFY_ADMIN_USER` is the admin's name. Leave `NTFY_URL` empty unless you use your own domain.

```bash
nano ntfy/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py ntfy
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file ntfy/card.env -f ntfy/docker-compose.yml pull
docker compose --env-file ntfy/card.env -f ntfy/docker-compose.yml up -d --wait
docker compose --env-file ntfy/card.env -f ntfy/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. ntfy denies every topic to everyone until the admin grants access, and `prepare.sh` makes that admin from the password this machine generated, so no setup page is ever public.

```bash
sh ntfy/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the ntfy card: make the admin, so nobody else can.
# Run it after Start and before Publish, from the directory that holds ntfy/:
#   sh ntfy/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# Access control is already on and denies everyone (docker-compose.yml). This adds the one
# login that can grant access, with the password ntfy-secrets made. It does nothing if the
# admin exists.
$COMPOSE exec -T -e NTFY_ADMIN_USER="$NTFY_ADMIN_USER" ntfy sh -c '
  if ntfy user list 2>/dev/null | grep -q "^user $NTFY_ADMIN_USER "; then
    echo "admin $NTFY_ADMIN_USER exists"
  else
    NTFY_PASSWORD=$(cat /run/card-secrets/NTFY_ADMIN_PASSWORD) ntfy user add --role=admin "$NTFY_ADMIN_USER"
  fi'
```

It prints nothing when it works. Show the admin's password on the machine with `docker compose --env-file card.env -f ntfy/docker-compose.yml run --rm ntfy-secrets show NTFY_ADMIN_PASSWORD`. Then sign in to the web app and, from your own terminal, give each sender and phone its own user and token, for example `docker compose --env-file card.env -f ntfy/docker-compose.yml exec ntfy ntfy user add alerts`, then `ntfy access alerts backups write-only` and `ntfy token add alerts`. A phone's user gets `read-only` on the topics it should see. In the phone app, set the server to your ntfy address; on an iPhone, instant delivery needs ntfy's `upstream-base-url` option, which sends ntfy.sh a message ID to wake the app. This card leaves it off, so no third party is involved, and an iPhone gets messages only when the app is open or polls (ntfy's docs say more).

### 5. Publish

```bash
set -euo pipefail
set -a
. ntfy/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name ntfy \
  --port "$NTFY_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`ntfy` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<ntfy hostname>"
```

The address answers with the ntfy web app. Publishing with no login (`curl -d hi https://<address>/test`) answers `403`, and signing in as the admin in the web app works.

The rest of the setup is in the [ntfy docs](https://docs.ntfy.sh).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete ntfy --yes
```

### 2. Stop

```bash
docker compose --env-file ntfy/card.env -f ntfy/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=ntfy); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file ntfy/card.env -f ntfy/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf ntfy
```
