# grafana-mcp

## Why

Your dashboards and metrics hold the answers to "why is it slow" and "what changed", and an AI assistant can read them for you, if it can reach a Grafana. The MCP server from Grafana Labs, [mcp-grafana](https://github.com/grafana/mcp-grafana), lets Claude Code and other MCP clients search dashboards, query Prometheus and Loki, and read alerts. This card runs it on a machine next to your Grafana, so you and your team can use it from anywhere, and Edgible keeps it behind a key per person.

## What

One app, `grafana-mcp`, on `api-key`. MCP clients send a key as `Authorization: Bearer`, and Edgible refuses a request without a valid one before it reaches the server. Give each person their own key, so one can be revoked when they leave. Claude Code and most developer clients can send a key; Claude's desktop, web and phone connectors expect an OAuth sign-in instead, so for those put the `mcp-signin` card in front of this server and leave it unpublished. The server reaches your Grafana as one service account, so everyone with a key can do what that account can. It starts read-only (`--disable-write`) and the account should be a Viewer: change that only when the assistant must edit dashboards or alerts. The card needs a Grafana to point at, which it does not include. The image sets the server to the older SSE transport, so the Compose file starts it with Streamable HTTP instead. The server refuses any `Host` header but loopback, so the Compose file passes `--allowed-hosts '*'`: the port is bound to the machine's loopback and Edgible refuses a request without a valid key before it arrives, so the key is the check. If you publish it another way, keep it behind something that checks the caller. The image has no healthcheck of its own; the Compose file adds one that asks the server's `/healthz`.

The card keeps no data. The token is a line in `card.env`, which is the one file to keep. Minimum recommended for the place `grafana-mcp`: 256 MB of memory and 1.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p grafana-mcp
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C grafana-mcp cards-main/grafana-mcp
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Set `GRAFANA_MCP_URL` to your Grafana as Docker on this machine sees it, such as `http://host.docker.internal:3000` for a Grafana on the same machine, and `GRAFANA_MCP_SERVICE_ACCOUNT_TOKEN` to a token of a Viewer service account in it. `chmod 600 grafana-mcp/card.env`, because it now holds a token. Leave `GRAFANA_MCP_ARGS="--disable-write"` unless the assistant should change things.

```bash
nano grafana-mcp/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py grafana-mcp
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file grafana-mcp/card.env -f grafana-mcp/docker-compose.yml pull
docker compose --env-file grafana-mcp/card.env -f grafana-mcp/docker-compose.yml up -d --wait
docker compose --env-file grafana-mcp/card.env -f grafana-mcp/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. grafana-mcp/card.env
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
  --name grafana-mcp \
  --port "$GRAFANA_MCP_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`grafana-mcp` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<grafana-mcp hostname>"
```

Without a key it answers `401`. Make a key for each person, which is shown once: `edgible app api-keys create --app grafana-mcp --name <who>`. Then add the server to Claude Code: `claude mcp add --transport http grafana https://<grafana-mcp hostname>/mcp --header "Authorization: Bearer <key>"`, and `/mcp` in Claude Code lists its tools. `edgible app api-keys list --app grafana-mcp` and `delete` manage the keys.

The rest of the setup is in the [mcp-grafana docs](https://github.com/grafana/mcp-grafana).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete grafana-mcp --yes
```

### 2. Stop

```bash
docker compose --env-file grafana-mcp/card.env -f grafana-mcp/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=grafana-mcp); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file grafana-mcp/card.env -f grafana-mcp/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf grafana-mcp
```
