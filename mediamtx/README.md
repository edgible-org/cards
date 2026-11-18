# mediamtx

## Why

Cameras, drones and encoders send live video, and you want one server that takes it in, converts it, and lets you watch it from anywhere. [MediaMTX](https://mediamtx.org) is a ready-to-use media server that takes a stream over RTSP, RTMP or SRT and serves it again over RTSP, RTMP, SRT and HLS.

## What

One MediaMTX server in one place. Its HLS player is published through Edgible with auth mode `org`, so a person in a browser signs in with Edgible first. Cameras publish with the user name `publisher` and the password you choose in `card.env`, and players read on the home network, which the card does not publish. WebRTC is off, since its media needs a UDP port Edgible does not publish. The auth mode is `org` because the callers of this hostname are your own team in a browser; TVs and phone players on the home network use RTSP or SRT directly.

MediaMTX keeps no data. Streams are live and nothing is recorded, so the card has no volumes to back up. Minimum recommended for the place `mediamtx`: 512 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p mediamtx
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C mediamtx cards-main/mediamtx
```

### 2. Edit card.env

Set `DEVICE` and `MEDIAMTX_PUBLISH_PASSWORD`. Keep the ports unless something else on the machine uses them.

```bash
nano mediamtx/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py mediamtx
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file mediamtx/card.env -f mediamtx/docker-compose.yml pull
docker compose --env-file mediamtx/card.env -f mediamtx/docker-compose.yml up -d --wait
docker compose --env-file mediamtx/card.env -f mediamtx/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. mediamtx/card.env
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
  --name mediamtx \
  --port "$MEDIAMTX_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`mediamtx` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<mediamtx hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The hostname sends you to the Edgible sign-in before it shows anything. After signing in, a stream called `cam` that a camera publishes plays at `/cam/`; see the docs for how to publish one.

The rest of the setup is in the [MediaMTX docs](https://mediamtx.org/docs/kickoff/introduction).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete mediamtx --yes
```

### 2. Stop

```bash
docker compose --env-file mediamtx/card.env -f mediamtx/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=mediamtx); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file mediamtx/card.env -f mediamtx/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf mediamtx
```
