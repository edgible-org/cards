#!/bin/sh
# Prepare for the domoticz card: make the admin before Domoticz is public.
# A new Domoticz lets its first visitor create the admin account.
# Run it after Start and before Publish, from the directory that holds domoticz/:
#   sh domoticz/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The admin's password is the human secret domoticz-secrets made on this machine.
PASSWORD=$($COMPOSE run --rm --no-deps domoticz-secrets show DOMOTICZ_ADMIN_PASSWORD)
B="http://127.0.0.1:$DOMOTICZ_PORT/json.htm"
out=$(mktemp); trap 'rm -f "$out"' EXIT

# Domoticz takes the password as its MD5 hash.
if command -v md5sum >/dev/null 2>&1; then
  HASH=$(printf %s "$PASSWORD" | md5sum | cut -d' ' -f1)
else
  HASH=$(printf %s "$PASSWORD" | md5 -q)
fi

curl -fsS "$B?type=command&param=getsetuprequired" -o "$out"
if grep -Eq '"SetupRequired" *: *true' "$out"; then
  curl -fsS -G "$B" -o "$out" --data-urlencode type=command --data-urlencode param=setupwizardcreateadmin \
    --data-urlencode "username=$DOMOTICZ_ADMIN_USER" --data-urlencode "password=$HASH"
  grep -Eq '"status" *: *"OK"' "$out" || { echo "making the admin failed: $(cat "$out")"; exit 1; }
fi

# Fail closed: a caller with no sign-in, as Edgible's gateway is to Domoticz, must get nothing.
curl -s "$B?type=command&param=getusers" -o "$out" || true
if grep -Eq '"status" *: *"OK"' "$out"; then
  echo "Domoticz answers without a sign-in; do not publish it. Check Setup, Settings, Local Networks."
  exit 1
fi
echo "the admin exists and Domoticz asks for a sign-in; sign in as $DOMOTICZ_ADMIN_USER with DOMOTICZ_ADMIN_PASSWORD"
