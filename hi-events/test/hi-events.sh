#!/bin/sh
# The organizer test/setup.sh made can sign in, and sign-up is closed again after setup.
set -eu
password=$(cat hi-events-test-admin-password)
base="https://$HOSTNAME_HI_EVENTS"
login=$(curl -fsS -X POST "$base/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$password\"}")
echo "$login" | grep -q token
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$base/api/auth/register" \
  -H 'Content-Type: application/json' \
  -d '{"first_name":"X","email":"x@example.com","password":"password12345","password_confirmation":"password12345"}')
[ "$code" -ge 400 ]
