# keeper-sh

## Why

Calendars end up scattered: work on Outlook, family on Google, a shared one someone publishes as an iCal link, a CalDAV server at home. [Keeper.sh](https://keeper.sh/) pulls events from iCal/ICS links and CalDAV calendars and pushes them to other calendars, so everyone sees the same events, with an anonymised busy/free option for calendars you do not want to share in full. This card runs it on a machine you own, so the sync does not depend on a hosted service. It syncs calendars only, not contacts.

## What

One app, `keeper-sh`, on `none`. Its web interface, its sign-in with Google or Microsoft (when you configure them) and its MCP endpoint are called by browsers, by those providers' redirects and by other tools, none of which can get past Edgible's own sign-in, and a family or club is not in your Edgible organisation. Keeper's own accounts protect it, so limit who can sign up with `KEEPER_SH_SIGNUP_DOMAINS`. One container, from Keeper's standalone image, runs the web app, the API, the scheduler, the worker, Redis and PostgreSQL. Stored CalDAV passwords are encrypted with a key the card makes on the machine.

The accounts, calendar sources and sync state are the PostgreSQL data in the volume `keeper-sh-data`. The session secret and the encryption key are in `keeper-sh-secrets`: keep them with any backup, or the stored CalDAV passwords cannot be read. Minimum recommended for the place `keeper-sh`: 256 MB of memory and 1.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p keeper-sh
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C keeper-sh cards-main/keeper-sh
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. Set `KEEPER_SH_SIGNUP_DOMAINS` to the email domains allowed to make an account, or leave it empty to let anyone sign up. Change `KEEPER_SH_PORT` only if 8095 is taken. Google and Microsoft calendars need your own OAuth apps, which this card does not set up: iCal links and CalDAV work without them.

```bash
nano keeper-sh/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py keeper-sh
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file keeper-sh/card.env -f keeper-sh/docker-compose.yml pull
docker compose --env-file keeper-sh/card.env -f keeper-sh/docker-compose.yml up -d --wait
docker compose --env-file keeper-sh/card.env -f keeper-sh/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. keeper-sh/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name keeper-sh \
  --port "$KEEPER_SH_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`keeper-sh` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<keeper-sh hostname>"
```

The check proves the hostname answers with Keeper's page. Then open it, make an account, and add a calendar source and a destination.

The rest of the setup is in the [Keeper.sh docs](https://github.com/ridafkih/keeper.sh).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete keeper-sh --yes
```

### 2. Stop

```bash
docker compose --env-file keeper-sh/card.env -f keeper-sh/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=keeper-sh); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file keeper-sh/card.env -f keeper-sh/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf keeper-sh
```
