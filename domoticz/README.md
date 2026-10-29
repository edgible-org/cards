# domoticz

## Why

Home automation is usually a vendor's app and cloud: each brand of light, plug and sensor has its own, and they stop working when the vendor's service does. [Domoticz](https://www.domoticz.com/) is one hub on a machine you own that monitors and switches lights, plugs, thermometers, energy and water meters and more, from many brands, with timers and rules, and keeps working with no cloud. This card runs it and makes it reachable from outside the home.

## What

One Domoticz container with its database in one volume, on two hostnames of the same process. `domoticz` is the web interface, on `org`, so only members of your Edgible organization reach it. `domoticz-app` is on `none`, because Domoticz's phone apps cannot pass an Edgible sign-in; Domoticz's own login is the protection there, and `prepare.sh` makes the admin before Publish, so nobody else can. Use `domoticz` in a browser, and give `domoticz-app` only to the phone apps, or leave it unpublished if you need none. This card passes no USB devices to the container, so a USB radio such as a Z-Wave stick is out of reach; devices on the network (MQTT, Hue, Shelly, Tasmota and others) work. Domoticz runs as root in its image.

The database, plugins, scripts and backups are in the `domoticz-data` volume; the admin's password is in `domoticz-secrets`. Minimum recommended for the place `domoticz`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p domoticz
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C domoticz cards-main/domoticz
```

### 2. Edit card.env

Set `DEVICE` and `ORG_LABEL`. Set `DOMOTICZ_TZ` to your time zone, for timers. `DOMOTICZ_ADMIN_USER` is the admin's name.

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

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

```bash
sh domoticz/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the domoticz card: make the admin before Domoticz is public.
# A new Domoticz lets its first visitor create the admin account.
# Run it after Start and before Publish, from the directory that holds domoticz/:
#   sh domoticz/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret domoticz-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps domoticz-secrets show DOMOTICZ_ADMIN_PASSWORD)
B="http://127.0.0.1:$DOMOTICZ_PORT/json.htm"
out=$(mktemp); trap 'rm -f "$out"' EXIT

# Domoticz takes the password as its MD5 hash.
if command -v md5sum >/dev/null 2>&1; then
  HASH=$(printf %s "$PASSWORD" | md5sum | cut -d' ' -f1)
else
  HASH=$(printf %s "$PASSWORD" | md5 -q)
fi

curl -fsS "$B?type=command&param=getsetuprequired" -o "$out"
if grep -Eq '"SetupRequired" *: *true' "$out"; then
  curl -fsS -G "$B" -o "$out" --data-urlencode type=command --data-urlencode param=setupwizardcreateadmin \
    --data-urlencode "username=$DOMOTICZ_ADMIN_USER" --data-urlencode "password=$HASH"
  grep -Eq '"status" *: *"OK"' "$out" || { echo "making the admin failed: $(cat "$out")"; exit 1; }
fi

# Fail closed: a caller with no sign-in, as Edgible's gateway is to Domoticz, must get nothing.
curl -s "$B?type=command&param=getusers" -o "$out" || true
if grep -Eq '"status" *: *"OK"' "$out"; then
  echo "Domoticz answers without a sign-in; do not publish it. Check Setup, Settings, Local Networks."
  exit 1
fi
echo "the admin exists and Domoticz asks for a sign-in; sign in as $DOMOTICZ_ADMIN_USER with DOMOTICZ_ADMIN_PASSWORD"
```

Sign in as the admin with the password from the `show` command in Verify, and change it under Setup, Users. Add family members there too, with the rights you want them to have.

### 5. Publish

```bash
set -euo pipefail
set -a
. domoticz/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
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
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`domoticz` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<domoticz hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the address, sign in to Edgible, then to Domoticz as `DOMOTICZ_ADMIN_USER` with the password `domoticz-secrets` made: run `docker compose --env-file domoticz/card.env -f domoticz/docker-compose.yml run --rm --no-deps domoticz-secrets show DOMOTICZ_ADMIN_PASSWORD`.

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
