# umami

## Why

Knowing whether anyone reads your site usually means handing every visitor to an analytics company. [Umami](https://umami.is) counts page views without cookies or personal data, and keeps the database on a machine you own.

## What

One process on two hostnames. `umami` is the dashboard, behind `org`. `analytics` serves the tracking script and takes page views, on `none`, because every visitor's browser has to reach it. Both are port `3000` on the place `umami`; list `umami` first so `UMAMI_PORT` is named after it. Postgres runs beside it as `umami-db`.

The `analytics` hostname serves the whole Umami process, so its login page is public too. Umami's own password protects it, which is why Start changes the default password before anything is published.

To use it in a card, copy the `umami-secrets`, `umami` and `umami-db` services, both volumes, and the `secrets:` section of [card.yml](card.yml), then put the tracking snippet from the dashboard into your site with the `analytics` hostname.

Page views, sites and accounts live in the volume `umami-db-data`.

No password or key is in `card.env`. At first start `umami-secrets` makes the three that card.yml's `secrets:` declares on the machine, one file each in the volume `umami-secrets`, and never changes them after. The database reads its password from that file, and Umami starts through a loader that reads them. They never leave the machine, and nothing else needs to know them. The admin is `admin`, with Umami's default password `umami` until you change it in [Set up Umami](#6-set-up-umami).

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints. There are no secrets to fill: Start makes them on the machine.

```bash
nano umami/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py umami
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file umami/card.env -f umami/docker-compose.yml pull
docker compose --env-file umami/card.env -f umami/docker-compose.yml up -d --wait
docker compose --env-file umami/card.env -f umami/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 439 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. `umami-secrets` makes the secrets first and exits. Umami starts with the account `admin` and the password `umami`. Publish keeps both hostnames behind the Edgible sign-in until you have changed it, in [Set up Umami](#6-set-up-umami).

### 5. Publish

```bash
set -euo pipefail
set -a
. umami/card.env
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
  --name umami \
  --port "$UMAMI_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app create existing \
  --non-interactive \
  --name analytics \
  --port "$UMAMI_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

`edgible app list` shows `umami` and `analytics`, both with `org` for now.

### 6. Set up Umami

Umami starts with the account `admin` and the password `umami`, which everyone knows, and `analytics` reaches the same Umami, login page included. So Publish put `umami` and `analytics` on `org`: only your Edgible organization reaches them. Open `https://<umami hostname>`, sign in with Edgible, then sign in to Umami as `admin` with `umami`, and change the password under Settings, Profile. Use a strong password from a password manager: once `analytics` is open, Umami's login is what protects it there.

When it is changed, this prints `done`:

```bash
set -a
. umami/card.env
set +a
test "$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$UMAMI_PORT/api/auth/login" -H 'Content-Type:application/json' -d '{"username":"admin","password":"umami"}')" = 401 && echo done
```

Then switch `analytics` to `none`, so websites can load the tracking script; `umami` stays on `org`. Until then they stay on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update analytics --auth-modes none
```

## Verify

`umami` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<umami hostname>"
```

That prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front. Open the hostname in a browser, sign in, then sign in to Umami with the password you set in Set up.

`analytics` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<analytics hostname>"
```

That prints `200`. Fetch `/script.js` on it to see the tracking script, with no login.

The rest of the setup is in the [Umami docs](https://umami.is/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete umami --yes
edgible app delete analytics --yes
```

### 2. Stop

```bash
docker compose --env-file umami/card.env -f umami/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `umami-secrets.tgz` holds the passwords and keys: keep it as safe as the data, since the data needs it.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=umami); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file umami/card.env -f umami/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf umami
```
