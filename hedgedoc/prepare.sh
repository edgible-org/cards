#!/bin/sh
# Prepare for the hedgedoc card: make the first account before HedgeDoc is published.
# HedgeDoc has no admin role and no setup page; the accounts are whoever registers. Making the
# first one here, with the password the card made, means you are signed in before anyone else.
# Run it after Start and before Publish, from the directory that holds hedgedoc/:
#   sh hedgedoc/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# bin/manage_users reads the database from the environment, so it runs through the same loader
# as the app. It exits 2 when the account already exists, which is fine on a second run.
rc=0
$COMPOSE exec -T hedgedoc sh /run/card-secrets/.load sh -c '
  export CMD_DB_URL="postgres://hedgedoc:$HEDGEDOC_DB_PASSWORD@hedgedoc-db:5432/hedgedoc"
  exec node bin/manage_users --add "$1" --pass "$HEDGEDOC_ADMIN_PASSWORD"
' sh "$HEDGEDOC_ADMIN_EMAIL" || rc=$?
case "$rc" in 0|2) ;; *) echo "making the first account failed ($rc)"; exit 1 ;; esac
echo "the first account exists; sign in as $HEDGEDOC_ADMIN_EMAIL with HEDGEDOC_ADMIN_PASSWORD"
