# karakeep

## Why

Articles to read later, links from every browser and phone, and pages that vanish after you saved them are what a hosted bookmark service solves, and then keeps. [Karakeep](https://karakeep.app/) saves each link with a screenshot and a readable copy of the page, searches all of it, sorts it into lists and tags, and has a browser extension and phone apps. This card runs it on a machine you own, through Edgible.

## What

One app, `karakeep`, on `none`: its browser extension and phone apps cannot get past an Edgible sign-in, and the web pages sit on the same hostname, so Karakeep's own login is the protection. Sign-up is closed, so only the admin and the accounts the admin makes can get in. The admin is the first account: you make it yourself on Karakeep's own sign-up page, which is open only while the app is behind the Edgible sign-in, in [Set up Karakeep](#6-set-up-karakeep). Three containers run it: Karakeep, which also runs its page-saving worker, a headless Chrome for screenshots and page copies, and Meilisearch for search. The optional AI tagging is left off; set its key in Karakeep's own settings if you want it. If you only save from a browser at home, you can keep the hostname on `org` instead of the last step of Set up, or move it back later with `edgible app update karakeep --auth-modes org`; the extension and phone apps then stop working.

The bookmarks, the account and the saved page copies are in the volume `karakeep-data`. The search index in `karakeep-meili-data` is rebuilt from it, and the keys the card made are in `karakeep-secrets`. Copy `karakeep-data` and `karakeep-secrets`. Minimum recommended for the place `karakeep`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p karakeep
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C karakeep cards-main/karakeep
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the label in your hostnames. Leave `KARAKEEP_DISABLE_SIGNUPS` at `true`: Start opens sign-up only for its first run. Change `KARAKEEP_PORT` only if 3000 is taken. There are no passwords to fill: Start makes the card's keys on the machine.

```bash
nano karakeep/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py karakeep
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml pull
KARAKEEP_DISABLE_SIGNUPS=false docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml up -d --wait
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `KARAKEEP_DISABLE_SIGNUPS=false` in front opens sign-up for this first run only, so you can make the first account in Set up; card.env keeps it closed.

### 5. Publish

```bash
set -euo pipefail
set -a
. karakeep/card.env
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
  --name karakeep \
  --port "$KARAKEEP_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `karakeep` with `org`.

### 6. Set up Karakeep

Sign-up is open for now, so Publish put `karakeep` on `org`: only your Edgible organization reaches it. Open `https://<karakeep hostname>`, sign in with Edgible, and choose **Sign Up**. Make your account with your own email and a strong password from a password manager. Karakeep makes the first account the admin.

When it exists, this prints `done`:

```bash
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml exec -T karakeep node -e "process.exit(new (require('node:sqlite').DatabaseSync)('/data/db.db',{readOnly:true}).prepare('select count(*) n from user').get().n>0?0:1)" && echo done
```

Then start Karakeep again with card.env as written, which closes sign-up. Your account and bookmarks stay.

```bash
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml up -d --wait
```

Then switch `karakeep` to `none`, so its browser extension and phone apps reach it. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update karakeep --auth-modes none
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`karakeep` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<karakeep hostname>"
```

Answers with Karakeep itself, open to the internet, so the sign-in is the protection. Sign in with the account you made in Set up. In the extension or phone app, give it the same address and the same account. Add people under Admin Settings, Users.

The rest of the setup is in the [Karakeep docs](https://docs.karakeep.com).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete karakeep --yes
```

### 2. Stop

```bash
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `karakeep-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=karakeep); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file karakeep/card.env -f karakeep/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf karakeep
```
