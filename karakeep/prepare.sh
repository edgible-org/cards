#!/bin/sh
# Prepare for the karakeep card: make the admin before the sign-up page is public.
# Run it after Start and before Publish, from the directory that holds karakeep/:
#   sh karakeep/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret karakeep-secrets made on this machine.
KARAKEEP_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps karakeep-secrets show KARAKEEP_ADMIN_PASSWORD)

# Open sign-up for this one local request. Nothing is published yet. Karakeep makes the first
# account an admin.
KARAKEEP_DISABLE_SIGNUPS=false $COMPOSE up -d --wait karakeep
B="http://127.0.0.1:$KARAKEEP_PORT"
O=${KARAKEEP_URL:-https://karakeep.$ORG_LABEL.${EDGIBLE_DOMAIN:-edgible.app}}
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/sign-up/email" \
  -H 'Content-Type: application/json' -H "Origin: $O" \
  -d "{\"name\":\"admin\",\"email\":\"$KARAKEEP_ADMIN_EMAIL\",\"password\":\"$KARAKEEP_ADMIN_PASSWORD\"}")

# Close it again, whatever happened: recreate with the Compose file's default.
$COMPOSE up -d --wait --force-recreate karakeep
# 200 made the admin; 422 or 400 means that email already has an account (a second run).
[ "$code" = 200 ] || [ "$code" = 400 ] || [ "$code" = 422 ] || { echo "creating the admin answered $code"; exit 1; }
echo "admin $KARAKEEP_ADMIN_EMAIL made; sign-up is closed again"
