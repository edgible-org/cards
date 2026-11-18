# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# After the switch to none, the admin test/setup.sh made signs in over the public hostname.
set -eu
curl -fsS -X POST "https://$HOSTNAME_IMMICH/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$(cat immich-test-admin-password)\"}" | grep -q accessToken
