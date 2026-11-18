# open-webui

## Why

Chatting with an AI usually means typing your questions, and your documents, into a hosted service. [Open WebUI](https://openwebui.com) is a chat interface you run yourself: it talks to models on your own machine (through Ollama, which keeps prompts and documents off outside services), or to any OpenAI-compatible service or gateway you choose, several at once. You can upload documents and ask questions about them, and each person has their own chats.

## What

One app, `open-webui`, on `org`: it is a web interface for people, so Edgible's sign-in stands in front of it and only members of your organization reach it. It has accounts of its own as well, for who sees which chats and documents. Sign-up is closed, but Open WebUI lets its first account through as the admin: after Publish you make it yourself on its first page, behind the Edgible sign-in, and then nobody else can register; the admin adds people under Admin Panel, Users. The card runs no model itself. Point it at one: Ollama on this machine (the default, `host.docker.internal:11434`, as the `ollama-osx` card runs on a Mac), or an OpenAI-compatible address and key in `card.env` or under Admin Settings, Connections, such as the `litellm` card's gateway. Its own OpenAI-compatible API needs a key made in the app; if other programs should call models, give them the `litellm` or `localai` card's API instead, on `api-key`.

Accounts, chats, settings, uploaded documents and their search index are in the volume `open-webui-data`; the signing key is in `open-webui-secrets`. A document answer is only as good as the model behind it: check the sources it cites, and have a person check an answer before relying on it. Minimum recommended for the place `open-webui`: 2 GB of memory and 6 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p open-webui
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C open-webui cards-main/open-webui
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. Set `OPEN_WEBUI_OLLAMA_URL` if Ollama is elsewhere, or enable the OpenAI-compatible connection and its key. These are read at the first start only; afterwards change them in the app. Change `OPEN_WEBUI_PORT` only if 8080 is taken.

```bash
nano open-webui/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py open-webui
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml pull
docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml up -d --wait
docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 1.5 GB, ten minutes or more on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. open-webui/card.env
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
  --name open-webui \
  --port "$OPEN_WEBUI_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up open-webui

Publish put `open-webui` on `org`, so only your Edgible organization reaches it. Open `https://<open-webui hostname>`, sign in with Edgible, and finish the app's own setup there. Its first page makes the admin: your name, email and a password from a password manager. After that, sign-up stays closed.

When it is finished, this prints `done`:

```bash
set -a
. open-webui/card.env
set +a
COMPOSE="docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml"
curl -fsS "http://127.0.0.1:$OPEN_WEBUI_PORT/api/config" | python3 -c 'import json, sys; sys.exit(1 if json.load(sys.stdin).get("onboarding") else 0)' && echo done
```

It stays on `org`: there is nothing to switch.

## Verify

`open-webui` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<open-webui hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in as the admin you made in Set up, add a model connection if you have not, and send a message. A person who is not in your organization is stopped at Edgible's sign-in.

The rest of the setup is in the [Open WebUI docs](https://docs.openwebui.com).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete open-webui --yes
```

### 2. Stop

```bash
docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `open-webui-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=open-webui); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file open-webui/card.env -f open-webui/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf open-webui
```
