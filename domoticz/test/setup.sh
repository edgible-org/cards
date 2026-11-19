#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the domoticz
# hostname behind the Edgible sign-in, where a new Domoticz asks its first visitor to make the
# admin; this does the same through Domoticz's API, with a random password only this run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$DOMOTICZ_PORT/json.htm"
out=$(mktemp); trap 'rm -f "$out"' EXIT
# Domoticz takes the password as its MD5 hash.
if command -v md5sum >/dev/null 2>&1; then
  hash=$(printf %s "$password" | md5sum | cut -d' ' -f1)
else
  hash=$(printf %s "$password" | md5 -q)
fi
curl -fsS "$B?type=command&param=getsetuprequired" -o "$out"
grep -Eq '"SetupRequired" *: *true' "$out" || { echo "Domoticz did not ask for its first admin: $(cat "$out")"; exit 1; }
curl -fsS -G "$B" -o "$out" --data-urlencode type=command --data-urlencode param=setupwizardcreateadmin \
  --data-urlencode username=admin --data-urlencode "password=$hash"
grep -Eq '"status" *: *"OK"' "$out" || { echo "making the admin failed: $(cat "$out")"; exit 1; }
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > domoticz-test-admin-password
