#!/bin/sh
# Prepare for the open-webui card: check the admin exists and sign-up is closed before it is public.
# Open WebUI makes the admin on its first start from OPEN_WEBUI_ADMIN_EMAIL and the secret
# OPEN_WEBUI_ADMIN_PASSWORD, and closes sign-up then; without that, its first visitor becomes
# the admin. This stops if either is not so.
# Run it after Start and before Publish, from the directory that holds open-webui/:
#   sh open-webui/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

PASSWORD=$($COMPOSE run --rm --no-deps open-webui-secrets show OPEN_WEBUI_ADMIN_PASSWORD)
B="http://127.0.0.1:$OPEN_WEBUI_PORT"
H='Content-Type: application/json'

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auths/signin" -H "$H" \
  -d "{\"email\":\"$OPEN_WEBUI_ADMIN_EMAIL\",\"password\":\"$PASSWORD\"}")
[ "$code" = 200 ] || { echo "the admin cannot sign in ($code)"; exit 1; }

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auths/signup" -H "$H" \
  -d '{"name":"stranger","email":"stranger@example.com","password":"stranger-pass-123"}')
[ "$code" != 200 ] || { echo "sign-up is open: a stranger made an account"; exit 1; }
echo "the admin exists and sign-up is closed; sign in as $OPEN_WEBUI_ADMIN_EMAIL with OPEN_WEBUI_ADMIN_PASSWORD"
