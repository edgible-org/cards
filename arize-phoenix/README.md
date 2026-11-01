# arize-phoenix

## Why

Once an AI app is live, you cannot see what it sends to the model, what comes back, or what it costs. Hosted tracing services take every prompt and response. [Arize Phoenix](https://arize.com/docs/phoenix) records OpenTelemetry traces, lets you evaluate prompts and models, and keeps the prompt logs in one container with a SQLite file on a machine you own.

## What

One process on two hostnames, both port `6006`. `arize-phoenix` is the dashboard, behind `org`, because a person in a browser reads the traces. `arize-phoenix-ingest` takes traces from your AI apps over OpenTelemetry HTTP (`/v1/traces`), on `api-key`, because it is another machine calling an API: make one key per app. Phoenix's own sign-in is off, since Edgible does it. Be aware that a key on the ingestion hostname reaches the whole Phoenix process, so give keys only to apps you trust. The gRPC port `4317` is not published. Prompts and responses are stored as sent: if they hold personal, health or client data, the logs are that data and follow its rules, so set `ARIZE_PHOENIX_RETENTION_DAYS` to keep them only as long as needed.

Every trace, span, prompt, dataset and eval is in the SQLite file in the volume `arize-phoenix-data`. Minimum recommended for the place `arize-phoenix`: 1 GB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p arize-phoenix
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C arize-phoenix cards-main/arize-phoenix
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `ARIZE_PHOENIX_PORT` only if 6006 is taken, and `ARIZE_PHOENIX_RETENTION_DAYS` to limit how long traces are kept.

```bash
nano arize-phoenix/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py arize-phoenix
```

It fills each empty secret and moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file arize-phoenix/card.env -f arize-phoenix/docker-compose.yml pull
docker compose --env-file arize-phoenix/card.env -f arize-phoenix/docker-compose.yml up -d --wait
docker compose --env-file arize-phoenix/card.env -f arize-phoenix/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. arize-phoenix/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name arize-phoenix \
  --port "$ARIZE_PHOENIX_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name arize-phoenix-ingest \
  --port "$ARIZE_PHOENIX_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`arize-phoenix` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<arize-phoenix hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The dashboard opens after Edgible's sign-in.

`arize-phoenix-ingest` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<arize-phoenix-ingest hostname>"
```

Make a key with `edgible app api-keys create --app arize-phoenix-ingest --name my-app`, and point your app's OpenTelemetry exporter at `https://<ingest hostname>/v1/traces` with the key in its headers. Its traces then appear in the dashboard.

The rest of the setup is in the [Phoenix docs](https://arize.com/docs/phoenix).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete arize-phoenix --yes
edgible app delete arize-phoenix-ingest --yes
```

### 2. Stop

```bash
docker compose --env-file arize-phoenix/card.env -f arize-phoenix/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=arize-phoenix); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file arize-phoenix/card.env -f arize-phoenix/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf arize-phoenix
```
