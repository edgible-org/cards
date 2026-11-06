#!/bin/sh
# freshrss-app is public: nobody may make an account.
set -eu
B="https://$HOSTNAME_FRESHRSS_APP"
curl -s -o /dev/null -w '%{http_code}' -L "$B/i/?c=auth&a=login" | grep -q '^200$' || { echo "the login page did not answer, so this check proves nothing"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -L "$B/i/?c=auth&a=register")
[ "$code" = 403 ] || { echo "the register page answered $code"; exit 1; }
