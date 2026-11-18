# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The admin LibrePhotos made at start signs in over the public hostname, with the password
# librephotos-secrets made, and a wrong password does not.
set -eu
B="https://$HOSTNAME_LIBREPHOTOS"; H='Content-Type: application/json'
curl -fsS -X POST "$B/api/auth/token/obtain" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$LIBREPHOTOS_ADMIN_PASSWORD\"}" | grep -q access
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/token/obtain" -H "$H" \
  -d '{"username":"admin","password":"admin"}')
[ "$code" = 401 ] || { echo "the default password answered $code"; exit 1; }
