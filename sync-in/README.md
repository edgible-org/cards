# sync-in

## Why

You want your files on every computer and phone you use, shared with family or a team, without handing them to a cloud provider. [Sync-in](https://sync-in.com) is file storage with syncing, sharing, permissions and a web interface, plus a desktop client and a command-line client that keep a folder in step with the server. This card runs it on a machine you own.

## What

One Sync-in app and its MariaDB database. It is published on one hostname with auth mode `none`: the desktop and CLI sync clients call the same address as the web, and cannot get past an Edgible sign-in, so Sync-in's own login is the protection. Sync-in makes the admin at its first start, before anything is published: the admin adds family or team members in the app, and should check its settings that nobody else can register. Who sees which folder is set there, with spaces and permissions. If you only need the web, change the hostname to `org` after Publish with `edgible app update`.

The files are in the `sync-in-data` volume, the users and sharing in the database volume `sync-in-db-data`, and the card's passwords and keys in `sync-in-secrets`. Back up all three together. This is your files: a copy on the same machine is not a backup. Minimum recommended for the place `sync-in`: 1 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p sync-in
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C sync-in cards-main/sync-in
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. `SYNC_IN_ADMIN_USER` is the admin's name.

```bash
nano sync-in/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py sync-in
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml pull
docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml up -d --wait
docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Sync-in makes the admin at this first start, with the password the card made, so there is no setup page for a visitor to find.

### 5. Publish

```bash
set -euo pipefail
set -a
. sync-in/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name sync-in \
  --port "$SYNC_IN_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`sync-in` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<sync-in hostname>"
```

Answers with Sync-in itself, open to the internet, so its sign-in is the protection. Sign in as `SYNC_IN_ADMIN_USER` with the password the card made: run `docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml run --rm --no-deps sync-in-secrets show SYNC_IN_ADMIN_PASSWORD`, and change it in the app. For the desktop or CLI client, give it the same address and sign-in.

The rest of the setup is in the [Sync-in docs](https://sync-in.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete sync-in --yes
```

### 2. Stop

```bash
docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=sync-in); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file sync-in/card.env -f sync-in/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf sync-in
```
