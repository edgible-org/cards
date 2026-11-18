# kokoro-fastapi

## Why

You want spoken audio from text (read-aloud, voice assistants, narration) without a per-character subscription. [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) wraps the small Kokoro voice model in an OpenAI-compatible speech API, and its CPU image needs no GPU.

## What

One Kokoro-FastAPI container, with the model inside the image. It has no accounts, so it is never published on `none`. The API (`/v1/audio/speech`) is on `api-key`: the apps that call it send an Edgible API key. Its demo page (`/web`) is on `org`: only your Edgible organization reaches it. Both hostnames are the same process.

Kokoro keeps nothing: the model is in the image and each request returns audio. Minimum recommended for the place `kokoro-fastapi`: 2 GB of memory and 6 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p kokoro-fastapi
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C kokoro-fastapi cards-main/kokoro-fastapi
```

### 2. Edit card.env

Set `DEVICE`. There are no passwords to fill: make an API key after Publish.

```bash
nano kokoro-fastapi/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py kokoro-fastapi
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file kokoro-fastapi/card.env -f kokoro-fastapi/docker-compose.yml pull
docker compose --env-file kokoro-fastapi/card.env -f kokoro-fastapi/docker-compose.yml up -d --wait
docker compose --env-file kokoro-fastapi/card.env -f kokoro-fastapi/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. kokoro-fastapi/card.env
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
  --name kokoro-fastapi \
  --port "$KOKORO_FASTAPI_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name kokoro-fastapi-ui \
  --port "$KOKORO_FASTAPI_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`kokoro-fastapi` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<kokoro-fastapi hostname>"
```

Answers `401` until an API key is sent. Make a key with `edgible app api-keys create`, then request `/v1/audio/voices` with it.

`kokoro-fastapi-ui` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<kokoro-fastapi-ui hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sends a stranger to the Edgible sign-in; signed in as a member of your organization, open `/web` to try a voice.

The rest of the setup is in the [Kokoro-FastAPI docs](https://github.com/remsky/Kokoro-FastAPI).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete kokoro-fastapi --yes
edgible app delete kokoro-fastapi-ui --yes
```

### 2. Stop

```bash
docker compose --env-file kokoro-fastapi/card.env -f kokoro-fastapi/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=kokoro-fastapi); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file kokoro-fastapi/card.env -f kokoro-fastapi/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf kokoro-fastapi
```
