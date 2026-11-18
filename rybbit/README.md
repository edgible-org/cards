# rybbit

## Why

Knowing who visits your site usually means handing every visitor to an analytics company, or a cookie banner. [Rybbit](https://rybbit.com) is open source web and product analytics that counts visits without cookies, and keeps the data on a machine you own, so you stop paying for it and have nothing to ask consent for.

## What

One app on two hostnames, both served by one Caddy proxy, `rybbit` on port `8080` and `rybbit-analytics` on port `8081`, in the place `rybbit`. `rybbit` is the dashboard and its API, behind `org`, so only members of your Edgible organization reach it. `rybbit-analytics` is on `none`, because every visitor's browser loads the tracking script from it and sends page views to it. The proxy lets only the script's own paths through there (the script, its tracking settings, `/api/track`, `/api/identify` and session replay), and answers `404` to everything else, so no sign-in, sign-up or dashboard API is open to the public. Behind the proxy run Rybbit's web app and backend, Postgres for accounts and sites, ClickHouse for the page views, and Redis for sessions, none of them published. Sign-up is open on the dashboard hostname, so each member of your organization can make an account; set `RYBBIT_DISABLE_SIGNUP=true` once yours exists to stop that. Rybbit's telemetry is off.

Accounts and sites are in the volume `rybbit-db-data`, the page views in `rybbit-clickhouse-data`, and the generated passwords and key in `rybbit-secrets`. Redis's volume `rybbit-redis-data` is a cache. Minimum recommended for the place `rybbit`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p rybbit
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C rybbit cards-main/rybbit
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the label in your apps' hostnames. Change `RYBBIT_PORT` or `RYBBIT_ANALYTICS_PORT` only if they are taken.

```bash
nano rybbit/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py rybbit
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file rybbit/card.env -f rybbit/docker-compose.yml pull
docker compose --env-file rybbit/card.env -f rybbit/docker-compose.yml up -d --wait
docker compose --env-file rybbit/card.env -f rybbit/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The first start takes a minute or two longer than most cards: the backend waits for Postgres and ClickHouse, then migrates both. There is no admin to make first, because the dashboard is on `org`: after Publish, the first sign-up you make on it is your account.

### 5. Publish

```bash
set -euo pipefail
set -a
. rybbit/card.env
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
  --name rybbit \
  --port "$RYBBIT_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name rybbit-analytics \
  --port "$RYBBIT_ANALYTICS_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`rybbit` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<rybbit hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The dashboard redirects to the Edgible sign-in. Once signed in, open `/signup` on it and make your account, then add a site.

`rybbit-analytics` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<rybbit-analytics hostname>"
```

The tracking script answers with no sign-in, and the dashboard's own paths answer `404`. Put the snippet Rybbit shows for your site into its pages, with the `rybbit-analytics` hostname as its source, which is `https://<hostname>/api/script.js`.

The rest of the setup is in the [Rybbit docs docs](https://rybbit.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete rybbit --yes
edgible app delete rybbit-analytics --yes
```

### 2. Stop

```bash
docker compose --env-file rybbit/card.env -f rybbit/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=rybbit); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file rybbit/card.env -f rybbit/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf rybbit
```
