# photoprism

## Why

You want your phone photos and your family's in one private place, searchable by face, place, and what is in them, without handing them to a cloud service. [PhotoPrism](https://photoprism.app) is a photo library that indexes pictures on a server you own and finds them by people, places, and labels. This card runs it on a machine you control, through Edgible, with its own sign-in.

## What

One app, `photoprism`, with its MariaDB database. It is published on one hostname with auth mode `none`: the web interface and the WebDAV address that phone apps such as PhotoSync upload to are the same address, and a phone app cannot get past an Edgible sign-in, so PhotoPrism's own login is the protection. PhotoPrism has no public sign-up: it makes one admin at its first start, from a password made on the machine, and you add family under Settings, Users. If you only browse from the web, or your photos are sensitive, change the hostname to `org` after Publish with `edgible app update`, and upload from home Wi-Fi or by copying files in, or do not publish it at all. Add disk encryption and an encrypted off-site backup of the volumes. Photos of patients, clients, or children carry legal duties: use this card as a prototype with consented or test photos only, and take real data to compliant hosting with advice.

The photos are in the volume `photoprism-originals`; the library's index, with faces, places and labels, is in `photoprism-db-data`; settings, sidecar files and thumbnails are in `photoprism-storage`; the passwords are in `photoprism-secrets`. The photos grow with your library, so give the machine room for it: the card's 5 GB is the application and its first data, not your photos. Minimum recommended for the place `photoprism`: 2 GB of memory and 5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p photoprism
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C photoprism cards-main/photoprism
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. `PHOTOPRISM_ADMIN_USER` is the admin's name.

```bash
nano photoprism/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py photoprism
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file photoprism/card.env -f photoprism/docker-compose.yml pull
docker compose --env-file photoprism/card.env -f photoprism/docker-compose.yml up -d --wait
docker compose --env-file photoprism/card.env -f photoprism/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. PhotoPrism makes the admin, with the password the card made, the first time it starts, so there is no setup page for a stranger to reach and no `prepare.sh`. The first start also prepares the index, so allow a minute or two before it is healthy.

### 5. Publish

```bash
set -euo pipefail
set -a
. photoprism/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name photoprism \
  --port "$PHOTOPRISM_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`photoprism` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<photoprism hostname>"
```

Answers with PhotoPrism's sign-in page, open to the internet, so the sign-in is the protection. Sign in as `PHOTOPRISM_ADMIN_USER` with the password `photoprism-secrets` made. To upload from a phone, add the WebDAV address `https://<photoprism hostname>/originals/` in a phone app, with that sign-in or, better, an app password made under Settings, Account.

The rest of the setup is in the [PhotoPrism user guide docs](https://docs.photoprism.app/user-guide/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete photoprism --yes
```

### 2. Stop

```bash
docker compose --env-file photoprism/card.env -f photoprism/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=photoprism); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file photoprism/card.env -f photoprism/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf photoprism
```
