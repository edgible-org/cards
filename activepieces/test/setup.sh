#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# activepieces hostname behind the Edgible sign-in and signs up as the first account, which
# makes the admin; this signs up through the same endpoint instead, with a random password
# that only this test run knows. It runs with card.env exported and the test's work directory
# as the current directory.
set -eu
password="Ap1!$(openssl rand -hex 12)"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$ACTIVEPIECES_PORT/api/v1/authentication/sign-up" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$password\",\"firstName\":\"Admin\",\"lastName\":\"Admin\",\"trackEvents\":false,\"newsLetter\":false}")
[ "$code" = 200 ] || { echo "the first sign-up answered $code"; exit 1; }
# For the admin-only check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > activepieces-test-admin-password
