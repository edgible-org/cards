#!/bin/sh
# Prepare for the minecraft card: switch Geyser to Floodgate sign-in, so Bedrock players sign in with Xbox,
# and to the RakNet transport. Geyser 2.12 defaults to NetherNet, which does not answer the RakNet ping on
# UDP that Bedrock clients send.
# Run it after Start and before Publish, from the directory that holds minecraft/:
#   sh minecraft/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

$COMPOSE exec -T minecraft \
  sed -i -e 's/auth-type: online/auth-type: floodgate/' -e 's/^\( *transport:\).*/\1 raknet/' /data/plugins/Geyser-Spigot/config.yml
$COMPOSE restart minecraft
$COMPOSE up -d --wait
