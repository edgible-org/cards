#!/bin/sh
# Prepare for the passbolt card: make the first admin, so no one else can claim it once it is public.
# Run it after Start and before Publish, from the directory that holds passbolt/:
#   sh passbolt/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

: "${PASSBOLT_ADMIN_EMAIL:?set PASSBOLT_ADMIN_EMAIL in card.env}"

# Prints a one-time link that sets up the admin's key and passphrase in the browser extension.
# exec does not pass through the entrypoint, so it reads the database password itself.
$COMPOSE exec -T -e PASSBOLT_ADMIN_EMAIL="$PASSBOLT_ADMIN_EMAIL" passbolt sh -c \
  'DATASOURCES_DEFAULT_PASSWORD=$(cat /run/card-secrets/PASSBOLT_DB_PASSWORD) exec /usr/share/php/passbolt/bin/cake passbolt register_user -u "$PASSBOLT_ADMIN_EMAIL" -f Admin -l User -r admin'
