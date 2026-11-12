# activepieces

## Why

Connecting your apps, such as a Slack message for each new Trello card, usually means a Zapier subscription that holds your data and charges by the task. [Activepieces](https://www.activepieces.com) does the same with no-code flows, and has AI steps, on a machine you own.

## What

One process on two hostnames. `activepieces` is the flow editor, behind `org`, because it is an admin interface for people in your Edgible organization. `activepieces-hooks` takes webhook calls, on `none`, because the services that call a webhook (Stripe, GitHub, a form) cannot sign in to Edgible. Both are port `80` on the place `activepieces`; list `activepieces` first so `ACTIVEPIECES_PORT` is named after it. Postgres runs beside it as `activepieces-db`, and Redis, for the job queue, as `activepieces-redis`. Flows run without Activepieces' own sandbox (`AP_EXECUTION_MODE=UNSANDBOXED`), because the sandbox needs a privileged container; the editor being behind `org` is what keeps strangers from writing code steps. The `activepieces-hooks` hostname serves the whole process, so its sign-in page is public too. Start makes the admin before anything is published, and the app's own password protects it. Point a service at `https://<activepieces-hooks hostname>/api/v1/webhooks/<flow id>`.

Flows, connections, runs and accounts live in the volume `activepieces-db-data`. The key that encrypts stored connections is in `activepieces-secrets`: back them up together. Minimum recommended for the place `activepieces`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p activepieces
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C activepieces cards-main/activepieces
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. There are no secrets to fill: Start makes them on the machine. Port 80 is the default; the check in How moves it if the machine uses it.

```bash
nano activepieces/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py activepieces
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml pull
docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml up -d --wait
docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `prepare.sh` makes the admin, `admin@example.com`, with the password `activepieces-secrets` made, so no sign-up page is ever public. The first start takes a minute while the database is built.

```bash
sh activepieces/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the activepieces card: make the admin before the sign-up page is public.
# The first person to sign up becomes the platform's admin, so it is done here, not by a visitor.
# Run it after Start and before Publish, from the directory that holds activepieces/:
#   sh activepieces/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The password is the human secret activepieces-secrets made on this machine.
ACTIVEPIECES_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps activepieces-secrets show ACTIVEPIECES_ADMIN_PASSWORD)

curl -fsS -X POST "http://127.0.0.1:$ACTIVEPIECES_PORT/api/v1/authentication/sign-up" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$ACTIVEPIECES_ADMIN_PASSWORD\",\"firstName\":\"Admin\",\"lastName\":\"Admin\",\"trackEvents\":false,\"newsLetter\":false}" >/dev/null
echo "admin@example.com is the admin, with the password ACTIVEPIECES_ADMIN_PASSWORD"
```

It prints the name of the secret holding the admin's password. Show it with the command in What.

### 5. Publish

```bash
set -euo pipefail
set -a
. activepieces/card.env
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
  --name activepieces \
  --port "$ACTIVEPIECES_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name activepieces-hooks \
  --port "$ACTIVEPIECES_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`activepieces` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<activepieces hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in as `admin@example.com` with the admin password. The editor is behind the Edgible sign-in, so you reach it as a member of your organization.

`activepieces-hooks` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<activepieces-hooks hostname>"
```

The hostname answers with the app, and a stranger's sign-up on it is refused. A webhook flow's URL, shown in the editor, starts with this hostname.

The rest of the setup is in the [Activepieces docs docs](https://www.activepieces.com/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete activepieces --yes
edgible app delete activepieces-hooks --yes
```

### 2. Stop

```bash
docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=activepieces); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf activepieces
```
