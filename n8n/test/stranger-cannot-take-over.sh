#!/bin/sh
# n8n-hooks is public and serves the whole app, so this goes through it: the owner prepare.sh made
# can sign in, and a stranger cannot make themselves the owner.
set -eu
B="https://$HOSTNAME_N8N_HOOKS"; H='Content-Type: application/json'
curl -fsS "$B/healthz" | grep -q ok
code=$(printf '{"emailOrLdapLoginId":"%s","password":"%s"}' "$N8N_OWNER_EMAIL" "$N8N_OWNER_PASSWORD" \
       | curl -s -o /dev/null -w '%{http_code}' -X POST -H "$H" -d @- "$B/rest/login")
[ "$code" = 200 ] || { echo "the owner could not sign in ($code), so this check proves nothing"; exit 1; }
curl -fsS "$B/rest/settings" | grep -q '"showSetupOnFirstLoad":false' || { echo "n8n still offers owner setup"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$H" \
       -d '{"email":"stranger@example.com","firstName":"S","lastName":"T","password":"Str4nger-pass-123"}' "$B/rest/owner/setup")
[ "$code" = 400 ] || [ "$code" = 401 ] || [ "$code" = 403 ] || { echo "a stranger's owner setup answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "$H" \
       -d '{"emailOrLdapLoginId":"stranger@example.com","password":"Str4nger-pass-123"}' "$B/rest/login")
[ "$code" != 200 ] || { echo "a stranger signed in"; exit 1; }
