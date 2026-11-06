# langflow

## Why

Building an AI agent or a RAG app without code usually means a hosted builder that holds your documents and keys and charges by the seat. [Langflow](https://www.langflow.org) is a visual builder for agents and RAG apps that publishes each flow as an API, on a machine you own, with hosted or local models.

## What

One process on three hostnames. `langflow` is the builder, behind `org`, because it is an admin interface for people in your Edgible organization. `langflow-api` is where your apps call a published flow, behind `api-key`, because it is another machine calling an API. `langflow-hooks` takes webhook calls, on `none`, because the services that call a webhook cannot sign in to Edgible. All are port `7860` on the place `langflow`; list `langflow` first so `LANGFLOW_PORT` is named after it. Postgres runs beside it as `langflow-db`. The `langflow-hooks` hostname serves the whole process, so Langflow's own sign-in page is public too: automatic sign-in is off, the admin is made when Langflow first starts, and any other account made there stays inactive until the admin turns it on, so a stranger cannot get in. Flows can run code, so keep the builder on `org` and give nobody an account you would not give a shell.

Flows, components, API keys, accounts and run history live in the volume `langflow-db-data`. The key that encrypts the model keys you store in Langflow is in `langflow-secrets`: back them up together. Files and logs are in `langflow-data`. Minimum recommended for the place `langflow`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU. Minimum recommended for the place `langflow`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p langflow
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C langflow cards-main/langflow
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. There are no secrets to fill: Start makes them on the machine. Model keys you bring are added in Langflow's settings, not here.

```bash
nano langflow/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py langflow
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file langflow/card.env -f langflow/docker-compose.yml pull
docker compose --env-file langflow/card.env -f langflow/docker-compose.yml up -d --wait
docker compose --env-file langflow/card.env -f langflow/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The admin is made by this start: the user is `admin`, and the password is the secret `LANGFLOW_ADMIN_PASSWORD`, which `langflow-secrets` made on this machine. There is no first-visitor setup, so nothing needs doing before Publish. Show the password with `docker compose --env-file langflow/card.env -f langflow/docker-compose.yml run --rm --no-deps langflow-secrets show LANGFLOW_ADMIN_PASSWORD`. The first start takes a minute or two while the database is built.

### 5. Publish

```bash
set -euo pipefail
set -a
. langflow/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name langflow \
  --port "$LANGFLOW_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name langflow-api \
  --port "$LANGFLOW_PORT" \
  --protocol https \
  --auth-modes api-key \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name langflow-hooks \
  --port "$LANGFLOW_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`langflow` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<langflow hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The sign-in page loads for a member of your organization. Sign in as `admin` with the password above.

`langflow-api` uses `api-key`. Without a key, it answers `401`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<langflow-api hostname>"
```

Create an API key in Langflow, then call a flow at `/api/v1/run/<flow id>` with the key your Edgible organization issued for this hostname, and Langflow's key in `x-api-key`.

`langflow-hooks` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<langflow-hooks hostname>"
```

A webhook component's address is `/api/v1/webhook/<flow id>` on this hostname. A stranger can reach the sign-in page here but cannot make a working account.

The rest of the setup is in the [Langflow docs](https://docs.langflow.org).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete langflow --yes
edgible app delete langflow-api --yes
edgible app delete langflow-hooks --yes
```

### 2. Stop

```bash
docker compose --env-file langflow/card.env -f langflow/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=langflow); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file langflow/card.env -f langflow/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf langflow
```
