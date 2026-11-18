#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and makes the admin on Immich's first page; this makes
# it through the same API instead, with a random password that only this test run knows.
# It runs with card.env exported and the test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
curl -fsS -X POST "http://127.0.0.1:$IMMICH_PORT/api/auth/admin-sign-up" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$password\",\"name\":\"Admin\"}" >/dev/null
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > immich-test-admin-password
