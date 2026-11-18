#!/bin/sh
# bloglite is public: it has one owner, and no way for anyone else to sign up.
set -eu
B="https://$HOSTNAME_BLOGLITE"
for p in /signup /admin; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$B$p"); [ "$code" = 404 ] || { echo "$p answered $code"; exit 1; }
done
