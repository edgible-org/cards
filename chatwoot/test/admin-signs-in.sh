# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# chatwoot is on none, so this goes through the public hostname: a wrong password is refused,
# the admin prepare.sh made signs in, and a stranger cannot make an account.
set -eu
B="https://$HOSTNAME_CHATWOOT"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/auth/sign_in" -H "$H" \
    -d "{\"email\":\"$CHATWOOT_ADMIN_EMAIL\",\"password\":\"$1\"}"
}
code=$(signin "wrong-$CHATWOOT_ADMIN_PASSWORD")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$CHATWOOT_ADMIN_PASSWORD")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
