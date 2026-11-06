#!/bin/sh
# Prepare for the onedev card: close self-registration and anonymous access before anything is public.
# OneDev's defaults let anyone on a public hostname make an account. The admin is made at first start
# (initial_user in the Compose file). Run this after Start and before Publish, from the directory
# that holds onedev/:
#   sh onedev/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# The card made this password on this machine at Start (onedev-secrets).
ONEDEV_ADMIN_PASSWORD=$($COMPOSE run --rm --no-deps onedev-secrets show ONEDEV_ADMIN_PASSWORD)

# Through OneDev's own API, from inside its container. Each step says why when it fails.
$COMPOSE exec -T -e AUTH="admin:$ONEDEV_ADMIN_PASSWORD" onedev bash -c '
set -eu
U=http://127.0.0.1:6610/~api/settings/security
# The container is healthy before OneDev has finished making the admin, so wait for the login to work.
cur=
for _ in $(seq 36); do
  cur=$(curl -fsS -u "$AUTH" "$U" 2>/dev/null) && break
  sleep 5
done
[ -n "$cur" ] || { echo "the admin could not sign in after three minutes" >&2; exit 1; }
new=$(printf "%s" "$cur" | sed -E "s/(\"enableSelfRegister\" *: *)true/\1false/; s/(\"enableAnonymousAccess\" *: *)true/\1false/")
printf "%s" "$new" | curl -fsS -u "$AUTH" -X POST -H "Content-Type: application/json" -d @- "$U" >/dev/null \
  || { echo "could not save the security settings" >&2; exit 1; }
now=$(curl -fsS -u "$AUTH" "$U") || { echo "could not read the settings after saving them" >&2; exit 1; }
printf "%s" "$now" | grep -Eq "\"enableSelfRegister\" *: *false" || { echo "self-registration is still on" >&2; exit 1; }
printf "%s" "$now" | grep -Eq "\"enableAnonymousAccess\" *: *false" || { echo "anonymous access is still on" >&2; exit 1; }
'
echo "self-registration and anonymous access are off; sign in as admin"
