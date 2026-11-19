# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# wiki-go is on org, so this asks the app on the machine: after the setup, a wrong password and
# the default password are refused, and the password test/setup.sh chose signs the admin in.
set -eu
B="http://127.0.0.1:$WIKI_GO_PORT"; H='Content-Type: application/json'
password=$(cat wiki-go-test-admin-password)
login() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/login" -H "$H" \
    -d "{\"username\":\"admin\",\"password\":\"$1\"}"
}
code=$(login "wrong-$password")
[ "$code" = 401 ] || { echo "a wrong password answered $code"; exit 1; }
code=$(login admin)
[ "$code" = 401 ] || { echo "the default password answered $code"; exit 1; }
code=$(login "$password")
[ "$code" = 200 ] || { echo "the password setup chose answered $code"; exit 1; }
