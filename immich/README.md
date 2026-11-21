# immich

## Why

Your photos and videos are the data people least want on someone else's servers, and the most expensive to keep there. [Immich](https://immich.app) is a photo and video library with phone apps that back up your camera roll, on a machine you own.

## What

One app, `immich`, on the place `immich`, on `org`, with its API left to Immich's own login. Immich's phone apps cannot get past an Edgible sign-in, so `/api/` (and `/.well-known/immich`, where the apps find it) goes straight to Immich, where each call needs an Immich token or password. The web app stays behind Edgible's sign-in, so anyone who uses it must be in your Edgible organization. Shared links stay open to anyone with the link (`/share/` and the web app's files it loads), so people outside your organization can open an album or photo you share with them. Nobody can sign up: the first account is the admin, and the admin adds everyone else. Until that first account exists, anyone who reaches Immich can make it, so the API opens only after you make the admin on Immich's first page, in Set up.

It runs four services, from the Compose file Immich publishes for v3.3.1: `immich-server`, `immich-machine-learning` for face recognition and smart search, `immich-redis`, and `immich-db`, a Postgres with vector search. The images are pinned to `v3.3.1`, with the digests Immich publishes for Redis and Postgres. To run without machine learning, remove that service; Immich then skips those features.

To use it in a card, copy the five services, the `x-immich-env` block, the four volumes, card.yml's `secrets:` and `setup:`, and the `IMMICH_` lines.

Photos and videos live in the volume `immich-library`, the database in `immich-db-data`, and machine learning's models in `immich-model-cache`. Back up the first two together. The memory and disk below follow Immich's own documented minimum, which is higher than an empty test library measures; disk is for Immich itself, so add room for your photos and about 20% more for thumbnails. Minimum recommended for the place `immich`: 6 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p immich
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C immich cards-main/immich
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. There are no passwords to fill: Start makes the database's on the machine, and you choose the admin's on Immich's first page.

```bash
nano immich/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py immich
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file immich/card.env -f immich/docker-compose.yml pull
docker compose --env-file immich/card.env -f immich/docker-compose.yml up -d --wait
docker compose --env-file immich/card.env -f immich/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 852 MB, a few minutes on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. immich/card.env
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
  --name immich \
  --port "$IMMICH_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up immich

Publish put `immich` on `org`, so only your Edgible organization reaches it. Open `https://<immich hostname>`, sign in with Edgible, and finish the app's own setup there. Its first page makes the admin: your name, email and password. Use a password manager for the password. Immich then walks you through a few settings, such as its theme and storage template, which you can change later.

When it is finished, this prints `done`:

```bash
set -a
. immich/card.env
set +a
COMPOSE="docker compose --env-file immich/card.env -f immich/docker-compose.yml"
curl -fsS "http://127.0.0.1:$IMMICH_PORT/api/server/config" | grep -q '"isInitialized":true' && echo done
```

Then leave the paths in `appPaths` ([card.yml](card.yml)) to the app's own login, for its apps, now that only the accounts you made can sign in. The web pages stay on `org`.

```bash
curl -fsSLo app-paths.py https://raw.githubusercontent.com/edgible-org/card-kit/main/app-paths.py
python3 app-paths.py immich immich
```

## Verify

`immich` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<immich hostname>"
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<immich hostname>/api/"
```

The first prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front of the web pages. The second prints `immich`'s own answer, with no sign-in address: Set up left the paths in `appPaths` ([card.yml](card.yml)) to its own login, so clients that cannot pass Edgible's sign-in still connect. In the phone app, set the server to `https://<immich hostname>` and sign in with the admin you made in Set up.

For a forgotten admin password, Immich resets it on the machine: `docker compose --env-file immich/card.env -f immich/docker-compose.yml exec immich-server immich-admin reset-admin-password`.

The rest of the setup is in the [Immich docs](https://docs.immich.app).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete immich --yes
```

### 2. Stop

```bash
docker compose --env-file immich/card.env -f immich/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `immich-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=immich); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file immich/card.env -f immich/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf immich
```
