# domoticz

## Why

Home automation is usually a vendor's app and cloud: each brand of light, plug and sensor has its own, and they stop working when the vendor's service does. [Domoticz](https://www.domoticz.com/) is one hub on a machine you own that monitors and switches lights, plugs, thermometers, energy and water meters and more, from many brands, with timers and rules, and keeps working with no cloud. This card runs it and makes it reachable from outside the home.

## What

One Domoticz container with its database in one volume, on two hostnames of the same process. `domoticz` is the web interface, on `org`, so only members of your Edgible organization reach it. `domoticz-app` is on `none`, because Domoticz's phone apps cannot pass an Edgible sign-in; Domoticz's own login is the protection there. A new Domoticz lets its first visitor make the admin, so Publish puts both on `org` until you have made it, in [Set up Domoticz](#6-set-up-domoticz). Use `domoticz` in a browser, and give `domoticz-app` only to the phone apps, or leave it unpublished if you need none. This card passes no USB devices to the container, so a USB radio such as a Z-Wave stick is out of reach; devices on the network (MQTT, Hue, Shelly, Tasmota and others) work. Domoticz runs as root in its image.

The database, plugins, scripts, backups and accounts are in the `domoticz-data` volume. Minimum recommended for the place `domoticz`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p domoticz
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C domoticz cards-main/domoticz
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Set `DOMOTICZ_TZ` to your time zone, for timers.

```bash
nano domoticz/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py domoticz
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml pull
docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml up -d --wait
docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Domoticz waits for its first visitor to make the admin, which you do after Publish, behind the Edgible sign-in.

### 5. Publish

```bash
set -euo pipefail
set -a
. domoticz/card.env
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
  --name domoticz \
  --port "$DOMOTICZ_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name domoticz-app \
  --port "$DOMOTICZ_APP_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `domoticz` and `domoticz-app`, both with `org` for now.

### 6. Set up Domoticz

A new Domoticz lets its first visitor make the admin account, and `domoticz-app` reaches the same Domoticz. So Publish put both on `org`: only your Edgible organization reaches them. Open `https://<domoticz hostname>`, sign in with Edgible, and make the admin in Domoticz's setup page. Use a strong password from a password manager: once `domoticz-app` is open, Domoticz's login is what protects it there. Add family members under Setup, Users, with the rights you want them to have.

When the admin exists and Domoticz asks for a sign-in, this prints `done`:

```bash
set -a
. domoticz/card.env
set +a
curl -s "http://127.0.0.1:$DOMOTICZ_PORT/json.htm?type=command&param=getsetuprequired" | grep -q '"SetupRequired"[[:space:]]*:[[:space:]]*false' && ! curl -s "http://127.0.0.1:$DOMOTICZ_PORT/json.htm?type=command&param=getusers" | grep -q '"status"[[:space:]]*:[[:space:]]*"OK"' && echo done
```

If the admin exists but nothing prints, Domoticz answers without a sign-in: check Setup, Settings, Local Networks, and do not open `domoticz-app` until it prints `done`.

Then switch `domoticz-app` to `none`, so the phone apps reach it; `domoticz` stays on `org`. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update domoticz-app --auth-modes none
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`domoticz` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<domoticz hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the address, sign in to Edgible, then to Domoticz as the admin you made in Set up.

`domoticz-app` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<domoticz-app hostname>"
```

Answers with Domoticz's own sign-in page, open to the internet, so its login is the protection. In the phone app, give it this address and the same sign-in.

The rest of the setup is in the [Domoticz wiki docs](https://wiki.domoticz.com/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete domoticz --yes
edgible app delete domoticz-app --yes
```

### 2. Stop

```bash
docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=domoticz); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf domoticz
```
