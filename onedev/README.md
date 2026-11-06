# onedev

## Why

Code, reviews and CI usually live on someone else's forge. [OneDev](https://onedev.io) is a Git forge with pull requests and code review, issues, and built-in CI/CD, that runs on a machine you own.

## What

One process on two hostnames, on the place `onedev`. `onedev` is the web, the API, and Git over HTTPS. `onedev-ssh` is Git over SSH, a TCP app on port `22611`, from the range `20000` to `29999` that TCP apps use.

Both are on `none`, deliberately. `git` over HTTPS, build agents, API tokens and webhooks cannot get past an Edgible sign-in, so `org` would break them. OneDev's own protections take its place: self-registration is off and anonymous access is off, so only the admin adds people; and the admin is made at the first start from generated settings, so no setup page is ever served. The card does not mount the Docker socket, so OneDev's Docker-based job executors are not set up here: add a separate agent on a machine you trust for CI.

OneDev shows its addresses in clone URLs, so its server URL is `https://onedev.<ORG_LABEL>.<EDGIBLE_DOMAIN>` (or `ONEDEV_URL`), and SSH clones use `onedev-ssh.<ORG_LABEL>.<EDGIBLE_DOMAIN>` on port `22611`. Postgres runs beside it as `onedev-db`. The images are `1dev/server:17.1.2` and `postgres:17.11-alpine`.

Repositories, build files and settings live in the volume `onedev-data`, and users, issues and pull requests in `onedev-db-data`. The generated passwords are in `onedev-secrets`. Minimum recommended for the place `onedev`: 2 GB of memory and 3 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p onedev
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C onedev cards-main/onedev
```

### 2. Edit card.env

Set `ORG_LABEL`, and `ONEDEV_ADMIN_EMAIL` to your own address. The administrator is the user `admin`.

```bash
nano onedev/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py onedev
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file onedev/card.env -f onedev/docker-compose.yml pull
docker compose --env-file onedev/card.env -f onedev/docker-compose.yml up -d --wait
docker compose --env-file onedev/card.env -f onedev/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

Before publishing, close self-registration. OneDev lets anyone make an account by default, and this hostname is public:

```bash
sh onedev/prepare.sh
```

[prepare.sh](prepare.sh) is:

```sh
#!/bin/sh
# Prepare for the onedev card: close self-registration and anonymous access before anything is public.
# OneDev's defaults let anyone on a public hostname make an account. The admin is made at first start
# (initial_user in the Compose file). Run this after Start and before Publish, from the directory
# that holds onedev/:
#   sh onedev/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The card made this password on this machine at Start (onedev-secrets).
ONEDEV_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps onedev-secrets show ONEDEV_ADMIN_PASSWORD)

# Through OneDev's own API, from inside its container. Each step says why when it fails.
$COMPOSE exec -T -e AUTH="admin:$ONEDEV_ADMIN_PASSWORD" onedev bash -c '
set -eu
U=http://127.0.0.1:6610/~api/settings/security
# The container is healthy before OneDev has finished making the admin, so wait for the login to work.
cur=
for _ in $(seq 36); do
  cur=$(curl -fsS -u "$AUTH" "$U" 2>/dev/null) && break
  sleep 5
done
[ -n "$cur" ] || { echo "the admin could not sign in after three minutes" >&2; exit 1; }
new=$(printf "%s" "$cur" | sed -E "s/(\"enableSelfRegister\" *: *)true/\1false/; s/(\"enableAnonymousAccess\" *: *)true/\1false/")
printf "%s" "$new" | curl -fsS -u "$AUTH" -X POST -H "Content-Type: application/json" -d @- "$U" >/dev/null \
  || { echo "could not save the security settings" >&2; exit 1; }
now=$(curl -fsS -u "$AUTH" "$U") || { echo "could not read the settings after saving them" >&2; exit 1; }
printf "%s" "$now" | grep -Eq "\"enableSelfRegister\" *: *false" || { echo "self-registration is still on" >&2; exit 1; }
printf "%s" "$now" | grep -Eq "\"enableAnonymousAccess\" *: *false" || { echo "anonymous access is still on" >&2; exit 1; }
'
echo "self-registration and anonymous access are off; sign in as admin"
```

It prints `self-registration and anonymous access are off; sign in as admin`. It waits up to three minutes for OneDev to finish making the admin. The admin is `admin`, with the password the card made.

### 5. Publish

```bash
set -euo pipefail
set -a
. onedev/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name onedev \
  --port "$ONEDEV_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name onedev-ssh \
  --port "$ONEDEV_SSH_PORT" \
  --protocol tcp \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`onedev` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<onedev hostname>"
```

The web answers without an Edgible sign-in. Sign in as `admin` with the password shown by `docker compose --env-file card.env -f docker-compose.yml run --rm --no-deps onedev-secrets show ONEDEV_ADMIN_PASSWORD`, then add people under Administration, Users.

`onedev-ssh` is a TCP app on port `22611`, with no auth mode.

The SSH port accepts a connection. Add an SSH key in your OneDev profile, then clone over SSH.

The rest of the setup is in the [OneDev docs](https://docs.onedev.io).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete onedev --yes
edgible app delete onedev-ssh --yes
```

### 2. Stop

```bash
docker compose --env-file onedev/card.env -f onedev/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=onedev); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file onedev/card.env -f onedev/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf onedev
```
