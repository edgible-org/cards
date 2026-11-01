# passbolt

## Why

A team that keeps its passwords in a spreadsheet, or one shared login, has no way to share a password with only the people who need it. [Passbolt](https://www.passbolt.com) is a password manager built for teams and families: each password is encrypted to its readers, shared with people or groups, and read through a browser extension or phone app. This card runs it on a machine you control, through Edgible.

## What

One app, `passbolt`, on `none`, with MariaDB beside it. The browser extension and the phone app cannot pass an Edgible sign-in, so the hostname is open and Passbolt's own sign-in protects it: each person signs in with their own key and passphrase, and nobody can register themselves (`PASSBOLT_REGISTRATION_PUBLIC` is off), so only the admin's invitations make accounts. Turn on two-factor for every person in Passbolt's settings, and for anything sensitive require it. The server's key and the sign-in token key live in their own volumes.

The database is in `passbolt-db-data`, the server's GPG key in `passbolt-gpg` and its token key in `passbolt-jwt`. Keep all three together in a backup, with `card.env`: without the GPG volume nobody can sign in. Passwords are encrypted to each person's own key, so a backup does not hold them readable, and a lost passphrase and recovery kit cannot be undone by anyone. Minimum recommended for the place `passbolt`: 1 GB of memory and 3 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p passbolt
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C passbolt cards-main/passbolt
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, `ORG_LABEL` to the part of a hostname after the app name, and `PASSBOLT_ADMIN_EMAIL` to an address you can read. To invite people, Passbolt has to send mail: set the `PASSBOLT_SMTP_*` lines to your mail provider's settings. Change `PASSBOLT_PORT` only if 8086 is taken.

```bash
nano passbolt/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py passbolt
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file passbolt/card.env -f passbolt/docker-compose.yml pull
docker compose --env-file passbolt/card.env -f passbolt/docker-compose.yml up -d --wait
docker compose --env-file passbolt/card.env -f passbolt/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Here the first start makes the server's key and runs the database migrations, which takes a minute or two.

```bash
sh passbolt/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the passbolt card: make the first admin, so no one else can claim it once it is public.
# Run it after Start and before Publish, from the directory that holds passbolt/:
#   sh passbolt/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

: "${PASSBOLT_ADMIN_EMAIL:?set PASSBOLT_ADMIN_EMAIL in card.env}"

# Prints a one-time link that sets up the admin's key and passphrase in the browser extension.
# exec does not pass through the entrypoint, so it reads the database password itself.
$COMPOSE exec -T -e PASSBOLT_ADMIN_EMAIL="$PASSBOLT_ADMIN_EMAIL" passbolt sh -c \
  'DATASOURCES_DEFAULT_PASSWORD=$(cat /run/card-secrets/PASSBOLT_DB_PASSWORD) exec /usr/share/php/passbolt/bin/cake passbolt register_user -u "$PASSBOLT_ADMIN_EMAIL" -f Admin -l User -r admin'
```

It prints a one-time link. Open it, after Publish, in a browser with the Passbolt extension, and choose the admin's passphrase there. Save the recovery kit it offers: it is the only way back if the passphrase is lost. The link is a secret until it is used.

### 5. Publish

```bash
set -euo pipefail
set -a
. passbolt/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name passbolt \
  --port "$PASSBOLT_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`passbolt` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<passbolt hostname>"
```

Open the setup link `prepare.sh` printed to make the admin, then sign in. Check that registering a new account on the sign-in page is not offered. Test a backup before you rely on it: ask who will check that it restores.

The rest of the setup is in the [Passbolt help docs](https://www.passbolt.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete passbolt --yes
```

### 2. Stop

```bash
docker compose --env-file passbolt/card.env -f passbolt/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=passbolt); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file passbolt/card.env -f passbolt/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf passbolt
```
