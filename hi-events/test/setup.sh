#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the hi-events
# hostname behind the Edgible sign-in while sign-up is open and makes the organizer's account;
# this does the same through Hi.Events' API, with a random password only this run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$HI_EVENTS_PORT/api/auth/register" \
  -H 'Content-Type: application/json' -H 'Accept: application/json' \
  -d "{\"first_name\":\"Organizer\",\"email\":\"admin@example.com\",\"password\":\"$password\",\"password_confirmation\":\"$password\",\"timezone\":\"UTC\"}")
case "$code" in 2*) ;; *) echo "making the organizer answered $code"; exit 1 ;; esac
# For the hi-events check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > hi-events-test-admin-password
