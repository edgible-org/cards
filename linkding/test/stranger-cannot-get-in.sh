#!/bin/sh
# Nobody may sign up or read bookmarks without an account: the web pages are behind Edgible's
# sign-in, the API (left to linkding's own login) refuses a call with no token, and linkding
# itself has no sign-up page.
set -eu
B="https://$HOSTNAME_LINKDING"
code=$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "$B/login/")
case "$code" in 30[1237]*application-access*) ;; *) echo "the login page answered $code, not Edgible's sign-in"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/bookmarks/"); [ "$code" = 401 ] || { echo "the bookmarks API answered $code with no token"; exit 1; }
L="http://localhost:$LINKDING_PORT"
code=$(curl -s -o /dev/null -w '%{http_code}' "$L/signup"); [ "$code" = 404 ] || { echo "/signup answered $code on the machine"; exit 1; }
if curl -sL "$L/login/" | grep -qi 'sign up'; then echo "the login page offers sign-up"; exit 1; fi
