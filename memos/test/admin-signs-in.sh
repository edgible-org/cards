# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# memos is on none, so this goes through the public hostname: a wrong password is refused,
# the admin test/setup.sh made signs in, and a stranger cannot register an account.
set -eu
B="https://$HOSTNAME_MEMOS"; H='Content-Type: application/json'
password=$(cat memos-test-admin-password)
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auth/signin" -H "$H" \
    -d "{\"passwordCredentials\":{\"username\":\"admin\",\"password\":\"$1\"}}"
}
code=$(signin "wrong-$password")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$password")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
  -d '{"username":"stranger","password":"stranger-pass-123","role":"USER"}')
[ "$code" != 200 ] || { echo "a stranger could register"; exit 1; }
