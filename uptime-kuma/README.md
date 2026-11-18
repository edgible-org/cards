# uptime-kuma

## Why

You want to know your sites and services are up before your users tell you. [Uptime Kuma](https://github.com/louislam/uptime-kuma) checks them on a schedule, alerts you through dozens of channels, and draws status pages, from a machine you own. This card puts its interface behind your org login.

## What

One app, `uptime-kuma`, on the place `uptime-kuma`, behind `org`. The image is `louislam/uptime-kuma:2.5.9-slim`, about 180 MB. It keeps monitors in SQLite and leaves out the bundled MariaDB and the browser-based monitors; `2.5.9` is the full image, about 600 MB, if you want those. The image brings its own healthcheck. A new Uptime Kuma asks its first visitor to pick a database and make the admin; behind `org`, only your organization reaches that, so you do it yourself after Publish.

A monitor on the same machine as what it watches cannot report that machine going down. Put this card on a different serving device from the services it checks. To use it in a card, copy the `uptime-kuma` service and its volume, `UPTIME_KUMA_PORT`, and card.yml's `setup:`, and give it its own place.

Monitors, settings and history live in the volume `uptime-kuma-data`. Minimum recommended for the place `uptime-kuma`: 256 MB of memory and 1.5 GB of disk, on an arm64, amd64 or 32-bit arm machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p uptime-kuma
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C uptime-kuma cards-main/uptime-kuma
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints.

```bash
nano uptime-kuma/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py uptime-kuma
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml pull
docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml up -d --wait
docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 183 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. uptime-kuma/card.env
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
  --name uptime-kuma \
  --port "$UPTIME_KUMA_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up uptime-kuma

Publish put `uptime-kuma` on `org`, so only your Edgible organization reaches it. Open `https://<uptime-kuma hostname>`, sign in with Edgible, and finish the app's own setup there. Its first page asks for the database: choose SQLite, which this image is made for. Then it makes the admin: a username and a password from a password manager.

When it is finished, this prints `done`:

```bash
set -a
. uptime-kuma/card.env
set +a
COMPOSE="docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml"
$COMPOSE exec -T uptime-kuma sh -c 'test -f /app/data/kuma.db && sqlite3 -readonly /app/data/kuma.db "select count(*) from user"' | grep -q '^[1-9]' && echo done
```

It stays on `org`: there is nothing to switch.

## Verify

`uptime-kuma` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<uptime-kuma hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the hostname in a browser, sign in to Edgible, then to Uptime Kuma as the admin you made in Set up.

The rest of the setup is in the [Uptime Kuma docs](https://github.com/louislam/uptime-kuma/wiki).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete uptime-kuma --yes
```

### 2. Stop

```bash
docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=uptime-kuma); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file uptime-kuma/card.env -f uptime-kuma/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf uptime-kuma
```
