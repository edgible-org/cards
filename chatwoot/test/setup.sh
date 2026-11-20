#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the chatwoot
# hostname behind the Edgible sign-in, and Chatwoot shows its install page, where they make the
# super admin and the account; this fills the same form, with a random password only this run
# knows. It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password="Cw-$(openssl rand -hex 12)1"
B="http://127.0.0.1:$CHATWOOT_PORT"
jar=$(mktemp); page=$(mktemp); trap 'rm -f "$jar" "$page"' EXIT
curl -fsS -c "$jar" -o "$page" "$B/installation/onboarding"
token=$(sed -n 's/.*name="authenticity_token" value="\([^"]*\)".*/\1/p' "$page" | head -n 1)
[ -n "$token" ] || { echo "no install page: Chatwoot did not offer its first-run setup"; exit 1; }
curl -sS -b "$jar" -c "$jar" -o /dev/null -X POST "$B/installation/onboarding" \
  --data-urlencode "authenticity_token=$token" --data-urlencode "user[name]=Admin" \
  --data-urlencode "user[company]=Support" --data-urlencode "user[email]=admin@example.com" \
  --data-urlencode "user[password]=$password"
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > chatwoot-test-admin-password
