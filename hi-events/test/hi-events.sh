#!/bin/sh
# The organizer made by prepare.sh can sign in, and sign-up is closed.
set -eu
base="https://$HOSTNAME_HI_EVENTS"
login=$(curl -fsS -X POST "$base/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$HI_EVENTS_ADMIN_EMAIL\",\"password\":\"$HI_EVENTS_ADMIN_PASSWORD\"}")
echo "$login" | grep -q token
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$base/api/auth/register" \
  -H 'Content-Type: application/json' \
  -d '{"first_name":"X","email":"x@example.com","password":"password12345","password_confirmation":"password12345"}')
[ "$code" -ge 400 ]
