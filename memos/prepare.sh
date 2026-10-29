#!/bin/sh
# Prepare for the memos card: make the admin and close sign-up before Memos is public.
# A new Memos lets its first visitor register as the admin, and anyone register after.
# Run it after Start and before Publish, from the directory that holds memos/:
#   sh memos/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret memos-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps memos-secrets show MEMOS_ADMIN_PASSWORD)
B="http://127.0.0.1:$MEMOS_PORT"
H='Content-Type: application/json'
out=$(mktemp); trap 'rm -f "$out"' EXIT

signin() {
  curl -s -o "$out" -w '%{http_code}' -X POST "$B/api/v1/auth/signin" -H "$H" \
    -d "{\"passwordCredentials\":{\"username\":\"$MEMOS_ADMIN_USER\",\"password\":\"$1\"}}"
}

if [ "$(signin "$PASSWORD")" != 200 ]; then
  code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
    -d "{\"username\":\"$MEMOS_ADMIN_USER\",\"password\":\"$PASSWORD\",\"role\":\"ADMIN\"}")
  [ "$code" = 200 ] || { echo "making the admin answered $code"; exit 1; }
  [ "$(signin "$PASSWORD")" = 200 ] || { echo "the new admin cannot sign in"; exit 1; }
fi
token=$(sed -n 's/.*"accessToken" *: *"\([^"]*\)".*/\1/p' "$out" | head -n 1)
[ -n "$token" ] || { echo "no access token in the sign-in answer"; exit 1; }

# Close sign-up: further accounts are made by the admin, under Settings, Members.
code=$(curl -s -o /dev/null -w '%{http_code}' -X PATCH \
  "$B/api/v1/instance/settings/GENERAL?updateMask=general_setting.disallow_user_registration" \
  -H "$H" -H "Authorization: Bearer $token" \
  -d '{"name":"instance/settings/GENERAL","generalSetting":{"disallowUserRegistration":true}}')
[ "$code" = 200 ] || { echo "closing sign-up answered $code"; exit 1; }
echo "the admin exists and sign-up is closed; sign in as $MEMOS_ADMIN_USER with MEMOS_ADMIN_PASSWORD"
