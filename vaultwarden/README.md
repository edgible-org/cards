# vaultwarden

## Why

A password manager is the one service whose data you most want on a machine you own. [Vaultwarden](https://github.com/dani-garcia/vaultwarden) is a small server that the official Bitwarden apps, browser extensions and web vault all talk to.

## What

One app, `vaultwarden`, on the place `vaultwarden`, on `org`, with the paths the Bitwarden apps call left to Vaultwarden's own login. The phone apps, desktop apps and browser extensions cannot get past an Edgible sign-in, so those paths (sign-in, `/api/`, live sync, events and site icons) go straight to Vaultwarden, where each call needs the person's own Vaultwarden password or token. Everything else stays behind Edgible's sign-in: the web vault, sign-up and the `/admin` page. So anyone who uses the web vault, such as someone you invite, must be in your Edgible organization; the apps work for everyone with an account. Vaultwarden's own protections stay on as well: every vault is encrypted with its owner's master password, sign-ups are off (`SIGNUPS_ALLOWED: "false"`), so nobody can create an account unless you invite them, and `/admin` needs `VAULTWARDEN_ADMIN_TOKEN`.

Vaultwarden must know its own address, so `DOMAIN` is `https://vaultwarden.<ORG_LABEL>.<EDGIBLE_DOMAIN>`, or `VAULTWARDEN_URL` on your own domain. The image is `vaultwarden/server:1.37.5`, with its own healthcheck.

The admin token is a long random string the card makes on the machine at first start, in the volume `vaultwarden-secrets`; it never leaves the machine. Vaultwarden prints a notice recommending an Argon2 hash of it instead.

Vaults, attachments and settings live in the volume `vaultwarden-data`. Back it up; it holds everyone's encrypted vault. Minimum recommended for the place `vaultwarden`: 256 MB of memory and 1.5 GB of disk, on an arm64, amd64 or 32-bit arm machine, with no GPU.

The Compose file is [docker-compose.yml](docker-compose.yml), the settings [card.env](card.env), the card [card.yml](card.yml), and the last test [test.yml](test.yml).

## How

Five steps. Edit [card.env](card.env) before you start.

### 1. Fetch

```bash
mkdir -p vaultwarden
curl -fsSL https://github.com/edgible-org/cards/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=2 -C vaultwarden cards-main/vaultwarden
```

### 2. Edit card.env

Set `DEVICE` to a name `edgible device list` prints, and `ORG_LABEL` to the part after the app name in a hostname `edgible app list` prints. There is no token to fill: Start makes it on the machine.

```bash
nano vaultwarden/card.env
```

### 3. Check

```bash
curl -fsSLo check-env.py https://raw.githubusercontent.com/edgible-org/card-kit/main/check-env.py
python3 check-env.py vaultwarden
```

It moves a taken port, as lines to paste. Run it again until it says `no conflicts`.

### 4. Start

```bash
docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml pull
docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml up -d --wait
docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml ps
```

The first start downloads the app's images from the registries named in the Compose file: about 97 MB, under a minute on a typical home connection. `pull` does that download on its own, so you can see it. The time is the download, not Edgible, and it happens once: later starts and upgrades reuse the images on the machine and fetch only what changed. `--wait` returns when each service is running, and healthy when it has a healthcheck. The image's own healthcheck applies.

### 5. Publish

```bash
set -euo pipefail
set -a
. vaultwarden/card.env
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
  --name vaultwarden \
  --port "$VAULTWARDEN_PORT" \
  --protocol https \
  --auth-modes org \
  --device-id "$device_id"
curl -fsSLo app-paths.py https://raw.githubusercontent.com/edgible-org/card-kit/main/app-paths.py
python3 app-paths.py vaultwarden vaultwarden
edgible app list
```

**Without Edgible:** only Publish is Edgible's. The app listens on `127.0.0.1` at the port in `card.env`, so any reverse proxy or tunnel on the machine, such as Caddy, nginx, Cloudflare Tunnel or Tailscale, can publish it instead, and sign-in is then that tool's to provide. Every other step stays the same.

## Verify

`vaultwarden` uses `org`.

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<vaultwarden hostname>"
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "https://<vaultwarden hostname>/identity/connect/token"
```

The first prints `302` and an `edgible.com/application-access/` address, so the org sign-in is in front of the web pages. The second prints `vaultwarden`'s own answer, with no sign-in address: Publish left the paths in `appPaths` ([card.yml](card.yml)) to its own login, so clients that cannot pass Edgible's sign-in still connect. Open `https://<vaultwarden hostname>/admin`, sign in with Edgible, enter the admin token (`docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml run --rm --no-deps vaultwarden-secrets show VAULTWARDEN_ADMIN_TOKEN` prints it), and invite yourself under **Users**. With no mail server set up, the invited address can then create its account on the web vault. Then point a Bitwarden app at `https://<vaultwarden hostname>` as a self-hosted server.

The rest of the setup is in the [Vaultwarden docs](https://github.com/dani-garcia/vaultwarden/wiki).

## Tear down

Four steps, in this order. Step 1 runs wherever `edgible` is logged in. Steps 2 to 4 run on the machine that runs the containers. Steps 2 and 3 read `card.env`, so keep it until step 4.

### 1. Unpublish

```bash
edgible app delete vaultwarden --yes
```

### 2. Stop

```bash
docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml down
```

### 3. Delete the data

Skip this step to keep the data. The loop copies each volume to a `.tgz` file in this directory first. `vaultwarden-secrets.tgz` holds the card's passwords and keys: keep it as safe as the data, which needs them.

```bash
for volume in $(docker volume ls -q --filter label=com.docker.compose.project=vaultwarden); do
  docker run --rm -v "$volume:/data:ro" -v "$PWD:/backup" alpine tar -czf "/backup/$volume.tgz" -C /data .
done
docker compose --env-file vaultwarden/card.env -f vaultwarden/docker-compose.yml down --volumes
```

### 4. Remove the card

```bash
rm -rf vaultwarden
```
