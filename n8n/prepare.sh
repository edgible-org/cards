#!/bin/sh
# Prepare for the n8n card: make the owner on this machine, so a stranger cannot be first to do it.
# n8n gives the owner account to whoever sets it up first, and n8n-hooks is public.
# Run it after Start and before Publish, from the directory that holds n8n/:
#   sh n8n/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
U="http://127.0.0.1:${N8N_PORT:?set N8N_PORT in card.env}"

settings=
for _ in $(seq 36); do
  settings=$(curl -fsS "$U/rest/settings" 2>/dev/null) && break
  sleep 5
done
[ -n "$settings" ] || { echo "n8n did not answer on $U after three minutes" >&2; exit 1; }

# An owner already made, such as when upgrading a running card, stays as it is.
if ! printf '%s' "$settings" | grep -q '"showSetupOnFirstLoad":true'; then
  echo "n8n already has an owner: nothing to do"
  exit 0
fi

: "${N8N_OWNER_EMAIL:?set N8N_OWNER_EMAIL in card.env}"
: "${N8N_OWNER_PASSWORD:?set N8N_OWNER_PASSWORD in card.env}"
body=$(printf '{"email":"%s","firstName":"Owner","lastName":"Admin","password":"%s"}' "$N8N_OWNER_EMAIL" "$N8N_OWNER_PASSWORD")
code=$(printf '%s' "$body" | curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d @- "$U/rest/owner/setup")
[ "$code" = 200 ] || { echo "n8n refused the owner with $code: the password needs 8 characters, a number and a capital" >&2; exit 1; }
echo "Owner $N8N_OWNER_EMAIL made, with the password N8N_OWNER_PASSWORD in card.env"
