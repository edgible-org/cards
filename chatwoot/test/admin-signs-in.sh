# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# chatwoot is on none, so this goes through the public hostname: a wrong password is refused,
# the admin made on Chatwoot's install page (test/setup.sh) signs in.
set -eu
password=$(cat chatwoot-test-admin-password)
B="https://$HOSTNAME_CHATWOOT"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/auth/sign_in" -H "$H" \
    -d "{\"email\":\"admin@example.com\",\"password\":\"$1\"}"
}
code=$(signin "wrong-$password")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$password")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
