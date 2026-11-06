# redaxo

## Why

A small business website on Squarespace or Wix costs a monthly fee and holds your pages in their editor. [REDAXO](https://www.redaxo.org) is a content management system: you edit pages, menus and media in its back end, and the site is built from templates you control. It is popular with agencies, and its back end can be set to English or German (its own documentation is mostly in German). This card runs it, with MariaDB, on a machine you own.

## What

One app on two hostnames, both the same REDAXO process on port `8087`. `redaxo` is the public website, on `none`, because a site is for anyone. `redaxo-admin` is on `org`, for the people who edit: only members of your Edgible organization reach its sign-in. Use the `redaxo-admin` address for editing. REDAXO's editor lives at `/redaxo` on every hostname, so the public hostname also shows REDAXO's own sign-in page there; it asks for the admin's name and password, so keep the one the card made and add no weak users. The image is published with a floating `5` tag only, so the card pins that tag to one build by digest.

Your pages, users and settings are in the database volume `redaxo-db-data`; uploads, addons and the config are in `redaxo-files`; the passwords are in `redaxo-secrets`. Back up all three. Minimum recommended for the place `redaxo`: 512 MB of memory and 2 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p redaxo
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C redaxo cards-main/redaxo
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL`. Change `REDAXO_ADMIN_EMAIL` to yours, and set `REDAXO_LANG` and `REDAXO_TIMEZONE`. Change `REDAXO_PORT` only if 8087 is taken.

```bash
nano redaxo/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py redaxo
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file redaxo/card.env -f redaxo/docker-compose.yml pull
docker compose --env-file redaxo/card.env -f redaxo/docker-compose.yml up -d --wait
docker compose --env-file redaxo/card.env -f redaxo/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The first start installs REDAXO and makes the admin, so no setup page is ever public. The admin's name is `REDAXO_ADMIN_USER` in `card.env`.

### 5. Publish

```bash
set -euo pipefail
set -a
. redaxo/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name redaxo \
  --port "$REDAXO_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name redaxo-admin \
  --port "$REDAXO_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`redaxo` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<redaxo hostname>"
```

The check asks for the editor's sign-in page, because a new REDAXO has no pages yet, so its front page may be empty. Open `https://<redaxo hostname>/redaxo` only to confirm it shows the sign-in, not an install wizard.

`redaxo-admin` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<redaxo-admin hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the address, sign in to Edgible, then to REDAXO as the admin with the password the `show` command above prints. From there add templates, articles and addons.

The rest of the setup is in the [REDAXO documentation docs](https://www.redaxo.org/doku/main).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete redaxo --yes
edgible app delete redaxo-admin --yes
```

### 2. Stop

```bash
docker compose --env-file redaxo/card.env -f redaxo/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=redaxo); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file redaxo/card.env -f redaxo/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf redaxo
```
