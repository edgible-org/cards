#!/bin/sh
# domoticz-app is public: nothing may answer without a sign-in.
set -eu
B="https://$HOSTNAME_DOMOTICZ_APP"
for p in getdevices getsettings; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$B/json.htm?type=command&param=$p"); [ "$code" = 401 ] || { echo "$p answered $code with no sign-in"; exit 1; }
done
