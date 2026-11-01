# linkwarden

## Why

Bookmarks scattered across browsers and phones, and pages that vanish after you saved them, are what a hosted read-later service solves, and then keeps. [Linkwarden](https://linkwarden.app) saves each link with a screenshot, a PDF and a readable copy of the page, files links in collections you can share with your team, and keeps all of it on a machine you own.

## What

One app, `linkwarden`, on `none`: its browser extension and phone app cannot get past an Edgible sign-in, and the web pages sit on the same hostname, so the app's own login is the protection. Sign-up is closed, so only the admin and the people the admin adds can get in. Two containers run it: Linkwarden, which also runs its page-archiving worker and a headless browser, and Postgres. Search is Linkwarden's built-in one; its optional Meilisearch index is left out.

The links are in the volume `linkwarden-db-data`. The saved screenshots, PDFs and page copies are in `linkwarden-data`. Both are irreplaceable, and so is `linkwarden-secrets`, which holds the passwords and the key that signs sessions. Minimum recommended for the place `linkwarden`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p linkwarden
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C linkwarden cards-main/linkwarden
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints and `ORG_LABEL` as the file says. Change `LINKWARDEN_ADMIN_USER` if you like, using lowercase letters, digits, `-` and `_`.

```bash
nano linkwarden/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py linkwarden
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml pull
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml up -d --wait
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Sign-up is closed in the Compose file. `prepare.sh` opens it for one request on the machine, before anything is published, to make the admin, and closes it again. Its password is the secret `LINKWARDEN_ADMIN_PASSWORD`; show it with `docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml run --rm --no-deps linkwarden-secrets show LINKWARDEN_ADMIN_PASSWORD`.

```bash
sh linkwarden/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the linkwarden card: make the admin before the sign-up page is public.
# Run it after Start and before Publish, from the directory that holds linkwarden/:
#   sh linkwarden/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret linkwarden-secrets made on this machine.
LINKWARDEN_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps linkwarden-secrets show LINKWARDEN_ADMIN_PASSWORD)

# Open sign-up for this one local request. Nothing is published yet.
LINKWARDEN_DISABLE_REGISTRATION=false $COMPOSE up -d --wait linkwarden
B="http://127.0.0.1:$LINKWARDEN_PORT"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H 'Content-Type: application/json' \
  -d "{\"name\":\"$LINKWARDEN_ADMIN_USER\",\"username\":\"$LINKWARDEN_ADMIN_USER\",\"password\":\"$LINKWARDEN_ADMIN_PASSWORD\"}")

# Close it again, whatever happened: recreate with the Compose file's default.
$COMPOSE up -d --wait --force-recreate linkwarden
[ "$code" = 201 ] || [ "$code" = 400 ] || { echo "creating the admin answered $code"; exit 1; }
echo "admin $LINKWARDEN_ADMIN_USER made; sign-up is closed again"
```

It prints that the admin was made and sign-up is closed again. Sign in as that admin and change the password under Settings. Add teammates under Admin Panel.

### 5. Publish

```bash
set -euo pipefail
set -a
. linkwarden/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name linkwarden \
  --port "$LINKWARDEN_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`linkwarden` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<linkwarden hostname>"
```

The check proves a stranger cannot sign up, and that the admin signs in. Sign in at the hostname as the admin, save a link, and open its saved copy. The browser extension and phone app take the same address and the same login.

The rest of the setup is in the [Linkwarden docs](https://docs.linkwarden.app).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete linkwarden --yes
```

### 2. Stop

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=linkwarden); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf linkwarden
```
