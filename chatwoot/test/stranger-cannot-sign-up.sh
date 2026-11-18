# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# chatwoot is on none, so anyone can reach it: a stranger must not be able to make an account,
# neither through the sign-up API nor as an agent of the admin's account.
set -eu
B="https://$HOSTNAME_CHATWOOT"; H='Content-Type: application/json'
out=$(mktemp); trap 'rm -f "$out"' EXIT
code=$(curl -s -o "$out" -w '%{http_code}' -X POST "$B/api/v1/accounts" -H "$H" \
  -d '{"account_name":"Stranger","user_full_name":"Stranger","email":"stranger@example.com","password":"Stranger-pass-1!"}')
[ "$code" != 200 ] || { echo "a stranger could make an account"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/auth/sign_in" -H "$H" \
  -d '{"email":"stranger@example.com","password":"Stranger-pass-1!"}')
[ "$code" != 200 ] || { echo "the stranger's account signs in"; exit 1; }
