#!/bin/sh
# sync-in is public: the sign-in page must not offer sign-up, and the route must not exist.
set -eu
B="https://$HOSTNAME_SYNC_IN"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{"login":"stranger","password":"Str4nger-pass-123","email":"s@example.com"}' "$B/api/auth/register")
[ "$code" = 404 ] || { echo "registering answered $code"; exit 1; }
if curl -sL "$B/" | grep -qiE 'sign.?up|register'; then echo "the page offers sign-up"; exit 1; fi
