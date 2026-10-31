# qdrant

## Why

A RAG app, a semantic search over your documents, or an agent's memory needs somewhere to keep embeddings and search them by meaning. A hosted vector database charges by the query and holds your text's embeddings, which can reveal the text. [Qdrant](https://qdrant.tech) is one container with a REST and gRPC API and a built-in dashboard, small enough to run on a machine you own, with no per-query bill.

## What

One process on two hostnames. `qdrant` is the REST API, on `api-key`, because what calls it is another program, not a person: without a key it answers `401`, and a client sends the key as `Authorization: Bearer <key>` or `X-API-Key: <key>`. `qdrant-dashboard` is the same process on `org`, for a person in a browser: only members of your Edgible organisation reach it. Both are port `6333` on the place `qdrant`; list `qdrant` first so `QDRANT_PORT` is named after it. Qdrant has no key of its own here and listens on `127.0.0.1` only, so Edgible's check is what keeps strangers out, and the dashboard hostname gives an organisation member the whole API, which is why it is `org`. An app on the same machine can skip Edgible and call `http://127.0.0.1:6333`, with nothing published. Embeddings can reveal the text they came from, so treat them like the documents: if only an app on the same machine uses it, publish nothing. Only the REST API is published: gRPC (port `6334`) is not.

Collections, vectors, payloads and snapshots live in the volume `qdrant-data`. Minimum recommended for the place `qdrant`: 512 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p qdrant
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C qdrant cards-main/qdrant
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `QDRANT_PORT` only if 6333 is taken. A collection of a million 768-number vectors takes roughly 3 GB of memory and disk, so size the machine to your documents.

```bash
nano qdrant/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py qdrant
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file qdrant/card.env -f qdrant/docker-compose.yml pull
docker compose --env-file qdrant/card.env -f qdrant/docker-compose.yml up -d --wait
docker compose --env-file qdrant/card.env -f qdrant/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. qdrant/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name qdrant \
  --port "$QDRANT_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name qdrant-dashboard \
  --port "$QDRANT_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`qdrant` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<qdrant hostname>"
```

Make a key with `edgible app api-keys create --app qdrant --name <who>` and give it to each app that calls Qdrant. `curl -H "Authorization: Bearer <key>" https://<qdrant hostname>/collections` lists the collections.

`qdrant-dashboard` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<qdrant-dashboard hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in with Edgible, then the dashboard is at `/dashboard`.

The rest of the setup is in the [Qdrant documentation docs](https://qdrant.tech/documentation/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete qdrant --yes
edgible app delete qdrant-dashboard --yes
```

### 2. Stop

```bash
docker compose --env-file qdrant/card.env -f qdrant/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=qdrant); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file qdrant/card.env -f qdrant/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf qdrant
```
