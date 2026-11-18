# dayglance

## Why

You want your calendars and tasks planned in one place without handing them to Google. [dayGLANCE](https://dayglance.app) is a day planner with time blocking, recurring tasks, habits and a focus timer. It reads iCal and CalDAV calendars and syncs its own data over WebDAV, from a machine you own. This card puts it behind your org login.

## What

One app, `dayglance`, on the place `dayglance`, behind `org`. The image is `ghcr.io/krelltunez/dayglance:5.15.0`. dayGLANCE is not a calendar server: it is a client, so point it at a CalDAV or WebDAV server you already have (Nextcloud, Radicale, Synology). It has no accounts of its own, and only your organization reaches it. Its plans stay in each person's browser unless they turn on WebDAV sync, so a shared family calendar comes from the CalDAV server you point it at. Family who are not in your Edgible organization cannot open it through this card.

The container keeps nothing: plans, settings and sync settings live in each browser's storage, and in the WebDAV server if you turn on sync. There is no volume to back up. Minimum recommended for the place `dayglance`: 128 MB of memory and 0.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p dayglance
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C dayglance cards-main/dayglance
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Set `DAYGLANCE_PROXY_BLOCK_PRIVATE=1` if your calendars are all on the internet and you want the proxy to refuse private addresses.

```bash
nano dayglance/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py dayglance
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file dayglance/card.env -f dayglance/docker-compose.yml pull
docker compose --env-file dayglance/card.env -f dayglance/docker-compose.yml up -d --wait
docker compose --env-file dayglance/card.env -f dayglance/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. dayglance/card.env
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
  --name dayglance \
  --port "$DAYGLANCE_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`dayglance` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<dayglance hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the hostname in a browser and sign in to Edgible. dayGLANCE opens at once, with no second sign-in. Add a calendar under Settings, Calendar Sync.

The rest of the setup is in the [dayGLANCE docs](https://docs.dayglance.app/self-hosting).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete dayglance --yes
```

### 2. Stop

```bash
docker compose --env-file dayglance/card.env -f dayglance/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=dayglance); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file dayglance/card.env -f dayglance/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf dayglance
```
