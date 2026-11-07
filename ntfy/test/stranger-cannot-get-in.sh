#!/bin/sh
# ntfy is public: a stranger may not make an account, publish or read, and the admin may.
set -eu
B="https://$HOSTNAME_NTFY"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
  -d '{"username":"stranger","password":"stranger-password-1"}' "$B/v1/account")
case "$code" in 400|401|403|404|405) ;; *) echo "sign-up answered $code"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' -d 'hello' "$B/stranger-topic")
case "$code" in 401|403) ;; *) echo "an anonymous publish answered $code"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/stranger-topic/json?poll=1")
case "$code" in 401|403) ;; *) echo "an anonymous read answered $code"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' -u "stranger:stranger-password-1" "$B/v1/account")
[ "$code" = 401 ] || { echo "a made-up login answered $code"; exit 1; }
# The admin, with the password the card made, can publish.
code=$(curl -s -o /dev/null -w '%{http_code}' -u "$NTFY_ADMIN_USER:$NTFY_ADMIN_PASSWORD" -d 'card test' "$B/card-test")
[ "$code" = 200 ] || { echo "the admin's publish answered $code"; exit 1; }
