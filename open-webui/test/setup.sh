#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and makes the admin on Open WebUI's first page; this
# signs up through the same endpoint instead, with a random password that only this test run
# knows. Sign-up is closed, but Open WebUI lets its first account through as the admin.
# It runs with card.env exported and the test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$OPEN_WEBUI_PORT/api/v1/auths/signup" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"Admin\",\"email\":\"admin@example.com\",\"password\":\"$password\"}")
[ "$code" = 200 ] || { echo "the first sign-up answered $code"; exit 1; }
# For the stranger-cannot-register check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > open-webui-test-admin-password
