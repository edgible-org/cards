# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The admin prepare.sh made signs in, and a stranger cannot sign up on the open webhook hostname.
set -eu
B="https://$HOSTNAME_ACTIVEPIECES_HOOKS"; H='Content-Type: application/json'
curl -fsS -X POST "$B/api/v1/authentication/sign-in" -H "$H" \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$ACTIVEPIECES_ADMIN_PASSWORD\"}" | grep -q token
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/authentication/sign-up" -H "$H" \
  -d '{"email":"stranger@example.com","password":"Ap1!stranger-pass","firstName":"S","lastName":"S","trackEvents":false,"newsLetter":false}')
case "$code" in 4*) ;; *) echo "a stranger's sign-up answered $code"; exit 1 ;; esac
