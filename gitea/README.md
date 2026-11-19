# gitea

## Why

Code, issues and reviews usually live on someone else's forge. [Gitea](https://about.gitea.com) is a light, complete Git forge (repositories, issues, pull requests, packages, and CI with its runner) that runs on a machine you own.

## What

One process on two hostnames, on the place `gitea`. `gitea` is the web, the API, and Git over HTTPS. `gitea-ssh` is Git over SSH, a TCP app on port `22222`, from the range `20000` to `29999` that TCP apps use.

Both are on `none`, deliberately. `git` over HTTPS, a CI runner, API tokens and webhooks cannot get past an Edgible sign-in, so `org` would break them. Gitea's own protections take its place: registration is off, so only the admin adds people; and `gitea` stays behind the Edgible sign-in until you have made the admin in Gitea's install page ([Set up Gitea](#6-set-up-gitea)), which Gitea then locks.

Gitea shows its addresses in clone URLs, so `ROOT_URL` is `https://gitea.<ORG_LABEL>.<EDGIBLE_DOMAIN>` (or `GITEA_URL`), and SSH clones use `gitea-ssh.<ORG_LABEL>.<EDGIBLE_DOMAIN>` on port `22222`. Postgres runs beside it as `gitea-db`. The images are `gitea/gitea:28.1.0` and `postgres:17.11-alpine`.

To use it in a card, copy the `gitea-secrets`, `gitea` and `gitea-db` services, the three volumes, card.yml's `secrets:`, and the `GITEA_` lines. A CI runner joins it with a registration token from **Site Administration**, then **Actions**, then **Runners**.

Repositories, attachments and settings live in the volume `gitea-data`, and users, issues and pull requests in `gitea-db-data`. Minimum recommended for the place `gitea`: 256 MB of memory and 1.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p gitea
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C gitea cards-main/gitea
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, `ORG_LABEL` to the part after the app name in a hostname `edgible app list` prints. There are no secrets to fill: Start makes them on the machine.

```bash
nano gitea/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py gitea
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file gitea/card.env -f gitea/docker-compose.yml pull
docker compose --env-file gitea/card.env -f gitea/docker-compose.yml up -d --wait
docker compose --env-file gitea/card.env -f gitea/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 184 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Gitea waits for its install page, which you fill in after Publish, behind the Edgible sign-in.

### 5. Publish

```bash
set -euo pipefail
set -a
. gitea/card.env
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
  --name gitea \
  --port "$GITEA_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name gitea-ssh \
  --port "$GITEA_SSH_PORT" \
  --protocol tcp \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `gitea` with `org` for now, and `gitea-ssh`.

### 6. Set up Gitea

A new Gitea shows its install page to its first visitor, so Publish put `gitea` on `org`: only your Edgible organization reaches it. `gitea-ssh` is open, but nobody can register, so there is no account to use it with yet. Open `https://<gitea hostname>`, sign in with Edgible, and Gitea shows its install page with the database already filled in. Leave those settings as they are, open **Administrator Account Settings** at the bottom, and make the admin: Gitea reserves the name `admin`, so choose another, such as `gitadmin`, and a strong password from a password manager. Then **Install Gitea**. Registration stays off whatever the page's box says: the Compose file sets it.

When the admin exists and the install page is gone, this prints `done`:

```bash
set -a
. gitea/card.env
set +a
test "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$GITEA_PORT/")" = 200 && ! curl -s "http://127.0.0.1:$GITEA_PORT/" | grep -q '<title>Installation' && curl -s "http://127.0.0.1:$GITEA_PORT/api/v1/users/search?limit=1" | grep -q '"login"' && echo done
```

If you installed without making an admin, nothing prints: nobody can register, so make one with `docker compose --env-file gitea/card.env -f gitea/docker-compose.yml exec -u git gitea gitea admin user create --admin --username gitadmin --email <you> --random-password`.

Then switch `gitea` to `none`, so `git` over HTTPS, CI runners, API tokens and webhooks reach it. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update gitea --auth-modes none
```

## Verify

`gitea` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<gitea hostname>"
```

That prints `200`. Open the hostname and sign in as the admin you made in Set up. **Register** is not offered: registration is off.

`gitea-ssh` is a TCP app on port `22222`, with no auth mode.

Check it answers as an SSH server:

```bash
nc -w 5 <gitea-ssh hostname> 22222 </dev/null | head -1
```

That prints a line starting `SSH-2.0-`. Add your SSH key under **Settings**, then **SSH / GPG Keys**, and clone with `git clone ssh://git@<gitea-ssh hostname>:22222/<owner>/<repo>.git`.

The rest of the setup is in the [Gitea docs](https://docs.gitea.com).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete gitea --yes
edgible app delete gitea-ssh --yes
```

### 2. Stop

```bash
docker compose --env-file gitea/card.env -f gitea/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `gitea-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=gitea); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file gitea/card.env -f gitea/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf gitea
```
