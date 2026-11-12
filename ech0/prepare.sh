#!/bin/sh
# Prepare for the ech0 card: make the owner and close sign-up before the site is public.
# Run it after Start and before Publish, from the directory that holds ech0/:
#   sh ech0/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The card made this password on this machine at Start (ech0-secrets).
ECH0_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps ech0-secrets show ECH0_ADMIN_PASSWORD)

B="http://127.0.0.1:$ECH0_PORT/api"
H='Content-Type: application/json'

n=0
until curl -fsS "$B/init/status" >/dev/null 2>&1; do
  n=$((n + 1)); [ "$n" -lt 60 ] || { echo "ech0 did not answer"; exit 1; }
  sleep 1
done

# The first account to register becomes the owner, so make it here, not on a public page.
curl -fsS -X POST "$B/init/owner" -H "$H" \
  -d "{\"username\":\"$ECH0_ADMIN_USER\",\"email\":\"$ECH0_ADMIN_EMAIL\",\"password\":\"$ECH0_ADMIN_PASSWORD\",\"locale\":\"en-US\"}" >/dev/null

token=$(curl -fsS -X POST "$B/login" -H "$H" \
  -d "{\"username\":\"$ECH0_ADMIN_USER\",\"password\":\"$ECH0_ADMIN_PASSWORD\"}" \
  | python3 -c '
import json, sys
token = json.load(sys.stdin)["data"]["access_token"]
if not token:
    sys.exit(1)
print(token)
')

# Close sign-up: the owner is the only account until the owner adds more.
settings=$(curl -fsS "$B/settings" | python3 -c '
import json, sys
data = json.load(sys.stdin)["data"]
data["allow_register"] = False
print(json.dumps(data, separators=(",", ":"), ensure_ascii=False))
')
curl -fsS -X PUT "$B/settings" -H "$H" -H "Authorization: Bearer $token" -d "$settings" >/dev/null
curl -fsS "$B/settings" | python3 -c '
import json, sys
sys.exit(0 if json.load(sys.stdin)["data"].get("allow_register") is False else 1)
'
echo "owner made from ECH0_ADMIN_USER and ECH0_ADMIN_PASSWORD, sign-up closed"
