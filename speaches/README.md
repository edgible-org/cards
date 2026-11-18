# speaches

## Why

Transcribing a meeting, dictating, or giving an app a voice usually means a subscription to a hosted speech service, and sending your audio to it. [Speaches](https://github.com/speaches-ai/speaches) is one container that speaks the same API as OpenAI's audio endpoints: speech to text with faster-whisper, and text to speech with Kokoro or Piper. It runs on a CPU, so no GPU is needed, and nothing you record leaves your machine. Apps and tools that already talk to OpenAI point at it instead.

## What

One process on two hostnames. `speaches` is the API, on `api-key`, because what calls it is another program: without a key it answers `401`, and a client sends the key as `Authorization: Bearer <key>`. `speaches-ui` is the same process on `org`, for a person trying models in a browser: only members of your Edgible organisation reach it. Both are port `8000` on the place `speaches`; list `speaches` first so `SPEACHES_PORT` is named after it. Speaches has no key of its own here and listens on `127.0.0.1` only, so Edgible's check is what keeps strangers out. Recordings are private, so there is no `none` hostname. This is the CPU image; it also runs on a Mac or Linux machine without a GPU.

The models you download live in the volume `speaches-models`. Nothing else is kept: audio is processed and not stored. Losing the volume costs only the download again. Minimum recommended for the place `speaches`: 2 GB of memory and 6 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p speaches
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C speaches cards-main/speaches
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `SPEACHES_PORT` only if 8000 is taken.

```bash
nano speaches/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py speaches
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file speaches/card.env -f speaches/docker-compose.yml pull
docker compose --env-file speaches/card.env -f speaches/docker-compose.yml up -d --wait
docker compose --env-file speaches/card.env -f speaches/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Speaches starts with no models. Download the ones you want once, from the machine, with `curl -X POST http://127.0.0.1:8000/v1/models/Systran/faster-whisper-small` for transcription, and `curl -X POST http://127.0.0.1:8000/v1/models/speaches-ai/Kokoro-82M-v1.0-ONNX` for speech (use your `SPEACHES_PORT`). Larger Whisper models are slower on a CPU.

### 5. Publish

```bash
set -euo pipefail
set -a
. speaches/card.env
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
  --name speaches \
  --port "$SPEACHES_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name speaches-ui \
  --port "$SPEACHES_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`speaches` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<speaches hostname>"
```

Make a key with `edgible app api-keys create --app speaches --name <who>` and give it to each app that calls Speaches. With it, `curl -H "Authorization: Bearer <key>" https://<speaches hostname>/v1/models` lists the downloaded models, and `/v1/audio/transcriptions` takes an audio file, as OpenAI's does.

`speaches-ui` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<speaches-ui hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in with Edgible, then the page lets you try a model by recording or typing.

The rest of the setup is in the [Speaches documentation docs](https://speaches.ai).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete speaches --yes
edgible app delete speaches-ui --yes
```

### 2. Stop

```bash
docker compose --env-file speaches/card.env -f speaches/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=speaches); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file speaches/card.env -f speaches/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf speaches
```
