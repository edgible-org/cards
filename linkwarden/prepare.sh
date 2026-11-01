#!/bin/sh
# Prepare for the linkwarden card: make the admin before the sign-up page is public.
# Run it after Start and before Publish, from the directory that holds linkwarden/:
#   sh linkwarden/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret linkwarden-secrets made on this machine.
LINKWARDEN_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps linkwarden-secrets show LINKWARDEN_ADMIN_PASSWORD)

# Open sign-up for this one local request. Nothing is published yet.
LINKWARDEN_DISABLE_REGISTRATION=false $COMPOSE up -d --wait linkwarden
B="http://127.0.0.1:$LINKWARDEN_PORT"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H 'Content-Type: application/json' \
  -d "{\"name\":\"$LINKWARDEN_ADMIN_USER\",\"username\":\"$LINKWARDEN_ADMIN_USER\",\"password\":\"$LINKWARDEN_ADMIN_PASSWORD\"}")

# Close it again, whatever happened: recreate with the Compose file's default.
$COMPOSE up -d --wait --force-recreate linkwarden
[ "$code" = 201 ] || [ "$code" = 400 ] || { echo "creating the admin answered $code"; exit 1; }
echo "admin $LINKWARDEN_ADMIN_USER made; sign-up is closed again"
