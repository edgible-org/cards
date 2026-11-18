#!/bin/sh
# Gotify is public: a stranger may not make an account, publish or read, the default login
# does not work, and the admin, with the password the card made, may.
set -eu
B="https://$HOSTNAME_GOTIFY"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
  -d '{"name":"stranger","pass":"stranger-password-1"}' "$B/user")
case "$code" in 401|403) ;; *) echo "sign-up answered $code"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
  -d '{"message":"hello"}' "$B/message")
[ "$code" = 401 ] || { echo "an anonymous publish answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/message")
[ "$code" = 401 ] || { echo "an anonymous read answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -u "admin:admin" "$B/current/user")
[ "$code" = 401 ] || { echo "the default login answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -u "stranger:stranger-password-1" "$B/current/user")
[ "$code" = 401 ] || { echo "a made-up login answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -u "$GOTIFY_DEFAULTUSER_NAME:$GOTIFY_DEFAULTUSER_PASS" "$B/current/user")
[ "$code" = 200 ] || { echo "the admin's login answered $code"; exit 1; }
