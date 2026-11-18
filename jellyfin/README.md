# jellyfin

## Why

Films, shows and music you already own shouldn't need a subscription to watch. [Jellyfin](https://jellyfin.org) is a free media server that streams your own library to its TV, phone and desktop apps and to any browser, from a machine you own.

## What

One app, `jellyfin`, on the place `jellyfin`, on `none`. That is deliberate: Jellyfin's TV, phone and desktop apps cannot get past an Edgible sign-in, so `org` would stop them playing. Jellyfin's own login protects it, and nobody can sign up: the admin adds everyone else. Until its setup wizard is finished, anyone who reaches Jellyfin can make the admin, so the card publishes it on `org` first: only your Edgible organization reaches the wizard, where you choose the language, your admin and password, and your libraries. Then you open it to everyone.

It runs one service, `jellyfin`, from the image Jellyfin publishes, pinned to `12.2.20261005-225228`. Your media folder is mounted read-only, so Jellyfin never changes your files. Hardware transcoding is optional: on Linux with an Intel or AMD GPU, uncomment the `devices:` lines in the Compose file. Without it, Jellyfin transcodes on the CPU, or not at all when the app plays the file as it is.

To use it in a card, copy the `jellyfin` service, the two volumes, card.yml's `setup:`, and the `JELLYFIN_` lines.

Settings, users and watch history live in the volume `jellyfin-config`, and artwork and transcodes in `jellyfin-cache`. Back up `jellyfin-config`; the cache rebuilds. Your media stays in `JELLYFIN_MEDIA_DIR`, outside Docker. The memory below is Jellyfin's own documented minimum, which is higher than an empty test library measures; transcoding several streams wants more. The disk is for Jellyfin itself, not your media. Minimum recommended for the place `jellyfin`: 4 GB of memory and 10 GB of disk, on an arm64 or amd64 machine, with a GPU if you have one (it runs without).

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Six steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p jellyfin
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C jellyfin cards-main/jellyfin
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `JELLYFIN_MEDIA_DIR` to the full path of the folder that holds your media. Keep that folder outside `jellyfin/`, because the last Tear down step deletes `jellyfin/`. There is no password to fill: you choose the admin's in Jellyfin's setup wizard.

```bash
nano jellyfin/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py jellyfin
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml pull
docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml up -d --wait
docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 424 MB, a minute or two on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck.

### 5. Publish

```bash
set -euo pipefail
set -a
. jellyfin/card.env
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
  --name jellyfin \
  --port "$JELLYFIN_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

### 6. Set up jellyfin

Publish put `jellyfin` on `org`, so only your Edgible organization reaches it. Open `https://<jellyfin hostname>`, sign in with Edgible, and finish the app's own setup there. Jellyfin's wizard asks for the language, your admin and password, and your libraries: add one pointing at `/media`, your `JELLYFIN_MEDIA_DIR`. Keep "Allow remote connections" on, or Jellyfin turns away its own apps once it is public. Use a password manager for the password.

When it is finished, this prints `done`:

```bash
set -a
. jellyfin/card.env
set +a
COMPOSE="docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml"
curl -fsS "http://127.0.0.1:$JELLYFIN_PORT/System/Info/Public" | grep -q '"StartupWizardCompleted":true' && echo done
```

Then switch it to `none`. Until then it stays on `org`, and nothing changes for you: a signed-in session stays signed in.

```bash
edgible app update jellyfin --auth-modes none
```

## Verify

`jellyfin` uses `none`.

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "https://<jellyfin hostname>"
```

That prints `302`: Jellyfin sending you to its web app, with no Edgible sign-in, as its apps need. In a Jellyfin app, set the server to `https://<jellyfin hostname>` and sign in with the admin you made in Set up.

For a forgotten password, use "Forgot Password" on Jellyfin's sign-in page and follow what it says. When the admin is locked out and that does not work, [Jellyfin's troubleshooting page](https://jellyfin.org/docs/general/administration/troubleshooting/) unlocks it on the machine.

The rest of the setup is in the [Jellyfin docs](https://jellyfin.org/docs).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete jellyfin --yes
```

### 2. Stop

```bash
docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=jellyfin); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file jellyfin/card.env -f jellyfin/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf jellyfin
```
