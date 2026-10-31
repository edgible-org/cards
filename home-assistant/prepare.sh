#!/bin/sh
# Prepare for the home-assistant card: make the admin before Home Assistant is public.
# A new Home Assistant lets its first visitor create the owner account.
# Run it after Start and before Publish, from the directory that holds home-assistant/:
#   sh home-assistant/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret home-assistant-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps home-assistant-secrets show HOME_ASSISTANT_ADMIN_PASSWORD)
B="http://127.0.0.1:$HOME_ASSISTANT_PORT"
out=$(mktemp); trap 'rm -f "$out"' EXIT

curl -fsS "$B/api/onboarding" -o "$out"
if tr -d ' \n' < "$out" | grep -q '"step":"user","done":false'; then
  curl -fsS -X POST "$B/api/onboarding/users" -o "$out" -H 'Content-Type: application/json' \
    -d "{\"client_id\":\"$B/\",\"name\":\"$HOME_ASSISTANT_ADMIN_USER\",\"username\":\"$HOME_ASSISTANT_ADMIN_USER\",\"password\":\"$PASSWORD\",\"language\":\"en\"}" \
    || { echo "making the admin failed"; exit 1; }
fi

# Fail closed: a caller with no sign-in, as Edgible's gateway is to Home Assistant, must get nothing.
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/")
if [ "$code" != 401 ]; then
  echo "Home Assistant answered $code to a caller with no sign-in; do not publish it."
  exit 1
fi
echo "the admin exists and Home Assistant asks for a sign-in; sign in as $HOME_ASSISTANT_ADMIN_USER with HOME_ASSISTANT_ADMIN_PASSWORD"
