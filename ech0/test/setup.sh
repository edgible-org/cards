#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in, makes the owner on Ech0's first page, and turns off
# registration in its settings; this does both through Ech0's API instead, with a random
# password that only this test run knows. It runs with card.env exported and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$ECH0_PORT/api"; H='Content-Type: application/json'
n=0
until curl -fsS "$B/init/status" >/dev/null 2>&1; do
  n=$((n + 1)); [ "$n" -lt 60 ] || { echo "ech0 did not answer"; exit 1; }
  sleep 1
done
curl -fsS -X POST "$B/init/owner" -H "$H" \
  -d "{\"username\":\"admin\",\"email\":\"admin@example.com\",\"password\":\"$password\",\"locale\":\"en-US\"}" >/dev/null
token=$(curl -fsS -X POST "$B/login" -H "$H" -d "{\"username\":\"admin\",\"password\":\"$password\"}" \
  | python3 -c 'import json, sys; print(json.load(sys.stdin)["data"]["access_token"])')
settings=$(curl -fsS "$B/settings" | python3 -c '
import json, sys
data = json.load(sys.stdin)["data"]
data["allow_register"] = False
print(json.dumps(data, separators=(",", ":"), ensure_ascii=False))
')
curl -fsS -X PUT "$B/settings" -H "$H" -H "Authorization: Bearer $token" -d "$settings" >/dev/null
# For the owner-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > ech0-test-owner-password
