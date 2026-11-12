# seatsurfing

## Why

Members who book a court or a room, and customers who book an appointment, usually end up in a hosted booking service with a monthly fee per user or per booking. [Seatsurfing](https://seatsurfing.io) does the booking part: you set up spaces such as desks, rooms or courts, with the hours they can be booked, and people pick a free slot and book it. The spaces, the people and the bookings stay on a machine you own.

## What

One app, `seatsurfing`, on `none`, with Postgres beside it as `seatsurfing-db`. The people who book are members and customers, who are not in your Edgible organization, so `org` would lock them out. They sign in with the app's own accounts, and an admin adds each person (check after Publish that the sign-in page offers no registration), so members' contact details stay in the app. Seatsurfing's admin screens are on the same hostname, protected by the same sign-in, because the app serves both from one address. The image has no shell, so a one-shot `seatsurfing-shell` copies a small static shell into a volume for the card's secrets loader to use. It then exits. Payment is not part of Seatsurfing: it books places, it does not take money.

Spaces, accounts and bookings live in the volume `seatsurfing-db-data`. The database password, the key that encrypts sensitive fields and the admin's password are in `seatsurfing-secrets`, which the data needs, so back both up together. Minimum recommended for the place `seatsurfing`: 512 MB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p seatsurfing
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C seatsurfing cards-main/seatsurfing
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, `ORG_LABEL` to the label in your hostnames, and `SEATSURFING_ORG_NAME` to your club's or business's name. Fill the `SEATSURFING_SMTP_` lines with a mail server so invitations and password resets reach people. The database password, the encryption key and the admin's password need nothing: Start makes them on the machine.

```bash
nano seatsurfing/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py seatsurfing
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml pull
docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml up -d --wait
docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Seatsurfing makes its organization and one admin on its first start, so the admin has a password only you know before Publish: it is made on this machine, never the product's default. Show it, and keep it: `docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml run --rm seatsurfing-secrets show SEATSURFING_ADMIN_PASSWORD`.

### 5. Publish

```bash
set -euo pipefail
set -a
. seatsurfing/card.env
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
  --name seatsurfing \
  --port "$SEATSURFING_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`seatsurfing` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<seatsurfing hostname>"
```

Open the hostname and sign in as `admin@seatsurfing.local` with the password from Start. In the admin screens, at `/ui/admin/`, change that address to your own, create a location and a space, and add a member. Then sign in as the member in a private window at the hostname and book the space. Members cannot sign themselves up: check that the sign-in page offers no registration.

The rest of the setup is in the [Seatsurfing docs](https://seatsurfing.io/docs/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete seatsurfing --yes
```

### 2. Stop

```bash
docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=seatsurfing); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file seatsurfing/card.env -f seatsurfing/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf seatsurfing
```
