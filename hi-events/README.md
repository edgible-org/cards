# hi-events

## Why

Clubs, venues and small businesses that sell places at courts, rooms, classes or events want their own booking and ticketing page, without a platform taking a fee on every booking. [Hi.Events](https://hi.events) gives each event or session a public page where people pick a time or ticket, and gives organizers a dashboard for attendees, check-in and emails.

## What

One app, Hi.Events, with its Postgres database and a Redis queue, in one place. Its hostname uses auth mode `none`: the people who book are not in your Edgible organization, so the public pages must open for anyone. The organizer dashboard is on the same hostname and is protected by Hi.Events' own login; sign-up is closed once the organizer is made, so nobody else can create an account. You make the organizer's account yourself on Hi.Events' own sign-up page, which is open only while the app is behind the Edgible sign-in, in [Set up Hi.Events](#6-set-up-hievents). Payments are optional and off here (free or pay-on-the-day bookings); online payment needs a Stripe account, set in the app's own settings. Set a mail server in card.env if people should get confirmation emails.

Bookings and accounts are in the `hi-events-db-data` volume; uploaded images are in `hi-events-storage`; `hi-events-redis-data` holds queued jobs only. Back up the first two. Minimum recommended for the place `hi-events`: 1 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p hi-events
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C hi-events cards-main/hi-events
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Leave `HI_EVENTS_DISABLE_REGISTRATION` at `true`: Start opens sign-up only for its first run. Fill the `HI_EVENTS_SMTP_*` lines and set `HI_EVENTS_MAIL_MAILER=smtp` to send emails.

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
HI_EVENTS_DISABLE_REGISTRATION=false docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml up -d --wait
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `HI_EVENTS_DISABLE_REGISTRATION=false` in front opens sign-up for this first run only, so you can make the organizer's account in Set up; card.env keeps it closed.

### 5. Publish

```bash
set -euo pipefail
set -a
. hi-events/card.env
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
  --name hi-events \
  --port "$HI_EVENTS_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `hi-events` with `org`.

### 6. Set up Hi.Events

Sign-up is open for now, so Publish put `hi-events` on `org`: only your Edgible organization reaches it. Open `https://<hi-events hostname>`, sign in with Edgible, choose **Register**, and make the organizer's account with your own email and a strong password from a password manager.

When it exists, this prints `done`:

```bash
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml exec -T hi-events-db psql -U hievents -d hievents -tAc 'select count(*) from users' | grep -qvx 0 && echo done
```

Then start Hi.Events again with card.env as written, which closes sign-up. Your account stays.

```bash
docker compose --env-file hi-events/card.env -f hi-events/docker-compose.yml up -d --wait
```

Then switch `hi-events` to `none`, so the people who book reach its public pages. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update hi-events --auth-modes none
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`hi-events` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<hi-events hostname>"
```

The public page answers without a sign-in. Sign in at the same address with the organizer's account you made in Set up, then create your first event. Invite more organizers from inside the app.

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
