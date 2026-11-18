# home-assistant

## Why

Smart-home gear usually comes with a vendor's app and cloud: each brand of light, plug, thermostat and sensor has its own, and they stop working when the vendor's service does. [Home Assistant](https://home-assistant.io/) is one app on a machine you own that brings devices from thousands of brands together, with dashboards, automations and scenes, and keeps them working locally with no cloud. This card runs it and makes it reachable from outside the home.

## What

One Home Assistant container with its configuration and database in one volume, on two hostnames of the same process. `home-assistant` is the web interface, on `org`, so only members of your Edgible organization reach it. `home-assistant-app` is on `none`, because the Home Assistant companion phone apps cannot pass an Edgible sign-in; Home Assistant's own login is the protection there. A new Home Assistant lets its first visitor make the owner, so both hostnames start on `org` while you make the owner in Home Assistant's own onboarding; then only `home-assistant-app` opens. Use `home-assistant` in a browser, and give `home-assistant-app` only to the phone apps, or leave it unpublished if you use them only at home. A one-time container writes a first `configuration.yaml` that trusts the local proxy, only when the volume has none. This card uses neither the host network nor USB devices, so automatic discovery on the home network (mDNS and the like) and a USB radio such as a Zigbee or Z-Wave stick are out of reach; devices you add by address (MQTT, Hue, Shelly, Tasmota and many more) work. Home Assistant runs as root in its image.

The configuration, database, and every integration's settings are in the `home-assistant-config` volume. Minimum recommended for the place `home-assistant`: 1 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p home-assistant
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C home-assistant cards-main/home-assistant
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Set `HOME_ASSISTANT_TZ` to your time zone, for automations that run at a time of day. There are no passwords to fill: you make the owner in Home Assistant's onboarding.

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

The first start downloads the app's images from the registries named in the Compose file: about 1.3 GB, a few minutes on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. home-assistant/card.env
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
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up home-assistant

Publish put `home-assistant` and `home-assistant-app` on `org`, so only your Edgible organization reaches them. Open `https://<home-assistant hostname>`, sign in with Edgible, and finish the app's own setup there. Its onboarding asks for the owner's name, username and password, then your home's name, location and units, and whether to share analytics. Use a password manager for the password: once `home-assistant-app` is open, Home Assistant's login is what protects it.

When it is finished, this prints `done`:

```bash
set -a
. home-assistant/card.env
set +a
COMPOSE="docker compose --env-file home-assistant/card.env -f home-assistant/docker-compose.yml"
curl -fsS "http://127.0.0.1:$HOME_ASSISTANT_PORT/api/onboarding" | tr -d ' ' | grep -q '"step":"user","done":true' && echo done
```

Then switch `home-assistant-app` to `none`; `home-assistant` stays on `org`. Until then they stay on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update home-assistant-app --auth-modes none
```

## Verify

`home-assistant` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<home-assistant hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The first sign-in: open the address as an organization member, then sign in to Home Assistant as the owner you made in Set up.

`home-assistant-app` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<home-assistant-app hostname>"
```

The check signs in as the owner through this hostname, so it also proves a wrong password is refused. In the companion app, enter this hostname's address and sign in with the same account.

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
