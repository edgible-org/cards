# papra

## Why

Paper piles up: invoices, letters, contracts, warranties. You want to scan them once, file them, and find any of them by a word in the text, without handing the lot to a hosted service. [Papra](https://papra.app) is a minimalist, open-source document archive: you upload files, tag them, search inside them, and keep them in storage you own. This card runs it on a machine you own, through Edgible.

## What

One app, `papra`, on `org`, so only members of your Edgible organization reach it. Everyone who files or searches documents is a person in a browser, so the Edgible sign-in is the first door and Papra's own login the second. One container runs it, with its database and documents in one volume. People outside your organization cannot reach it, and Papra's sign-up page is only reachable through that sign-in. Papra has no admin to make: you register your own account on its first page, and anyone else in your organization can register too until you set `PAPRA_REGISTRATION=false` in `card.env` and run Start again. Papra keeps documents in organizations of its own, so use those, with invitations, to decide who sees which files. Papra holds documents that may be about money or health: keep backups encrypted, and follow the retention rules of your profession.

The database and the documents are in the volume `papra-data`, and the signing secret the card made is in `papra-secrets`. Copy both. Minimum recommended for the place `papra`: 512 MB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p papra
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C papra cards-main/papra
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Change `PAPRA_PORT` only if 1221 is taken. There are no passwords to fill: Start makes the card's signing secret on the machine, and you make your account on Papra's sign-up page.

```bash
nano papra/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py papra
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file papra/card.env -f papra/docker-compose.yml pull
docker compose --env-file papra/card.env -f papra/docker-compose.yml up -d --wait
docker compose --env-file papra/card.env -f papra/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. papra/card.env
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
  --name papra \
  --port "$PAPRA_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`papra` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<papra hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Answers with a redirect to the Edgible sign-in, so only your organization reaches it. After signing in with Edgible, register your own account on Papra's first page and upload a document.

The rest of the setup is in the [Papra docs](https://docs.papra.app).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete papra --yes
```

### 2. Stop

```bash
docker compose --env-file papra/card.env -f papra/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `papra-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=papra); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file papra/card.env -f papra/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf papra
```
