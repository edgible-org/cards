#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the n8n
# hostname behind the Edgible sign-in and makes the owner on n8n's setup page; this makes it
# through the same endpoint instead, with a random password that only this test run knows.
# It runs with card.env exported and the test's work directory as the current directory.
set -eu
U="http://127.0.0.1:$N8N_PORT"
for _ in $(seq 36); do curl -fsS "$U/rest/settings" >/dev/null 2>&1 && break; sleep 5; done
# n8n wants 8 characters, a number and a capital.
password="Owner1$(openssl rand -hex 12)"
body=$(printf '{"email":"owner@example.com","firstName":"Owner","lastName":"Admin","password":"%s"}' "$password")
code=$(printf '%s' "$body" | curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d @- "$U/rest/owner/setup")
[ "$code" = 200 ] || { echo "n8n refused the owner with $code" >&2; exit 1; }
# For the stranger-cannot-take-over check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > n8n-test-owner-password
