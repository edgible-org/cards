#!/bin/sh
# immich is public: the first admin is made, so nobody else can become it.
set -eu
B="https://$HOSTNAME_IMMICH"
curl -fsS "$B/api/server/config" | grep -q '"isInitialized":true' || { echo "immich is not set up"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{"email":"s@example.com","name":"S","password":"Str4nger-pass-123"}' "$B/api/auth/admin-sign-up")
[ "$code" = 400 ] || { echo "making an admin answered $code"; exit 1; }
