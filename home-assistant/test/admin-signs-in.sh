# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# Home Assistant's sign-in page is behind Edgible's, so this signs in on the machine: a wrong
# password is refused and the admin test/setup.sh made signs in. Its API, left to its own login
# for the companion apps, refuses a caller with no token through the hostname.
set -eu
B="http://127.0.0.1:$HOME_ASSISTANT_PORT"
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
[ "$(curl -s -o /dev/null -w '%{http_code}' "https://$HOSTNAME_HOME_ASSISTANT/api/")" = 401 ] || { echo "the API answered without a sign-in"; exit 1; }
exit 0
