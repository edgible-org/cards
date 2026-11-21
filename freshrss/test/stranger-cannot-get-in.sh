#!/bin/sh
# Nobody may make an account: the register page is behind Edgible's sign-in, and FreshRSS
# itself refuses it, asked on the machine.
set -eu
code=$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "https://$HOSTNAME_FRESHRSS/i/?c=auth&a=register")
case "$code" in 30[1237]*application-access*) ;; *) echo "the register page answered $code, not Edgible's sign-in"; exit 1 ;; esac
B="http://127.0.0.1:$FRESHRSS_PORT"
curl -s -o /dev/null -w '%{http_code}' "$B/i/?c=auth&a=login" | grep -q '^200$' || { echo "the login page did not answer on the machine, so this check proves nothing"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -L "$B/i/?c=auth&a=register")
[ "$code" = 403 ] || { echo "the register page answered $code on the machine"; exit 1; }
