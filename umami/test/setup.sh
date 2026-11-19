#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the umami
# hostname behind the Edgible sign-in, signs in as admin / umami and changes the password under
# Settings; this does the same through Umami's API, with a random password only this run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$UMAMI_PORT"
H='Content-Type: application/json'
token=$(curl -fsS -X POST "$B/api/auth/login" -H "$H" -d '{"username":"admin","password":"umami"}' \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$token" ] || { echo "the default admin / umami did not sign in"; exit 1; }
curl -fsS -X POST "$B/api/me/password" -H "$H" -H "Authorization: Bearer $token" \
  -d "{\"currentPassword\":\"umami\",\"newPassword\":\"$password\"}" >/dev/null
# For the default-password-gone check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > umami-test-admin-password
