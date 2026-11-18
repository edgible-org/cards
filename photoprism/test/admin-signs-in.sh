# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# photoprism is on none, so this goes through the public hostname: a wrong password is
# refused, the admin made at first start signs in, and the library needs a sign-in.
set -eu
B="https://$HOSTNAME_PHOTOPRISM"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/session" -H "$H" \
    -d "{\"username\":\"$PHOTOPRISM_ADMIN_USER\",\"password\":\"$1\"}"
}
code=$(signin "wrong-$PHOTOPRISM_ADMIN_PASSWORD")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$PHOTOPRISM_ADMIN_PASSWORD")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' "$B/api/v1/photos?count=1")
case "$code" in 401|403) ;; *) echo "the library answered $code without a sign-in"; exit 1 ;; esac
