# hi-events

## Why

Clubs, venues and small businesses that sell places at courts, rooms, classes or events want their own booking and ticketing page, without a platform taking a fee on every booking. [Hi.Events](https://hi.events) gives each event or session a public page where people pick a time or ticket, and gives organizers a dashboard for attendees, check-in and emails.

## What

One app, Hi.Events, with its Postgres database and a Redis queue, in one place. Its hostname uses auth mode `none`: the people who book are not in your Edgible organization, so the public pages must open for anyone. The organizer dashboard is on the same hostname and is protected by Hi.Events' own login; sign-up is closed once the organizer is made, so nobody else can create an account. Payments are optional and off here (free or pay-on-the-day bookings); online payment needs a Stripe account, set in the app's own settings. Set a mail server in card.env if people should get confirmation emails.

Bookings and accounts are in the `hi-events-db-data` volume; uploaded images are in `hi-events-storage`; `hi-events-redis-data` holds queued jobs only. Back up the first two. Minimum recommended for the place `hi-events`: 1 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p hi-events
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C hi-events cards-main/hi-events
```

### 2. Edit card.env

Set `DEVICE`, `ORG_LABEL` and `HI_EVENTS_ADMIN_EMAIL` (the organizer's email). Fill the `HI_EVENTS_SMTP_*` lines and set `HI_EVENTS_MAIL_MAILER=smtp` to send emails.

```bash
nano hi-events/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py hi-events
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml pull
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml up -d --wait
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Hi.Events lets the first visitor register, so sign-up is closed from the start and `prepare.sh` makes the organizer before anything is published.

```bash
sh hi-events/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the hi-events card: make the organizer account, then close sign-up.
# Run it after Start and before Publish, from the directory that holds hi-events/:
#   sh hi-events/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}
: "${HI_EVENTS_ADMIN_EMAIL:?set HI_EVENTS_ADMIN_EMAIL in card.env}"

# Open sign-up for the one request that makes the organizer, then close it again.
HI_EVENTS_DISABLE_REGISTRATION=false $COMPOSE up -d --wait hi-events
status=0
$COMPOSE exec -T -e ADMIN_EMAIL="$HI_EVENTS_ADMIN_EMAIL" hi-events sh -c '
  pw=$(cat /run/card-secrets/HI_EVENTS_ADMIN_PASSWORD)
  wget -q -O /dev/null --header="Content-Type: application/json" \
    --post-data="{\"first_name\":\"Organizer\",\"email\":\"$ADMIN_EMAIL\",\"password\":\"$pw\",\"password_confirmation\":\"$pw\",\"timezone\":\"UTC\"}" \
    http://127.0.0.1:80/api/auth/register
' || status=$?
$COMPOSE up -d --wait hi-events
if [ "$status" -ne 0 ]; then
  echo "Making the organizer failed (it may already exist): sign-up is closed again." >&2
  exit "$status"
fi
echo "Organizer $HI_EVENTS_ADMIN_EMAIL made. Show the password with:"
echo "  $COMPOSE run --rm --no-deps hi-events-secrets show HI_EVENTS_ADMIN_PASSWORD"
```

It prints the command that shows the organizer's password. Run it on the machine to sign in after Publish. Sign-up stays closed: more organizers are invited from inside the app.

### 5. Publish

```bash
set -euo pipefail
set -a
. hi-events/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name hi-events \
  --port "$HI_EVENTS_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`hi-events` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<hi-events hostname>"
```

The public page answers without a sign-in. Sign in at the same address with the organizer's email and the password from `prepare.sh`, then create your first event.

The rest of the setup is in the [Hi.Events docs](https://hi.events/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete hi-events --yes
```

### 2. Stop

```bash
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=hi-events); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf hi-events
```
