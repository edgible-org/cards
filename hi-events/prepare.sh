#!/bin/sh
# Prepare for the hi-events card: make the organizer account, then close sign-up.
# Run it after Start and before Publish, from the directory that holds hi-events/:
#   sh hi-events/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}
: "${HI_EVENTS_ADMIN_EMAIL:?set HI_EVENTS_ADMIN_EMAIL in card.env}"

# Open sign-up for the one request that makes the organizer, then close it again.
HI_EVENTS_DISABLE_REGISTRATION=false $COMPOSE up -d --wait hi-events
status=0
$COMPOSE exec -T -e ADMIN_EMAIL="$HI_EVENTS_ADMIN_EMAIL" hi-events sh -c '
  pw=$(cat /run/card-secrets/HI_EVENTS_ADMIN_PASSWORD)
  wget -q -O /dev/null --header="Content-Type: application/json" \
    --post-data="{\"first_name\":\"Organizer\",\"email\":\"$ADMIN_EMAIL\",\"password\":\"$pw\",\"password_confirmation\":\"$pw\",\"timezone\":\"UTC\"}" \
    http://127.0.0.1:80/api/auth/register
' || status=$?
$COMPOSE up -d --wait hi-events
if [ "$status" -ne 0 ]; then
  echo "Making the organizer failed (it may already exist): sign-up is closed again." >&2
  exit "$status"
fi
echo "Organizer $HI_EVENTS_ADMIN_EMAIL made. Show the password with:"
echo "  $COMPOSE run --rm --no-deps hi-events-secrets show HI_EVENTS_ADMIN_PASSWORD"
