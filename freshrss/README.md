# freshrss

## Why

Following news and blogs in one place usually means a hosted reader such as Feedly or Inoreader, which holds your subscriptions and your reading history and charges for the better features. This card keeps them on a machine you own. [FreshRSS](https://freshrss.org/) is a feed reader with a fast web interface, folders, filters and search, and an API that many phone and desktop reader apps already speak, so you can read on a phone and keep it in step with the web.

## What

One app on two hostnames, both the same FreshRSS process on port `8080`. `freshrss` is on `org`, for people reading in a browser, so only members of your Edgible organization reach its sign-in page. `freshrss-app` is on `none`, because a phone reader app calls the API and cannot pass an Edgible sign-in. The API (`/api/greader.php`) asks for the admin's name and a separate API password, and everything else on that hostname is FreshRSS's own login page, so treat it as open to the internet: keep the passwords the card made, and leave sign-up closed. Give a reader app only the `freshrss-app` address. It keeps its data in SQLite in one volume, with no separate database, and refreshes every feed twice an hour.

Your subscriptions, articles, and settings live in the volume `freshrss-data`. The passwords are in `freshrss-secrets`. Back up both: the passwords are made once. Minimum recommended for the place `freshrss`: 256 MB of memory and 1.5 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p freshrss
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C freshrss cards-main/freshrss
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the part after the app name in one of your hostnames. Set `FRESHRSS_TZ` to your time zone. Change `FRESHRSS_PORT` only if 8080 is taken.

```bash
nano freshrss/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py freshrss
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml pull
docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml up -d --wait
docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The first start installs FreshRSS and makes the admin, so no setup page is ever public. The admin's name is `FRESHRSS_ADMIN_USER` in `card.env`. Show the two passwords on the machine with `docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml run --rm --no-deps freshrss-secrets show FRESHRSS_ADMIN_PASSWORD`, and the same with `FRESHRSS_API_PASSWORD`.

### 5. Publish

```bash
set -euo pipefail
set -a
. freshrss/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name freshrss \
  --port "$FRESHRSS_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name freshrss-app \
  --port "$FRESHRSS_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`freshrss` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<freshrss hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the hostname in a browser, sign in to Edgible, then to FreshRSS as the admin with `FRESHRSS_ADMIN_PASSWORD`. Change the password under Configuration, Profile.

`freshrss-app` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<freshrss-app hostname>"
```

The API sign-in answers `401` for a wrong API password and a token for the right one: `curl -sS --data-urlencode "Email=admin" --data-urlencode "Passwd=<API password>" https://<freshrss-app hostname>/api/greader.php/accounts/ClientLogin` prints a line starting `Auth=`. In a reader app, choose FreshRSS or Google Reader API, give the address `https://<freshrss-app hostname>/api/greader.php`, the admin's name, and the API password.

The rest of the setup is in the [FreshRSS docs](https://freshrss.github.io/FreshRSS/en/).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete freshrss --yes
edgible app delete freshrss-app --yes
```

### 2. Stop

```bash
docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=freshrss); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file freshrss/card.env -f freshrss/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf freshrss
```
