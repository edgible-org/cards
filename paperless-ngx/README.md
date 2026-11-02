# paperless-ngx

## Why

Invoices, letters, contracts and statements pile up on paper and in mail attachments, and are hard to find when you need them. [Paperless-ngx](https://docs.paperless-ngx.com) reads the text of each scan or PDF (OCR), tags and files it, and makes the whole archive searchable, on a machine you own instead of a cloud scanning service.

## What

One app, `paperless-ngx`, on `org`. A document archive is private, and a person uses it in a browser, so only members of your Edgible organisation reach it, and Paperless's own login still applies after that. The trade-off is that Paperless's phone apps and API clients cannot get past the Edgible sign-in; upload from the web interface, or from a scanner that writes to a folder on the machine. Four services run it: `paperless-ngx`, `paperless-ngx-db`, a Postgres, `paperless-ngx-redis`, a queue, and `paperless-ngx-secrets`, which makes the passwords and exits. Paperless makes the admin itself at its first start, with a password made on the machine, so there is no setup page to leave open. Inside the app, give each person their own user and set who sees which documents with its permissions and groups; for documents with client, patient or financial data, keep it on `org`, use those permissions, keep encrypted backups, and follow your profession's retention rules.

Original and archived documents live in the volume `paperless-ngx-media`, the database in `paperless-ngx-db-data`; back those two up together. `paperless-ngx-data` holds the search index, which Paperless rebuilds, and `paperless-ngx-consume` is a drop folder. Minimum recommended for the place `paperless-ngx`: 3 GB of memory and 6 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p paperless-ngx
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C paperless-ngx cards-main/paperless-ngx
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, `PAPERLESS_NGX_TIME_ZONE` to yours, and `PAPERLESS_NGX_OCR_LANGUAGE` to the language of your documents. There are no passwords to fill: Start makes them on the machine.

```bash
nano paperless-ngx/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py paperless-ngx
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml pull
docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml up -d --wait
docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The admin is made at this first start, by Paperless, which can take a minute after the services show healthy.

### 5. Publish

```bash
set -euo pipefail
set -a
. paperless-ngx/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name paperless-ngx \
  --port "$PAPERLESS_NGX_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`paperless-ngx` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<paperless-ngx hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. That redirects to the Edgible sign-in, so nobody outside your organisation reaches the app. After you sign in to Edgible, sign in to Paperless as `PAPERLESS_NGX_ADMIN_USER` with the password the card made; see it with `docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml run --rm --no-deps paperless-ngx-secrets show PAPERLESS_NGX_ADMIN_PASSWORD`. Change it under your profile after.

The rest of the setup is in the [Paperless-ngx docs](https://docs.paperless-ngx.com).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete paperless-ngx --yes
```

### 2. Stop

```bash
docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=paperless-ngx); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file paperless-ngx/card.env -f paperless-ngx/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf paperless-ngx
```
