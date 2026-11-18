# agent-zero

## Why

An autonomous agent that can write and run code, browse and use tools is the kind of AI people want to try before it is mainstream, and few want to run one on their everyday computer. [Agent Zero](https://github.com/agent0ai/agent-zero) keeps its own Linux desktop inside one Docker image, so the agent works in a sandbox on a machine you choose. This card runs it there, through Edgible, for you to tinker with. Its v2 line changes often, so expect things to move.

## What

One app, `agent-zero`, on `org`, so only members of your Edgible organization reach its web UI. The agent runs code and commands for whoever uses the page, so it is never published to anyone else. Give it a machine with nothing else on it. The card mounts no Docker socket and nothing from the host; the agent's settings, chats and memory are in one named volume.

Settings, chats, memory, projects and plugins are in the volume `agent-zero-data`. Copy it before an upgrade. Your model provider keys are saved there too, so treat the copy as secret. Minimum recommended for the place `agent-zero`: 4 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p agent-zero
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C agent-zero cards-main/agent-zero
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the label in your hostnames. Change `AGENT_ZERO_PORT` only if 5080 is taken. There are no passwords to fill: model provider keys are entered in the app's Settings after you sign in.

```bash
nano agent-zero/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py agent-zero
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file agent-zero/card.env -f agent-zero/docker-compose.yml pull
docker compose --env-file agent-zero/card.env -f agent-zero/docker-compose.yml up -d --wait
docker compose --env-file agent-zero/card.env -f agent-zero/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. agent-zero/card.env
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
  --name agent-zero \
  --port "$AGENT_ZERO_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`agent-zero` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<agent-zero hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. After the Edgible sign-in, open Settings and choose a model provider and enter its key (or point it at a local OpenAI-compatible server such as ollama), then send the agent a message.

The rest of the setup is in the [Agent Zero docs](https://github.com/agent0ai/agent-zero/tree/main/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete agent-zero --yes
```

### 2. Stop

```bash
docker compose --env-file agent-zero/card.env -f agent-zero/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=agent-zero); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file agent-zero/card.env -f agent-zero/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf agent-zero
```
