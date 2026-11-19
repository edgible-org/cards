#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the wiki-go
# hostname behind the Edgible sign-in, signs in as admin / admin and changes the password in
# Wiki-Go; this does the same through Wiki-Go's API, with a random password only this run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$WIKI_GO_PORT"
H='Content-Type: application/json'
hdr=$(mktemp); trap 'rm -f "$hdr"' EXIT
code=$(curl -s -D "$hdr" -o /dev/null -w '%{http_code}' -X POST "$B/api/login" -H "$H" \
  -d '{"username":"admin","password":"admin"}')
[ "$code" = 200 ] || { echo "the default admin / admin answered $code"; exit 1; }
token=$(sed -n 's/^[Ss]et-[Cc]ookie: session_token=\([^;]*\).*/\1/p' "$hdr" | head -n 1)
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/password" -H "$H" \
  -H "Cookie: session_token=$token" \
  -d "{\"current_password\":\"admin\",\"new_password\":\"$password\"}")
[ "$code" = 200 ] || { echo "changing the password answered $code"; exit 1; }
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > wiki-go-test-admin-password
