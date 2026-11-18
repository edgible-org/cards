# ech0

## Why

A short-post blog or notes feed on a hosted service lives under that service's terms. [Ech0](https://github.com/lin-snow/Ech0) is a lightweight publishing platform for personal posts, with a public timeline, that runs on a machine you own. It has no newsletter or paid members: it suits a personal blog or micro-blog, not a replacement for Substack's email list.

## What

One app, `ech0`, on the place `ech0`, on `none`. A blog is public, so readers need no Edgible sign-in, and the owner's own login in Ech0 protects publishing. The first account to register on a fresh Ech0 becomes its owner, and anyone can register after, so the card publishes it on `org` first: only your Edgible organization reaches it while you make the owner and close sign-up. Then you open it to everyone. The image is `sn0wl1n/ech0:v5.9.5`, from Docker Hub, and the Compose file adds a healthcheck on `/api/hello`.

Posts, uploads, users and settings live in the volume `ech0-data`, at `/app/data`. Back it up. Minimum recommended for the place `ech0`: 256 MB of memory and 1.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p ech0
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C ech0 cards-main/ech0
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the part after the app name in a hostname `edgible app list` prints. There are no secrets to fill: Start makes the card's token secret on the machine, and you choose the owner's password on Ech0's first page.

```bash
nano ech0/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py ech0
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file ech0/card.env -f ech0/docker-compose.yml pull
docker compose --env-file ech0/card.env -f ech0/docker-compose.yml up -d --wait
docker compose --env-file ech0/card.env -f ech0/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 47 MB, under a minute on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. ech0/card.env
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
  --name ech0 \
  --port "$ECH0_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up ech0

Publish put `ech0` on `org`, so only your Edgible organization reaches it. Open `https://<ech0 hostname>`, sign in with Edgible, and finish the app's own setup there. Its first page makes the owner: a username, an email (only an address on the account, so any will do) and a password from a password manager. Then, in its settings, turn off registration, so nobody else can make an account once it is public. The check below says `done` only when both are true.

When it is finished, this prints `done`:

```bash
set -a
. ech0/card.env
set +a
COMPOSE="docker compose --env-file ech0/card.env -f ech0/docker-compose.yml"
curl -fsS "http://127.0.0.1:$ECH0_PORT/api/init/status" | grep -q '"owner_exists":true' && curl -fsS "http://127.0.0.1:$ECH0_PORT/api/settings" | grep -q '"allow_register":false' && echo done
```

Then switch it to `none`. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update ech0 --auth-modes none
```

## Verify

`ech0` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<ech0 hostname>"
```

The public timeline, with no Edgible sign-in. Sign in as the owner you made in Set up to publish.

The rest of the setup is in the [Ech0 docs](https://github.com/lin-snow/Ech0).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete ech0 --yes
```

### 2. Stop

```bash
docker compose --env-file ech0/card.env -f ech0/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `ech0-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=ech0); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file ech0/card.env -f ech0/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf ech0
```
