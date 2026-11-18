#!/bin/sh
# Prepare for the librephotos card: close sign-up, so only the admin can make accounts.
# Run it after Start and before Publish, from the directory that holds librephotos/:
#   sh librephotos/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# LibrePhotos made the admin at start, with the human secret librephotos-secrets made.
LIBREPHOTOS_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps librephotos-secrets show LIBREPHOTOS_ADMIN_PASSWORD)

B="http://127.0.0.1:$LIBREPHOTOS_PORT"
H='Content-Type: application/json'
token=$(curl -fsS -X POST "$B/api/auth/token/obtain" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$LIBREPHOTOS_ADMIN_PASSWORD\"}" \
  | sed -n 's/.*"access":"\([^"]*\)".*/\1/p')
[ -n "$token" ] || { echo "the admin could not sign in"; exit 1; }
curl -fsS -X POST "$B/api/sitesettings" -H "$H" -H "Authorization: Bearer $token" \
  -d '{"allow_registration":false,"allow_upload":true}' >/dev/null
curl -fsS "$B/api/sitesettings" -H "Authorization: Bearer $token" | tr -d ' ' | grep -q '"allow_registration":false' \
  || { echo "sign-up is still open"; exit 1; }
echo "sign-up is closed; the admin is admin, with LIBREPHOTOS_ADMIN_PASSWORD"
