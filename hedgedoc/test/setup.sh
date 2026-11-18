#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and registers on HedgeDoc's sign-in page; this makes the
# account with HedgeDoc's own bin/manage_users instead, with a password only this run knows.
# bin/manage_users reads the database from the environment, so it runs through the same loader
# as the app. It runs with card.env exported and $COMPOSE set to the test's project.
set -eu
password=$(openssl rand -hex 16)
$COMPOSE exec -T -e HEDGEDOC_TEST_PASSWORD="$password" hedgedoc sh /run/card-secrets/.load sh -c '
  export CMD_DB_URL="postgres://hedgedoc:$HEDGEDOC_DB_PASSWORD@hedgedoc-db:5432/hedgedoc"
  exec node bin/manage_users --add admin@example.com --pass "$HEDGEDOC_TEST_PASSWORD"
'
