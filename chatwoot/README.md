# chatwoot

## Why

Customers and members ask the same questions again and again, and they expect to ask on your website or in the chat app they already use. [Chatwoot](https://www.chatwoot.com) is a support inbox with a website chat widget, inboxes for Telegram, Slack-style chat and email, and optional AI replies, so a person or a bot can answer from one place.

## What

One Chatwoot app, with its background worker, Postgres (with pgvector) and Redis. It is on one hostname with auth mode `none`, because the chat widget and the bot webhooks are called by visitors and chat platforms that cannot sign in to Edgible, and the agents' dashboard is on the same app, so it cannot be split off. The protection is Chatwoot's own login, and sign-up is closed (`ENABLE_ACCOUNT_SIGNUP=false`), so only the admin and the agents they add can sign in. You make the admin yourself on Chatwoot's own install page, which a new Chatwoot shows its first visitor, while the app is behind the Edgible sign-in, in [Set up Chatwoot](#6-set-up-chatwoot). If you turn on AI replies with a hosted model, set a spending limit with the model provider, and keep only public information in what the bot can read. Do not let it answer from client, patient or financial records.

Conversations and accounts live in the `chatwoot-db-data` volume, attachments in `chatwoot-storage`, and the generated passwords and keys in `chatwoot-secrets`. Redis (`chatwoot-redis-data`) holds only queues. Minimum recommended for the place `chatwoot`: 3 GB of memory and 5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p chatwoot
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C chatwoot cards-main/chatwoot
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. The mail settings are optional; without them, Chatwoot sends no email.

```bash
nano chatwoot/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py chatwoot
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml pull
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml up -d --wait
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The first start runs Chatwoot's database setup, so it takes a few minutes.

### 5. Publish

```bash
set -euo pipefail
set -a
. chatwoot/card.env
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
  --name chatwoot \
  --port "$CHATWOOT_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `chatwoot` with `org`.

### 6. Set up Chatwoot

A new Chatwoot shows its install page to its first visitor, so Publish put `chatwoot` on `org`: only your Edgible organization reaches it. Open `https://<chatwoot hostname>`, sign in with Edgible, and Chatwoot shows its install page. Give your name, the account's name (such as your company), your own email, and a strong password from a password manager. That makes you the super admin and the account's administrator. Sign-up stays closed: the Compose file sets it.

When the admin exists, this prints `done`:

```bash
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml exec -T chatwoot-db psql -U chatwoot -d chatwoot -tAc 'select count(*) from users' | grep -qvx 0 && echo done
```

Then switch `chatwoot` to `none`, so the chat widget and the chat platforms reach it. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update chatwoot --auth-modes none
```

Add agents under Settings, Agents, and the website widget under Settings, Inboxes.

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`chatwoot` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<chatwoot hostname>"
```

The page answers without an Edgible sign-in, because visitors use the widget. Then sign in with the admin you made in Set up, and check that the sign-in page offers no sign-up link.

The rest of the setup is in the [Chatwoot docs](https://www.chatwoot.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete chatwoot --yes
```

### 2. Stop

```bash
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=chatwoot); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file chatwoot/card.env -f chatwoot/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf chatwoot
```
