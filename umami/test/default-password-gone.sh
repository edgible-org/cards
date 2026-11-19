# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# After the setup, the default password is refused on the public analytics hostname, and the
# password test/setup.sh chose signs in.
set -eu
B="https://$HOSTNAME_ANALYTICS"; H='Content-Type: application/json'
password=$(cat umami-test-admin-password)
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/login" -H "$H" -d '{"username":"admin","password":"umami"}')
[ "$code" = 401 ] || { echo "the default password answered $code"; exit 1; }
curl -fsS -X POST "$B/api/auth/login" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$password\"}" | grep -q token
