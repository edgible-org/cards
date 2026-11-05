#!/bin/sh
# Prepare for the activepieces card: make the admin before the sign-up page is public.
# The first person to sign up becomes the platform's admin, so it is done here, not by a visitor.
# Run it after Start and before Publish, from the directory that holds activepieces/:
#   sh activepieces/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The password is the human secret activepieces-secrets made on this machine.
ACTIVEPIECES_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps activepieces-secrets show ACTIVEPIECES_ADMIN_PASSWORD)

curl -fsS -X POST "http://127.0.0.1:$ACTIVEPIECES_PORT/api/v1/authentication/sign-up" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$ACTIVEPIECES_ADMIN_PASSWORD\",\"firstName\":\"Admin\",\"lastName\":\"Admin\",\"trackEvents\":false,\"newsLetter\":false}" >/dev/null
echo "admin@example.com is the admin, with the password ACTIVEPIECES_ADMIN_PASSWORD"
