# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# memos is on none, so this goes through the public hostname: a wrong password is refused,
# the admin prepare.sh made signs in, and a stranger cannot register an account.
set -eu
B="https://$HOSTNAME_MEMOS"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auth/signin" -H "$H" \
    -d "{\"passwordCredentials\":{\"username\":\"$MEMOS_ADMIN_USER\",\"password\":\"$1\"}}"
}
code=$(signin "wrong-$MEMOS_ADMIN_PASSWORD")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$MEMOS_ADMIN_PASSWORD")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
  -d '{"username":"stranger","password":"stranger-pass-123","role":"USER"}')
[ "$code" != 200 ] || { echo "a stranger could register"; exit 1; }
