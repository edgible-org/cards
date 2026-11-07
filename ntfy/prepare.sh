#!/bin/sh
# Prepare for the ntfy card: make the admin, so nobody else can.
# Run it after Start and before Publish, from the directory that holds ntfy/:
#   sh ntfy/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# Access control is already on and denies everyone (docker-compose.yml). This adds the one
# login that can grant access, with the password ntfy-secrets made. It does nothing if the
# admin exists.
$COMPOSE exec -T -e NTFY_ADMIN_USER="$NTFY_ADMIN_USER" ntfy sh -c '
  if ntfy user list 2>/dev/null | grep -q "^user $NTFY_ADMIN_USER "; then
    echo "admin $NTFY_ADMIN_USER exists"
  else
    NTFY_PASSWORD=$(cat /run/card-secrets/NTFY_ADMIN_PASSWORD) ntfy user add --role=admin "$NTFY_ADMIN_USER"
  fi'
