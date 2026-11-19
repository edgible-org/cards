# wiki-go

## Why

A team wiki is where a team writes down how it does things, and hosted ones (Notion, Confluence) charge per seat and keep your pages on their servers. [Wiki-Go](https://leomoon.com/downloads/web-apps/wiki-go/) is a small open-source wiki that keeps pages as Markdown files, with no database to run. It has admin, editor and viewer roles, user groups, and rules that make a page or folder public, private or restricted to a group. This card runs it on a machine you own, through Edgible.

## What

One app, `wiki-go`, on `org`, so only members of your Edgible organization reach it. Everyone who reads or edits the team wiki is a person in a browser, so the Edgible sign-in is the first door and Wiki-Go's own login the second. One container runs it, as the image's own non-root user. People outside your organization cannot reach it. For a public knowledge base for customers, publish with `none` instead, which is a different choice from this card's: Wiki-Go's access rules then decide what a visitor without an account sees, so set them before you publish. Use Wiki-Go's roles and groups to keep confidential pages to the people who should see them. Wiki-Go starts with the user `admin` and the password `admin`; you change it in [Set up Wiki-Go](#6-set-up-wiki-go), and the Edgible sign-in keeps everyone outside your organization away from it meanwhile. Wiki-Go counts failed sign-ins by address and sees the Edgible gateway's address for everyone, so a run of failures from anyone can lock sign-in for a while.

Pages, uploads, users and settings, the admin's password included, are all files in the volume `wiki-go-data`. Copy it. Minimum recommended for the place `wiki-go`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p wiki-go
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C wiki-go cards-main/wiki-go
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. Change `WIKI_GO_PORT` only if 8080 is taken.

```bash
nano wiki-go/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py wiki-go
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file wiki-go/card.env -f wiki-go/docker-compose.yml pull
docker compose --env-file wiki-go/card.env -f wiki-go/docker-compose.yml up -d --wait
docker compose --env-file wiki-go/card.env -f wiki-go/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. Here that means Wiki-Go answers on its sign-in page, with the user `admin` and the password `admin` until you change it in [Set up Wiki-Go](#6-set-up-wiki-go).

### 5. Publish

```bash
set -euo pipefail
set -a
. wiki-go/card.env
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
  --name wiki-go \
  --port "$WIKI_GO_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `wiki-go` with `org`.

### 6. Set up Wiki-Go

Wiki-Go starts with the user `admin` and the password `admin`, which everyone knows. `wiki-go` is on `org`, so only your Edgible organization reaches it. Open `https://<wiki-go hostname>`, sign in with Edgible, then sign in to Wiki-Go as `admin` with `admin`, and change the password in your profile. Use a strong password from a password manager.

When it is changed, this prints `done`:

```bash
set -a
. wiki-go/card.env
set +a
test "$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$WIKI_GO_PORT/api/login" -H 'Content-Type:application/json' -d '{"username":"admin","password":"admin"}')" = 401 && echo done
```

`wiki-go` stays on `org`.

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`wiki-go` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<wiki-go hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. The check proves the Edgible sign-in stands in front of the wiki. Then sign in as `admin` with the password you set in Set up, and add your team under Users in the admin settings. Wiki-Go has no email invitations: you make each account and give its password.

The rest of the setup is in the [Wiki-Go docs](https://github.com/leomoon-studios/wiki-go#readme).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete wiki-go --yes
```

### 2. Stop

```bash
docker compose --env-file wiki-go/card.env -f wiki-go/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=wiki-go); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file wiki-go/card.env -f wiki-go/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf wiki-go
```
