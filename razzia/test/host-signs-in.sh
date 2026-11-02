# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# razzia is on none, so this goes through the public hostname: the page and the health
# endpoint answer, a wrong host password is refused, and the one the card made is accepted.
set -eu
B="https://$HOSTNAME_RAZZIA"; H='Content-Type: application/json'
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/health")
[ "$code" = 200 ] || { echo "the health endpoint answered $code"; exit 1; }
login() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/manager" -H "$H" \
    -d "{\"password\":\"$1\"}"
}
code=$(login "wrong-$RAZZIA_MANAGER_PASSWORD")
[ "$code" = 403 ] || { echo "a wrong host password answered $code"; exit 1; }
code=$(login "$RAZZIA_MANAGER_PASSWORD")
[ "$code" = 200 ] || { echo "the host's sign-in answered $code"; exit 1; }
