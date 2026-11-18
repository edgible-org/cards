#!/bin/sh
# photoprism is public: no photos without a sign-in, no sign-up, no default password.
set -eu
B="https://$HOSTNAME_PHOTOPRISM"; H='Content-Type: application/json'
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/v1/photos?count=1"); [ "$code" = 401 ] || { echo "photos answered $code with no sign-in"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$H" -d '{"username":"stranger","password":"Str4nger-pass-123"}' "$B/api/v1/users"); case "$code" in 2*) echo "making a user answered $code"; exit 1;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$H" -d '{"username":"admin","password":"insecure"}' "$B/api/v1/session"); [ "$code" = 401 ] || { echo "the default password answered $code"; exit 1; }
