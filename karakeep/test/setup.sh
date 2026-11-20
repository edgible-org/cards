#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the karakeep
# hostname behind the Edgible sign-in while sign-up is open and makes the first account, which
# Karakeep makes the admin; this does the same through Karakeep's API, with a random password
# only this run knows. It runs with card.env exported, $COMPOSE set to the test's project, and the
# test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
O="https://$HOSTNAME_KARAKEEP"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$KARAKEEP_PORT/api/auth/sign-up/email" \
  -H 'Content-Type: application/json' -H "Origin: $O" \
  -d "{\"name\":\"admin\",\"email\":\"admin@example.com\",\"password\":\"$password\"}")
[ "$code" = 200 ] || { echo "making the first account answered $code"; exit 1; }
# For the stranger-and-admin check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > karakeep-test-admin-password
