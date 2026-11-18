# activepieces

## Why

Connecting your apps, such as a Slack message for each new Trello card, usually means a Zapier subscription that holds your data and charges by the task. [Activepieces](https://www.activepieces.com) does the same with no-code flows, and has AI steps, on a machine you own.

## What

One process on two hostnames. `activepieces` is the flow editor, behind `org`, because it is an admin interface for people in your Edgible organization. `activepieces-hooks` takes webhook calls, on `none`, because the services that call a webhook (Stripe, GitHub, a form) cannot sign in to Edgible. Both are port `80` on the place `activepieces`; list `activepieces` first so `ACTIVEPIECES_PORT` is named after it. Postgres runs beside it as `activepieces-db`, and Redis, for the job queue, as `activepieces-redis`. Flows run without Activepieces' own sandbox (`AP_EXECUTION_MODE=UNSANDBOXED`), because the sandbox needs a privileged container; the editor being behind `org` is what keeps strangers from writing code steps. The `activepieces-hooks` hostname serves the whole process, so its sign-in page is public too. The first account to sign up becomes the admin, and sign-up closes after it, so both hostnames start on `org` while you sign up; then only `activepieces-hooks` opens, and the app's own password protects it. Point a service at `https://<activepieces-hooks hostname>/api/v1/webhooks/<flow id>`.

Flows, connections, runs and accounts live in the volume `activepieces-db-data`. The key that encrypts stored connections is in `activepieces-secrets`: back them up together. Minimum recommended for the place `activepieces`: 2 GB of memory and 4 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p activepieces
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C activepieces cards-main/activepieces
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. There are no secrets to fill: Start makes the card's keys on the machine, and you choose the admin's password when you sign up. Port 80 is the default; the check in How moves it if the machine uses it.

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

The first start downloads the app's images from the registries named in the Compose file: about 612 MB, a few minutes on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

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
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up activepieces

Publish put `activepieces` and `activepieces-hooks` on `org`, so only your Edgible organization reaches them. Open `https://<activepieces hostname>`, sign in with Edgible, and finish the app's own setup there. Sign up there as the first account, with your email and a password from a password manager: that makes you the admin, and sign-up closes after it. Once `activepieces-hooks` is open, Activepieces' login is what protects it.

When it is finished, this prints `done`:

```bash
set -a
. activepieces/card.env
set +a
COMPOSE="docker compose --env-file activepieces/card.env -f activepieces/docker-compose.yml"
curl -fsS "http://127.0.0.1:$ACTIVEPIECES_PORT/api/v1/flags" | grep -q '"USER_CREATED":true' && echo done
```

Then switch `activepieces-hooks` to `none`; `activepieces` stays on `org`. Until then they stay on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update activepieces-hooks --auth-modes none
```

## Verify

`activepieces` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<activepieces hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Sign in as the admin you made in Set up. The editor is behind the Edgible sign-in, so you reach it as a member of your organization.

`activepieces-hooks` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<activepieces-hooks hostname>"
```

The hostname answers with the app, and a stranger's sign-up on it is refused. A webhook flow's URL, shown in the editor, starts with this hostname.

The rest of the setup is in the [Activepieces docs](https://www.activepieces.com/docs).

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

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `activepieces-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

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
