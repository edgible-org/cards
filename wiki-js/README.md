# wiki-js

## Why

A team wiki is where a team writes down how it does things, and hosted ones (Notion, Confluence) charge per seat and keep your pages on their servers. [Wiki.js](https://js.wiki) is an open-source wiki with a visual and a Markdown editor, a page tree, search, page history, groups with per-page access rules, and optional sync of its pages to a Git repository. This card runs it on a machine you own, through Edgible.

## What

One app, `wiki-js`, on `org`, so only members of your Edgible organization reach it. Everyone who reads or edits the wiki is a person in a browser, so the Edgible sign-in is the first door and Wiki.js's own login the second. Two containers run it: Wiki.js and PostgreSQL for its pages, uploads and accounts. People outside your organization cannot reach it. For a public knowledge base for customers, publish with `none` instead and let guests read only the pages you choose, which is a different choice from this card's. Use Wiki.js groups and page rules to keep confidential pages to the people who should see them.

The first visit to a new Wiki.js is its setup page, which makes the admin. Behind `org`, only your organization reaches it, so you answer it yourself after Publish: your email and password, and the wiki's address.

Pages, uploads and accounts are in the volume `wiki-js-db-data`, and the database password the card made is in `wiki-js-secrets`. Copy both; the password unlocks the database. Minimum recommended for the place `wiki-js`: 1 GB of memory and 3 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p wiki-js
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C wiki-js cards-main/wiki-js
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `WIKI_JS_PORT` only if 3000 is taken. There are no passwords to fill: Start makes the database's on the machine, and you choose the admin's on Wiki.js's setup page.

```bash
nano wiki-js/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py wiki-js
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml pull
docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml up -d --wait
docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 292 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. wiki-js/card.env
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
  --name wiki-js \
  --port "$WIKI_JS_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up wiki-js

Publish put `wiki-js` on `org`, so only your Edgible organization reaches it. Open `https://<wiki-js hostname>`, sign in with Edgible, and finish the app's own setup there. It asks for the admin's email and password, and the site's address: set it to `https://<wiki-js hostname>`. Use a password manager for the password.

When it is finished, this prints `done`:

```bash
set -a
. wiki-js/card.env
set +a
COMPOSE="docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml"
curl -fsS "http://127.0.0.1:$WIKI_JS_PORT/healthz" | head -c 1 | grep -q '{' && echo done
```

It stays on `org`: there is nothing to switch.

## Verify

`wiki-js` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<wiki-js hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in as the admin you made in Set up, add your team from Administration, Users, and set who may see what under Groups.

The rest of the setup is in the [Wiki.js docs](https://docs.requarks.io).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete wiki-js --yes
```

### 2. Stop

```bash
docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `wiki-js-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=wiki-js); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file wiki-js/card.env -f wiki-js/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf wiki-js
```
