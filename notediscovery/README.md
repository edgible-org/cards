# notediscovery

## Why

New staff learn what a team knows by asking around, and the answers sit in one person's head or in documents nobody can find. Hosted knowledge tools (Notion, Confluence) charge per seat and keep your material on their servers. [NoteDiscovery](https://github.com/gamosoft/NoteDiscovery) is a small Markdown library: notes are plain files in folders, with full-text search, links and a graph view, and an MCP endpoint so an AI assistant can search and read them to answer a question. This card runs it on a machine you own, through Edgible, as a searchable library of past work and best practices and the start of onboarding.

## What

One process on two hostnames. `notediscovery` is the library in a browser, on `org`, so only members of your Edgible organisation reach it. `notediscovery-mcp` is the same process on `api-key`, for AI assistants, whose MCP client cannot get past an Edgible sign-in: without a key it answers `401`, and a client sends the key as `Authorization: Bearer <key>` or `X-API-Key: <key>` to `/mcp`. Both are port `8000` on the place `notediscovery`; list `notediscovery` first so `NOTEDISCOVERY_PORT` is named after it. NoteDiscovery's own login is left off, because Edgible stands in front of both hostnames, so everyone who gets in sees and can change every note: the key hostname gives its holder the whole API, so make one key per assistant and delete it when it is no longer used. This card suits a team that may all see the same material. NoteDiscovery has no per-folder permissions, so for material some people must not see, run a second card for it or do not use this app. An assistant's answers are only as good as the notes, so ask it for the note it used and have a person check them.

Every note and attachment is a plain file in the volume `notediscovery-data`, so a backup is also a folder you can open in any editor. Minimum recommended for the place `notediscovery`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p notediscovery
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C notediscovery cards-main/notediscovery
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, `ORG_LABEL` to the label in your hostnames, and `NOTEDISCOVERY_TZ` to your time zone. Change `NOTEDISCOVERY_PORT` only if 8000 is taken.

```bash
nano notediscovery/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py notediscovery
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file notediscovery/card.env -f notediscovery/docker-compose.yml pull
docker compose --env-file notediscovery/card.env -f notediscovery/docker-compose.yml up -d --wait
docker compose --env-file notediscovery/card.env -f notediscovery/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. notediscovery/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name notediscovery \
  --port "$NOTEDISCOVERY_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name notediscovery-mcp \
  --port "$NOTEDISCOVERY_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`notediscovery` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<notediscovery hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. That proves the Edgible sign-in stands in front of the library. Then sign in and add a first note; to import existing material, put Markdown files in folders through the app.

`notediscovery-mcp` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<notediscovery-mcp hostname>"
```

That proves the MCP address needs a key. Make one with `edgible app api-keys create --app notediscovery-mcp --name <who-calls-it>`, then add `https://<notediscovery-mcp hostname>/mcp` to the assistant as a Streamable HTTP server that sends it.

The rest of the setup is in the [NoteDiscovery docs](https://github.com/gamosoft/NoteDiscovery/tree/main/documentation).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete notediscovery --yes
edgible app delete notediscovery-mcp --yes
```

### 2. Stop

```bash
docker compose --env-file notediscovery/card.env -f notediscovery/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=notediscovery); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file notediscovery/card.env -f notediscovery/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf notediscovery
```
