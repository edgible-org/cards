# weaviate

## Why

A RAG app, a semantic search over your documents, or an agent's memory needs somewhere to keep embeddings and search them by meaning. A hosted vector database charges by the query and holds your text's embeddings, which can reveal the text. [Weaviate](https://weaviate.io) is one container with REST, GraphQL and gRPC APIs and built-in hybrid search (keyword and vector together), small enough to run on a machine you own, with no per-query bill. It is heavier than Qdrant, and worth it when you want hybrid search or filtering that mixes both.

## What

One process on one hostname. `weaviate` is the REST and GraphQL API, on `api-key`, because what calls it is another program, not a person, and Weaviate has no dashboard to put behind `org`. Without a key it answers `401`, and a client sends the key in an `Authorization` header as `Bearer <key>`. Weaviate's own sign-in is off and it listens on `127.0.0.1` only, so Edgible's check is what keeps strangers out. An app on the same machine can skip Edgible and call `http://127.0.0.1:8080`, with nothing published. Embeddings can reveal the text they came from, so treat them like the documents, and if only an app on the same machine uses it, publish nothing. No vectorizer modules are enabled, so your app sends its own embeddings with each object. Only the REST and GraphQL port is published, gRPC (port `50051`) is not.

Collections, objects, vectors and indexes live in the volume `weaviate-data`. Minimum recommended for the place `weaviate`: 1 GB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p weaviate
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C weaviate cards-main/weaviate
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `WEAVIATE_PORT` only if 8080 is taken. Weaviate keeps vectors in memory for fast search, so a million 768-number vectors needs about 4 GB; size the machine to your documents.

```bash
nano weaviate/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py weaviate
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file weaviate/card.env -f weaviate/docker-compose.yml pull
docker compose --env-file weaviate/card.env -f weaviate/docker-compose.yml up -d --wait
docker compose --env-file weaviate/card.env -f weaviate/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. weaviate/card.env
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
  --name weaviate \
  --port "$WEAVIATE_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`weaviate` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<weaviate hostname>"
```

Without a key it answers `401`. Make a key with `edgible app api-keys create --app weaviate --name <who>` and give it to each app that calls Weaviate. Send it in an `Authorization` header as `Bearer <key>` to `https://<weaviate hostname>/v1/schema`, which lists the collections.

The rest of the setup is in the [Weaviate documentation docs](https://docs.weaviate.io).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete weaviate --yes
```

### 2. Stop

```bash
docker compose --env-file weaviate/card.env -f weaviate/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=weaviate); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file weaviate/card.env -f weaviate/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf weaviate
```
