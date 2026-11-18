#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and answers WordPress's install page; this answers it
# with wp-cli instead, with a random password that only this test run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, HOSTNAME_WORDPRESS set,
# and the test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
$COMPOSE --profile cli run --rm -T wordpress-cli \
  wp core install --url="https://$HOSTNAME_WORDPRESS" --title="My site" \
  --admin_user=admin --admin_password="$password" --admin_email=admin@example.com --skip-email
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > wordpress-test-admin-password
