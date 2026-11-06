#!/bin/sh
# home-assistant-app is public: onboarding must be finished, so nobody can make the owner.
set -eu
B="https://$HOSTNAME_HOME_ASSISTANT_APP"
curl -fsS "$B/api/onboarding" | tr -d ' ' | grep -q '"step":"user","done":true' || { echo "the user step of onboarding is not done"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{"client_id":"x","name":"S","username":"stranger","password":"Str4nger-pass-123","language":"en"}' "$B/api/onboarding/users")
[ "$code" = 403 ] || { echo "making an owner answered $code"; exit 1; }
