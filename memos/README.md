# memos

## Why

You want private notes you can reach from any device, or shared notes for a family or a small team, written in markdown on a server you own. [Memos](https://usememos.com/) is a note app that keeps everything in one SQLite file, has a fast web interface, and works with phone apps.

## What

One Memos container, with its notes and uploads in one volume. It is published on one hostname with auth mode `none`: Memos' phone apps and the web call the same address and cannot get past an Edgible sign-in, so Memos' own login is the protection. A new Memos lets its first visitor register as the admin, and anyone register after, so the card publishes it on `org` first: only your Edgible organization reaches it while you make the admin and close sign-up. Then you open it to everyone, and the admin adds family or team members under Settings, Members. If you only use the web and need no phone app, leave it on `org` instead of opening it.

The notes and uploads are in the `memos-data` volume. Minimum recommended for the place `memos`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p memos
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C memos cards-main/memos
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. There are no passwords to fill: you make the admin on Memos's first page.

```bash
nano memos/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py memos
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file memos/card.env -f memos/docker-compose.yml pull
docker compose --env-file memos/card.env -f memos/docker-compose.yml up -d --wait
docker compose --env-file memos/card.env -f memos/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 25 MB, under a minute on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. memos/card.env
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
  --name memos \
  --port "$MEMOS_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up memos

Publish put `memos` on `org`, so only your Edgible organization reaches it. Open `https://<memos hostname>`, sign in with Edgible, and finish the app's own setup there. Its first page makes the admin: a username and a password from a password manager. Then, in Settings, turn on the setting that disallows user registration, so nobody else can make an account once it is public. The check below says `done` only when both are true.

When it is finished, this prints `done`:

```bash
set -a
. memos/card.env
set +a
COMPOSE="docker compose --env-file memos/card.env -f memos/docker-compose.yml"
curl -fsS "http://127.0.0.1:$MEMOS_PORT/api/v1/instance/profile" | grep -q '"admin"' && curl -fsS "http://127.0.0.1:$MEMOS_PORT/api/v1/instance/settings/GENERAL" | grep -q '"disallowUserRegistration":true' && echo done
```

Then switch it to `none`. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update memos --auth-modes none
```

## Verify

`memos` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<memos hostname>"
```

Answers with Memos itself, open to the internet, so the sign-in is the protection. In the phone app, give it the same address and the admin you made in Set up.

The rest of the setup is in the [Memos docs](https://usememos.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete memos --yes
```

### 2. Stop

```bash
docker compose --env-file memos/card.env -f memos/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=memos); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file memos/card.env -f memos/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf memos
```
