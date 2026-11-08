# ollama-nvidia

## Why

[Ollama](https://ollama.com) runs open models, such as Llama, Qwen, Gemma and Mistral, on your own machine, behind one API that many tools speak. This card runs it in Docker on a Linux machine's NVIDIA GPU, and Edgible publishes it through a small proxy, so your tools and AI agents can use your models from anywhere, behind an API key, without a cloud provider seeing your prompts, and without anything on your own network being able to reach Ollama. On an Apple Silicon Mac, use the `ollama-osx` card instead: Docker on macOS has no GPU.

## What

One app, `ollama`, the Ollama API on `api-key`: without a key it answers `401`, and with one any client that speaks Ollama's API works, such as Open WebUI, Continue, or your own scripts, with the key sent as `Authorization: Bearer <key>` or `X-API-Key: <key>`. Ollama has no login of its own, so the key is what keeps strangers off your GPU. Two services: `ollama-nvidia` listens on 127.0.0.1 (`OLLAMA_LOCAL_PORT`) for managing models on the machine, and `ollama-nvidia-proxy`, a [Caddy](https://caddyserver.com) proxy on 127.0.0.1 (`OLLAMA_PORT`), passes on only what a client needs to use a model: chat, generate, embeddings, the model list and its details, and the OpenAI-style `/v1` routes. Pulling, creating, copying, pushing and deleting a model are refused with `403`, so a key can use your models and cannot change them. Edgible publishes the proxy. The GPU comes through Docker's `nvidia` runtime: the `docker` snap sets it up itself once the NVIDIA driver is installed (check that `snap services docker` shows `docker.nvidia-container-toolkit` enabled); Docker from apt needs NVIDIA's container toolkit and `nvidia-ctk runtime configure`. A model needs about its own size in GPU memory to run fully on the GPU: on an 8 GB card, models up to about 8B parameters at 4-bit.

Models live in the volume `ollama-nvidia-models`. A small model takes 2 to 5 GB, a large one 20 to 40 GB. They can be downloaded again, so the volume needs no backup unless the connection is slow or metered. Minimum recommended for the place `ollama`: 8 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p ollama-nvidia
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C ollama-nvidia cards-main/ollama-nvidia
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Keep `OLLAMA_LOCAL_PORT` at `11434`, the port Ollama's clients expect, unless another Ollama already runs on this machine. `OLLAMA_KEEP_ALIVE` is how long a model stays in GPU memory after its last request.

```bash
nano ollama-nvidia/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py ollama-nvidia
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml pull
docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml up -d --wait
docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 3.4 GB, ten minutes or more on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Then download a model on the machine: `curl http://127.0.0.1:11434/api/pull -d '{"model": "llama3.2"}'`, or `docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml exec ollama-nvidia ollama pull llama3.2`.

### 5. Publish

```bash
set -euo pipefail
set -a
. ollama-nvidia/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name ollama \
  --port "$OLLAMA_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`ollama` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<ollama hostname>"
```

Make a key for each person or tool, which is shown once: `edgible app api-keys create --app ollama --name <who>`. Then `curl -H "Authorization: Bearer <key>" https://<ollama hostname>/api/tags` lists your models. The card's tests ask a tiny model a question and check with `/api/ps` that it ran 100% on the GPU; call the published app with a throwaway key (`401` without it, `200` with it, a streamed answer, and `403` for pull, create, copy, delete and push); and check that both ports listen on 127.0.0.1 only.

The rest of the setup is in the [Ollama docs](https://github.com/ollama/ollama/tree/main/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete ollama --yes
```

### 2. Stop

```bash
docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=ollama-nvidia); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file ollama-nvidia/card.env -f ollama-nvidia/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf ollama-nvidia
```
