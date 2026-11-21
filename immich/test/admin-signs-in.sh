# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# /api/* is left to Immich's own login, so the admin test/setup.sh made signs in over the hostname, as the phone apps do.
set -eu
curl -fsS -X POST "https://$HOSTNAME_IMMICH/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$(cat immich-test-admin-password)\"}" | grep -q accessToken
