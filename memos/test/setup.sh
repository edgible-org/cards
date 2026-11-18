#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in, makes the admin on Memos's first page, and closes
# sign-up in its settings; this does both through Memos's API instead, with a random password
# that only this test run knows. It runs with card.env exported and the test's work directory
# as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$MEMOS_PORT"; H='Content-Type: application/json'
out=$(mktemp); trap 'rm -f "$out"' EXIT
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$password\",\"role\":\"ADMIN\"}")
[ "$code" = 200 ] || { echo "making the admin answered $code"; exit 1; }
code=$(curl -s -o "$out" -w '%{http_code}' -X POST "$B/api/v1/auth/signin" -H "$H" \
  -d "{\"passwordCredentials\":{\"username\":\"admin\",\"password\":\"$password\"}}")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
token=$(sed -n 's/.*"accessToken" *: *"\([^"]*\)".*/\1/p' "$out" | head -n 1)
code=$(curl -s -o /dev/null -w '%{http_code}' -X PATCH \
  "$B/api/v1/instance/settings/GENERAL?updateMask=general_setting.disallow_user_registration" \
  -H "$H" -H "Authorization: Bearer $token" \
  -d '{"name":"instance/settings/GENERAL","generalSetting":{"disallowUserRegistration":true}}')
[ "$code" = 200 ] || { echo "closing sign-up answered $code"; exit 1; }
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > memos-test-admin-password
