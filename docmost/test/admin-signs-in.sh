# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# docmost is on org, so this asks the app on the machine: the admin test/setup.sh made signs
# in, and a wrong password is refused.
set -eu
B="http://127.0.0.1:$DOCMOST_PORT"; H='Content-Type: application/json'
password=$(cat docmost-test-admin-password)
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/login" -H "$H" \
  -d "{\"email\":\"admin@example.org\",\"password\":\"wrong-$password\"}")
[ "$code" = 401 ] || [ "$code" = 400 ] || { echo "a wrong password answered $code"; exit 1; }
curl -fsS -D - -o /dev/null -X POST "$B/api/auth/login" -H "$H" \
  -d "{\"email\":\"admin@example.org\",\"password\":\"$password\"}" | grep -qi 'set-cookie'
