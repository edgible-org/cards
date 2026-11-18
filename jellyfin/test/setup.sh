#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and answers Jellyfin's setup wizard; this answers it
# through the wizard's own API instead, with a random password that only this test run knows.
# It runs with card.env exported and the test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$JELLYFIN_PORT"
H='Content-Type: application/json'
curl -fsS -X POST "$B/Startup/Configuration" -H "$H" \
  -d '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}'
curl -fsS "$B/Startup/User" >/dev/null
curl -fsS -X POST "$B/Startup/User" -H "$H" -d "{\"Name\":\"admin\",\"Password\":\"$password\"}"
curl -fsS -X POST "$B/Startup/RemoteAccess" -H "$H" \
  -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "$B/Startup/Complete"
# For the wizard-locked check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > jellyfin-test-admin-password
