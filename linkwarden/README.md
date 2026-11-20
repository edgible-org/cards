# linkwarden

## Why

Bookmarks scattered across browsers and phones, and pages that vanish after you saved them, are what a hosted read-later service solves, and then keeps. [Linkwarden](https://linkwarden.app) saves each link with a screenshot, a PDF and a readable copy of the page, files links in collections you can share with your team, and keeps all of it on a machine you own.

## What

One app, `linkwarden`, on `none`: its browser extension and phone app cannot get past an Edgible sign-in, and the web pages sit on the same hostname, so the app's own login is the protection. Sign-up is closed, so only the admin and the people the admin adds can get in. The admin is the first account: you make it yourself on Linkwarden's own sign-up page, which is open only while the app is behind the Edgible sign-in, in [Set up Linkwarden](#6-set-up-linkwarden). Two containers run it: Linkwarden, which also runs its page-archiving worker and a headless browser, and Postgres. Search is Linkwarden's built-in one; its optional Meilisearch index is left out.

The links are in the volume `linkwarden-db-data`. The saved screenshots, PDFs and page copies are in `linkwarden-data`. Both are irreplaceable, and so is `linkwarden-secrets`, which holds the passwords and the key that signs sessions. Minimum recommended for the place `linkwarden`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p linkwarden
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C linkwarden cards-main/linkwarden
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints and `ORG_LABEL` as the file says. Leave `LINKWARDEN_DISABLE_REGISTRATION` at `true`: Start opens sign-up only for its first run.

```bash
nano linkwarden/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py linkwarden
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml pull
LINKWARDEN_DISABLE_REGISTRATION=false docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml up -d --wait
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `LINKWARDEN_DISABLE_REGISTRATION=false` in front opens sign-up for this first run only, so you can make the first account in Set up; card.env keeps it closed.

### 5. Publish

```bash
set -euo pipefail
set -a
. linkwarden/card.env
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
  --name linkwarden \
  --port "$LINKWARDEN_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `linkwarden` with `org`.

### 6. Set up Linkwarden

Sign-up is open for now, so Publish put `linkwarden` on `org`: only your Edgible organization reaches it. Open `https://<linkwarden hostname>`, sign in with Edgible, and choose **Sign Up**. Make your account with a strong password from a password manager. The first account is the admin.

When it exists, this prints `done`:

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml exec -T linkwarden-db psql -U linkwarden -d linkwarden -tAc 'select count(*) from "User"' | grep -qvx 0 && echo done
```

Then start Linkwarden again with card.env as written, which closes sign-up. Your account and links stay.

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml up -d --wait
```

Then switch `linkwarden` to `none`, so its browser extension and phone app reach it. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update linkwarden --auth-modes none
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`linkwarden` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<linkwarden hostname>"
```

That prints `200`. The check proves a stranger cannot sign up, and that the admin signs in. Sign in at the hostname with the account you made in Set up, save a link, and open its saved copy. Add teammates under Admin Panel. The browser extension and phone app take the same address and the same login.

The rest of the setup is in the [Linkwarden docs](https://docs.linkwarden.app).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete linkwarden --yes
```

### 2. Stop

```bash
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `linkwarden-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=linkwarden); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file linkwarden/card.env -f linkwarden/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf linkwarden
```
