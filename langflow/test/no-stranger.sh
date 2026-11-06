# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The admin signs in, and a stranger cannot make a working account on the open webhook hostname.
set -eu
B="https://$HOSTNAME_LANGFLOW_HOOKS"
login() { curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/login" \
  -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "username=$1" --data-urlencode "password=$2"; }
[ "$(login admin "$LANGFLOW_ADMIN_PASSWORD")" = 200 ] || { echo "the admin cannot sign in"; exit 1; }
curl -s -o /dev/null -X POST "$B/api/v1/users/" -H 'Content-Type: application/json' \
  -d '{"username":"stranger","password":"Str4nger-pass-1234"}' || true
code=$(login stranger 'Str4nger-pass-1234')
case "$code" in 2*) echo "a stranger signed in ($code)"; exit 1 ;; esac
