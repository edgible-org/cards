# razzia

## Why

You want to run a quiz for a classroom, a club night, a team event or a family evening, where everyone answers on their own phone and a big screen shows the scores, without a hosted quiz service and its player limits. [Razzia](https://github.com/Ralex91/Razzia) is a Kahoot-style quiz platform made for smaller events. The host builds quizzes and starts a game; players type the game code in their phone's browser, with no account and nothing to install.

## What

One Razzia container, with its quizzes, media and results in one volume. It is published on one hostname with auth mode `none`, because the players are guests with no Edgible account, on phones that cannot get past an Edgible sign-in. The host page is on the same hostname, so Razzia's own host password is what stops a stranger from creating quizzes or starting games; players can only join a game the host has started. A strong host password and a session signing key are made on the machine at first start, and are not in `card.env`. If only your Edgible organization will ever play, change the hostname to `org` after Publish with `edgible app update`.

The quizzes, uploaded media and saved results are in the `razzia-config` volume; the host password and signing key are in `razzia-secrets`. Minimum recommended for the place `razzia`: 256 MB of memory and 1 GB of disk, on an arm64 or amd64 machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p razzia
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C razzia cards-main/razzia
```

### 2. Edit card.env

Set `DEVICE`.

```bash
nano razzia/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py razzia
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file razzia/card.env -f razzia/docker-compose.yml pull
docker compose --env-file razzia/card.env -f razzia/docker-compose.yml up -d --wait
docker compose --env-file razzia/card.env -f razzia/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file, which takes longer for a larger app. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. 

### 5. Publish

```bash
set -euo pipefail
set -a
. razzia/card.env
set +a
device_id=$(edgible device list --json | jq -er --arg name "$DEVICE" '
  map(select(.name == $name))
  | if length == 1 then .[0].id
    else error("need exactly one device named " + $name + " (" + (map(.status + " " + .id) | join(", ")) + ")")
    end
')
edgible app create existing \
  --non-interactive \
  --name razzia \
  --port "$RAZZIA_PORT" \
  --protocol https \
  --auth-modes none \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`razzia` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<razzia hostname>"
```

Answers with the Razzia page, open to the internet. Open it, choose the host side, and sign in with the host password the card made. Show it on the machine with `docker compose --env-file razzia/card.env -f razzia/docker-compose.yml run --rm --no-deps razzia-secrets show RAZZIA_MANAGER_PASSWORD`. Players open the same address on their phones and enter the game code.

The rest of the setup is in the [Razzia docs](https://github.com/Ralex91/Razzia).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete razzia --yes
```

### 2. Stop

```bash
docker compose --env-file razzia/card.env -f razzia/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=razzia); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file razzia/card.env -f razzia/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf razzia
```
