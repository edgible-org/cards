# memos

## Why

You want private notes you can reach from any device, or shared notes for a family or a small team, written in markdown on a server you own. [Memos](https://usememos.com/) is a note app that keeps everything in one SQLite file, has a fast web interface, and works with phone apps.

## What

One Memos container, with its notes and uploads in one volume. It is published on one hostname with auth mode `none`: Memos' phone apps and the web call the same address and cannot get past an Edgible sign-in, so Memos' own login is the protection. `prepare.sh` makes the admin and closes self-registration before Publish, so nobody else can create an account; the admin adds family or team members under Settings, Members. If you only use the web and need no phone app, change the hostname to `org` after Publish with `edgible app update`.

The notes and uploads are in the `memos-data` volume; the admin's password is in `memos-secrets`. Minimum recommended for the place `memos`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p memos
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C memos cards-main/memos
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. `MEMOS_ADMIN_USER` is the admin's name.

```bash
nano memos/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py memos
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file memos/card.env -f memos/docker-compose.yml pull
docker compose --env-file memos/card.env -f memos/docker-compose.yml up -d --wait
docker compose --env-file memos/card.env -f memos/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `prepare.sh` makes the admin with the password the card made, and turns off sign-up, because a new Memos lets its first visitor become the admin.

```bash
sh memos/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the memos card: make the admin and close sign-up before Memos is public.
# A new Memos lets its first visitor register as the admin, and anyone register after.
# Run it after Start and before Publish, from the directory that holds memos/:
#   sh memos/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret memos-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps memos-secrets show MEMOS_ADMIN_PASSWORD)
B="http://127.0.0.1:$MEMOS_PORT"
H='Content-Type: application/json'
out=$(mktemp); trap 'rm -f "$out"' EXIT

signin() {
  curl -s -o "$out" -w '%{http_code}' -X POST "$B/api/v1/auth/signin" -H "$H" \
    -d "{\"passwordCredentials\":{\"username\":\"$MEMOS_ADMIN_USER\",\"password\":\"$1\"}}"
}

if [ "$(signin "$PASSWORD")" != 200 ]; then
  code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
    -d "{\"username\":\"$MEMOS_ADMIN_USER\",\"password\":\"$PASSWORD\",\"role\":\"ADMIN\"}")
  [ "$code" = 200 ] || { echo "making the admin answered $code"; exit 1; }
  [ "$(signin "$PASSWORD")" = 200 ] || { echo "the new admin cannot sign in"; exit 1; }
fi
token=$(sed -n 's/.*"accessToken" *: *"\([^"]*\)".*/\1/p' "$out" | head -n 1)
[ -n "$token" ] || { echo "no access token in the sign-in answer"; exit 1; }

# Close sign-up: further accounts are made by the admin, under Settings, Members.
code=$(curl -s -o /dev/null -w '%{http_code}' -X PATCH \
  "$B/api/v1/instance/settings/GENERAL?updateMask=general_setting.disallow_user_registration" \
  -H "$H" -H "Authorization: Bearer $token" \
  -d '{"name":"instance/settings/GENERAL","generalSetting":{"disallowUserRegistration":true}}')
[ "$code" = 200 ] || { echo "closing sign-up answered $code"; exit 1; }
echo "the admin exists and sign-up is closed; sign in as $MEMOS_ADMIN_USER with MEMOS_ADMIN_PASSWORD"
```

Sign in as the admin with the password from the `show` command in Verify, and change it under Settings. Add other people under Settings, Members.

### 5. Publish

```bash
set -euo pipefail
set -a
. memos/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name memos \
  --port "$MEMOS_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`memos` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<memos hostname>"
```

Answers with Memos itself, open to the internet, so the sign-in is the protection. Sign in as `MEMOS_ADMIN_USER` with the password `memos-secrets` made: run `docker compose --env-file memos/card.env -f memos/docker-compose.yml run --rm --no-deps memos-secrets show MEMOS_ADMIN_PASSWORD`. In the phone app, give it the same address and that sign-in.

The rest of the setup is in the [Memos docs](https://usememos.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete memos --yes
```

### 2. Stop

```bash
docker compose --env-file memos/card.env -f memos/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=memos); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file memos/card.env -f memos/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf memos
```
