# hedgedoc

## Why

You want shared notes that several people edit at once, written in markdown on a server you own, for a family, a club committee or a small team, or just your own notes reachable from any browser. [HedgeDoc](https://hedgedoc.org/) is a realtime collaborative markdown editor, formerly CodiMD and HackMD CE, with live preview, sharing by link, slides, diagrams and note history.

## What

One HedgeDoc container with a PostgreSQL database, and the uploaded images in a volume. It is published on one hostname with auth mode `org`, because HedgeDoc is used in a browser and has no phone app that would need to get past an Edgible sign-in, so only members of your Edgible organisation reach it. HedgeDoc has its own accounts too (email and password), which is what gives each note an owner. Anonymous editing is off, new notes are editable by signed-in users only, and `prepare.sh` makes the first account before Publish. Family or club members who are not in your organisation cannot reach it this way; add them to the organisation, or use a different app.

The notes are in the `hedgedoc-db-data` volume, the uploaded images in `hedgedoc-uploads`, and the first account's password in `hedgedoc-secrets`. Minimum recommended for the place `hedgedoc`: 512 MB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p hedgedoc
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C hedgedoc cards-main/hedgedoc
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. `HEDGEDOC_ADMIN_EMAIL` is the first account's email. Set `HEDGEDOC_ALLOW_REGISTER=false` if you would rather add each account yourself.

```bash
nano hedgedoc/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py hedgedoc
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml pull
docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml up -d --wait
docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. HedgeDoc has no admin role and no setup page, so the accounts are whoever registers. `prepare.sh` makes the first account with the password the card made, before anything is published.

```bash
sh hedgedoc/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the hedgedoc card: make the first account before HedgeDoc is published.
# HedgeDoc has no admin role and no setup page; the accounts are whoever registers. Making the
# first one here, with the password the card made, means you are signed in before anyone else.
# Run it after Start and before Publish, from the directory that holds hedgedoc/:
#   sh hedgedoc/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# bin/manage_users reads the database from the environment, so it runs through the same loader
# as the app. It exits 2 when the account already exists, which is fine on a second run.
rc=0
$COMPOSE exec -T hedgedoc sh /run/card-secrets/.load sh -c '
  export CMD_DB_URL="postgres://hedgedoc:$HEDGEDOC_DB_PASSWORD@hedgedoc-db:5432/hedgedoc"
  exec node bin/manage_users --add "$1" --pass "$HEDGEDOC_ADMIN_PASSWORD"
' sh "$HEDGEDOC_ADMIN_EMAIL" || rc=$?
case "$rc" in 0|2) ;; *) echo "making the first account failed ($rc)"; exit 1 ;; esac
echo "the first account exists; sign in as $HEDGEDOC_ADMIN_EMAIL with HEDGEDOC_ADMIN_PASSWORD"
```

Show the first account's password on the machine with `docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml run --rm --no-deps hedgedoc-secrets show HEDGEDOC_ADMIN_PASSWORD`. With `HEDGEDOC_ALLOW_REGISTER=false`, add another account with `docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml exec hedgedoc sh /run/card-secrets/.load sh -c 'export CMD_DB_URL="postgres://hedgedoc:$HEDGEDOC_DB_PASSWORD@hedgedoc-db:5432/hedgedoc"; exec node bin/manage_users --add person@example.com'`, which asks for the password.

### 5. Publish

```bash
set -euo pipefail
set -a
. hedgedoc/card.env
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
  --name hedgedoc \
  --port "$HEDGEDOC_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`hedgedoc` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<hedgedoc hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Opening the address redirects to the Edgible sign-in, because the hostname is on `org`. Sign in to Edgible, then to HedgeDoc with the first account's email and password, and make a note.

The rest of the setup is in the [HedgeDoc docs](https://docs.hedgedoc.org).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete hedgedoc --yes
```

### 2. Stop

```bash
docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=hedgedoc); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file hedgedoc/card.env -f hedgedoc/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf hedgedoc
```
