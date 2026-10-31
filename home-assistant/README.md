# home-assistant

## Why

Smart-home gear usually comes with a vendor's app and cloud: each brand of light, plug, thermostat and sensor has its own, and they stop working when the vendor's service does. [Home Assistant](https://home-assistant.io/) is one app on a machine you own that brings devices from thousands of brands together, with dashboards, automations and scenes, and keeps them working locally with no cloud. This card runs it and makes it reachable from outside the home.

## What

One Home Assistant container with its configuration and database in one volume, on two hostnames of the same process. `home-assistant` is the web interface, on `org`, so only members of your Edgible organization reach it. `home-assistant-app` is on `none`, because the Home Assistant companion phone apps cannot pass an Edgible sign-in; Home Assistant's own login is the protection there, and `prepare.sh` makes the owner account before Publish, so nobody else can. Use `home-assistant` in a browser, and give `home-assistant-app` only to the phone apps, or leave it unpublished if you use them only at home. A one-time container writes a first `configuration.yaml` that trusts the local proxy, only when the volume has none. This card uses neither the host network nor USB devices, so automatic discovery on the home network (mDNS and the like) and a USB radio such as a Zigbee or Z-Wave stick are out of reach; devices you add by address (MQTT, Hue, Shelly, Tasmota and many more) work. Home Assistant runs as root in its image.

The configuration, database, and every integration's settings are in the `home-assistant-config` volume; the admin's password is in `home-assistant-secrets`. Minimum recommended for the place `home-assistant`: 1 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p home-assistant
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C home-assistant cards-main/home-assistant
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Set `HOME_ASSISTANT_TZ` to your time zone, for automations that run at a time of day. `HOME_ASSISTANT_ADMIN_USER` is the owner's name.

```bash
nano home-assistant/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py home-assistant
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml pull
docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml up -d --wait
docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

```bash
sh home-assistant/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the home-assistant card: make the admin before Home Assistant is public.
# A new Home Assistant lets its first visitor create the owner account.
# Run it after Start and before Publish, from the directory that holds home-assistant/:
#   sh home-assistant/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret home-assistant-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps home-assistant-secrets show HOME_ASSISTANT_ADMIN_PASSWORD)
B="http://127.0.0.1:$HOME_ASSISTANT_PORT"
out=$(mktemp); trap 'rm -f "$out"' EXIT

curl -fsS "$B/api/onboarding" -o "$out"
if tr -d ' \n' < "$out" | grep -q '"step":"user","done":false'; then
  curl -fsS -X POST "$B/api/onboarding/users" -o "$out" -H 'Content-Type: application/json' \
    -d "{\"client_id\":\"$B/\",\"name\":\"$HOME_ASSISTANT_ADMIN_USER\",\"username\":\"$HOME_ASSISTANT_ADMIN_USER\",\"password\":\"$PASSWORD\",\"language\":\"en\"}" \
    || { echo "making the admin failed"; exit 1; }
fi

# Fail closed: a caller with no sign-in, as Edgible's gateway is to Home Assistant, must get nothing.
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/")
if [ "$code" != 401 ]; then
  echo "Home Assistant answered $code to a caller with no sign-in; do not publish it."
  exit 1
fi
echo "the admin exists and Home Assistant asks for a sign-in; sign in as $HOME_ASSISTANT_ADMIN_USER with HOME_ASSISTANT_ADMIN_PASSWORD"
```

Home Assistant's remaining first-run questions (home name, location, analytics) are asked at your first sign-in.

### 5. Publish

```bash
set -euo pipefail
set -a
. home-assistant/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name home-assistant \
  --port "$HOME_ASSISTANT_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name home-assistant-app \
  --port "$HOME_ASSISTANT_APP_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`home-assistant` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<home-assistant hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The first sign-in: open the address as an organization member, then sign in to Home Assistant as `HOME_ASSISTANT_ADMIN_USER` with the password `prepare.sh` made. Change it in your profile.

`home-assistant-app` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<home-assistant-app hostname>"
```

The check signs in as the admin through this hostname, so it also proves a wrong password is refused. In the companion app, enter this hostname's address and sign in with the same account.

The rest of the setup is in the [Home Assistant docs](https://www.home-assistant.io/docs/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete home-assistant --yes
edgible app delete home-assistant-app --yes
```

### 2. Stop

```bash
docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=home-assistant); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf home-assistant
```
