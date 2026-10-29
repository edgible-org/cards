# frigate

## Why

A camera that records to the vendor's cloud charges a subscription, and shows your home to someone else's servers. [Frigate](https://frigate.video) records your cameras on a machine you own, finds people and cars in them with locally run detection, and shows live views, recordings and detections in its web interface. Through Edgible you can see it from anywhere.

## What

One app, `frigate`, on `org`: the camera footage is private, and only people in your Edgible organization sign in to see it. Frigate's port 5000 has no login of its own, so the card binds it to the machine's own address and lets Edgible's sign-in be the only way in. Do not move it to `none`. Frigate's phone and Home Assistant integrations call a different, authenticated port that this card does not publish. A small helper, `frigate-seed`, puts a starting `config.yml` into the volume once, with a placeholder camera and detection on the CPU. Your cameras must be reachable from this machine, on the same network. Detection on the CPU is slow for several cameras; a Coral or GPU needs devices the card does not pass in.

The config and database live in the volume `frigate-config`, the recordings and snapshots in `frigate-media`. Recordings grow until Frigate's retention removes them, so give the disk room. Minimum recommended for the place `frigate`: 2 GB of memory and 20 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p frigate
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C frigate cards-main/frigate
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `FRIGATE_PORT` only if 5000 is taken. Your cameras go in Frigate's config after the first start, as Verify says.

```bash
nano frigate/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py frigate
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file frigate/card.env -f frigate/docker-compose.yml pull
docker compose --env-file frigate/card.env -f frigate/docker-compose.yml up -d --wait
docker compose --env-file frigate/card.env -f frigate/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Frigate takes about a minute to be ready on first start.

### 5. Publish

```bash
set -euo pipefail
set -a
. frigate/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name frigate \
  --port "$FRIGATE_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`frigate` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<frigate hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Add your cameras: in the interface, open Settings, then the Config editor, and replace the `placeholder` camera with your cameras' stream addresses (the `rtsp://` address in each camera's settings), as Frigate's docs describe. Save and restart Frigate from the same page. Use a camera account made for Frigate, not your main one.

The rest of the setup is in the [Frigate documentation docs](https://docs.frigate.video).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete frigate --yes
```

### 2. Stop

```bash
docker compose --env-file frigate/card.env -f frigate/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=frigate); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file frigate/card.env -f frigate/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf frigate
```
