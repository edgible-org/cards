# kyoo

## Why

Films and series you already own shouldn't need a subscription to watch. [Kyoo](https://github.com/zoriya/kyoo) is a free media server for movies, series and anime: it scans your folders, fetches posters and descriptions, transcodes on the fly, and remembers what you watched, from a machine you own.

## What

One app, `kyoo`, on the place `kyoo`, on `org`. Kyoo's own accounts open to anyone who reaches it, and the first account becomes the admin, so the card keeps it behind your Edgible organization: only your team reaches it, and only your team can make an account. Kyoo's phone and TV apps cannot get past that sign-in, so they cannot reach it; the browser can. Use Jellyfin (the `jellyfin` card) if you need native apps from outside.

It runs seven services: `kyoo-front`, `kyoo-auth`, `kyoo-api`, `kyoo-scanner` and `kyoo-transcoder` from the images Kyoo publishes, pinned to `5.3.0`; `kyoo-traefik`, which sends each path to the one that answers it (its routes are in `traefik/dynamic.yml`, so it needs no Docker socket); and `kyoo-db`, Postgres, which publishes no port. Your films and shows sit in the volume `kyoo-media`, mounted read-only. Transcoding runs on the CPU.

To use it in a card, copy the services, the volumes, the `traefik/` folder and the `KYOO_` lines.

Accounts, libraries and watch history live in the Postgres volume `kyoo-db-data`; profile pictures in `kyoo-profile-pictures`. Back up those two. Artwork (`kyoo-images`) is fetched again by a scan, and the transcoder volumes are caches. Your films and shows are in `kyoo-media`: back it up too, as copying it is the only record of what you loaded. The disk is for Kyoo itself, not your media. Minimum recommended for the place `kyoo`: 2 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p kyoo
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C kyoo cards-main/kyoo
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints and `ORG_LABEL` to the label in your apps' hostnames. `KYOO_THEMOVIEDB_TOKEN` is optional. There is no password to fill. After Start, copy your films and shows into the volume with `docker run --rm -v kyoo_kyoo-media:/media -v /path/to/your/media:/src:ro alpine cp -r /src/. /media`, then add the library on Kyoo's page.

```bash
nano kyoo/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py kyoo
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file kyoo/card.env -f kyoo/docker-compose.yml pull
docker compose --env-file kyoo/card.env -f kyoo/docker-compose.yml up -d --wait
docker compose --env-file kyoo/card.env -f kyoo/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. kyoo/card.env
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
  --name kyoo \
  --port "$KYOO_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`kyoo` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<kyoo hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. That redirects you to the Edgible sign-in, so only your organization reaches Kyoo. Open the hostname, sign in with Edgible, then register on Kyoo's own page: the first account is the admin, and can add the library and start a scan. Everyone after gets an account that can browse and play.

The rest of the setup is in the [Kyoo docs](https://github.com/zoriya/kyoo).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete kyoo --yes
```

### 2. Stop

```bash
docker compose --env-file kyoo/card.env -f kyoo/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=kyoo); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file kyoo/card.env -f kyoo/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf kyoo
```
