#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# home-assistant hostname behind the Edgible sign-in and makes the owner in Home Assistant's
# onboarding; this makes it through the same API instead, with a random password that only
# this test run knows. It runs with card.env exported and the test's work directory as the
# current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$HOME_ASSISTANT_PORT"
curl -fsS -o /dev/null -X POST "$B/api/onboarding/users" -H 'Content-Type: application/json' \
  -d "{\"client_id\":\"$B/\",\"name\":\"admin\",\"username\":\"admin\",\"password\":\"$password\",\"language\":\"en\"}"
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > home-assistant-test-admin-password
