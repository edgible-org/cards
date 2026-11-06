#!/bin/sh
# linkding is public: nobody may sign up or read bookmarks without an account.
set -eu
B="https://$HOSTNAME_LINKDING"
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/signup"); [ "$code" = 404 ] || { echo "/signup answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/bookmarks/"); [ "$code" = 401 ] || { echo "the bookmarks API answered $code with no sign-in"; exit 1; }
if curl -sL "$B/login/" | grep -qi 'sign up'; then echo "the login page offers sign-up"; exit 1; fi
