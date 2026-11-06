# localai

## Why

Apps that speak the OpenAI API, such as chat front ends, coding agents and automation tools, normally send every prompt to a hosted model and are billed per token. [LocalAI](https://localai.io) is one container that answers the same API for language, image and audio models, running on the machine's CPU, and faster on a GPU, so the prompts stay on a machine you own. It suits tinkering with new open models before they are mainstream; do not depend on it for anything that must not fail.

## What

One process on two hostnames. `localai` is the OpenAI-compatible API (`/v1`), on `api-key`, because what calls it is another program: without a key it answers `401`, and a client sends the key as `Authorization: Bearer <key>`. `localai-ui` is the same process on `org`, for a person in a browser to install and try models: only members of your Edgible organisation reach it. Both are port `8080` on the place `localai`; list `localai` first so `LOCALAI_PORT` is named after it. LocalAI has no key of its own here and listens on `127.0.0.1` only, so Edgible's check is what keeps strangers out, and the UI hostname gives an organisation member the power to download and run models on this machine, which is why it is never `none`. Give it a machine with nothing else on it. A GPU needs a GPU image of LocalAI and the Docker GPU runtime, which this card does not set up: the pinned image runs on the CPU.

Models and their configuration live in the volume `localai-models`; the inference backends it downloads when a model needs one live in `localai-backends`, and come back by themselves. Minimum recommended for the place `localai`: 4 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p localai
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C localai cards-main/localai
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `LOCALAI_PORT` only if 8080 is taken. Models are large: a 7B model takes several GB of disk and memory, so size the machine to the models you mean to run.

```bash
nano localai/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py localai
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file localai/card.env -f localai/docker-compose.yml pull
docker compose --env-file localai/card.env -f localai/docker-compose.yml up -d --wait
docker compose --env-file localai/card.env -f localai/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. LocalAI starts with no model. Open the UI (after Publish) and install one from its gallery, or put a model file and its YAML in the `localai-models` volume.

### 5. Publish

```bash
set -euo pipefail
set -a
. localai/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name localai \
  --port "$LOCALAI_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name localai-ui \
  --port "$LOCALAI_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`localai` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<localai hostname>"
```

Without a key it answers `401`. With a key, `GET /v1/models` lists the installed models, and `POST /v1/chat/completions` with a model's name answers once one is installed.

`localai-ui` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<localai-ui hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in with Edgible, then use the Models page to install a model. LocalAI has no sign-in of its own here.

The rest of the setup is in the [LocalAI docs](https://localai.io/docs/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete localai --yes
edgible app delete localai-ui --yes
```

### 2. Stop

```bash
docker compose --env-file localai/card.env -f localai/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=localai); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file localai/card.env -f localai/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf localai
```
