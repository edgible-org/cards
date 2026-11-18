# docmost

## Why

A team wiki is where a team writes down how it does things, and hosted ones (Notion, Confluence) charge per seat and keep your pages on their servers. [Docmost](https://docmost.com) is an open-source wiki with spaces, page trees, real-time editing, comments, diagrams, and permissions per space and group. This card runs it on a machine you own, through Edgible.

## What

One app, `docmost`, on `org`, so only members of your Edgible organization reach it. Everyone who reads or edits the wiki is a person in a browser, so the Edgible sign-in is the first door and Docmost's own login the second. Three containers run it: Docmost, PostgreSQL for its pages and accounts, and Redis for live editing. People outside your organization cannot reach it. For a public knowledge base for customers, publish with `none` instead and keep sign-up closed, which is a different choice from this card's. Use Docmost's spaces and roles to keep confidential pages to the people who should see them.

The first visit to a new Docmost is its setup page, which makes the workspace and its admin. Behind `org`, only your organization reaches it, so you answer it yourself after Publish: the workspace's name, and your name, email and password.

Pages and accounts are in the volume `docmost-db-data`, uploaded files in `docmost-data`, and the keys the card made in `docmost-secrets`. Copy all three; the keys unlock the database. Minimum recommended for the place `docmost`: 1 GB of memory and 3 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p docmost
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C docmost cards-main/docmost
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the label in your hostnames. Change `DOCMOST_PORT` only if 3000 is taken. There are no passwords to fill: Start makes the card's keys on the machine, and you choose the admin's on Docmost's setup page.

```bash
nano docmost/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py docmost
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file docmost/card.env -f docmost/docker-compose.yml pull
docker compose --env-file docmost/card.env -f docmost/docker-compose.yml up -d --wait
docker compose --env-file docmost/card.env -f docmost/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 379 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. docmost/card.env
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
  --name docmost \
  --port "$DOCMOST_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up docmost

Publish put `docmost` on `org`, so only your Edgible organization reaches it. Open `https://<docmost hostname>`, sign in with Edgible, and finish the app's own setup there. It asks for the workspace's name, and your name, email and password, which make you its admin. Use a password manager for the password.

When it is finished, this prints `done`:

```bash
set -a
. docmost/card.env
set +a
COMPOSE="docker compose --env-file docmost/card.env -f docmost/docker-compose.yml"
$COMPOSE exec -T docmost-db psql -U docmost -d docmost -tAc 'select count(*) from workspaces' | grep -q '^[1-9]' && echo done
```

It stays on `org`: there is nothing to switch.

## Verify

`docmost` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<docmost hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in as the admin you made in Set up, and invite your team from Settings, Members. Docmost sends invitations by email only when you configure mail in its settings; without it, copy each invitation link from the members page.

The rest of the setup is in the [Docmost docs](https://docmost.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete docmost --yes
```

### 2. Stop

```bash
docker compose --env-file docmost/card.env -f docmost/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `docmost-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=docmost); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file docmost/card.env -f docmost/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf docmost
```
