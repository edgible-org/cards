# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# home-assistant-app is on none, so this goes through the public hostname: a wrong password is
# refused, the admin test/setup.sh made signs in, and a caller with no sign-in cannot read the API.
set -eu
B="https://$HOSTNAME_HOME_ASSISTANT_APP"
password=$(cat home-assistant-test-admin-password)
login() {
  flow=$(curl -fsS -X POST "$B/auth/login_flow" -H 'Content-Type: application/json' \
    -d "{\"client_id\":\"$B/\",\"handler\":[\"homeassistant\",null],\"redirect_uri\":\"$B/\"}" \
    | sed -n 's/.*"flow_id": *"\([^"]*\)".*/\1/p')
  curl -s -X POST "$B/auth/login_flow/$flow" -H 'Content-Type: application/json' \
    -d "{\"client_id\":\"$B/\",\"username\":\"admin\",\"password\":\"$1\"}"
}
login "wrong-$password" | grep -q '"create_entry"' && { echo "a wrong password signed in"; exit 1; }
login "$password" | grep -q '"create_entry"' || { echo "the admin could not sign in"; exit 1; }
[ "$(curl -s -o /dev/null -w '%{http_code}' "$B/api/")" = 401 ] || { echo "the API answered without a sign-in"; exit 1; }
exit 0
