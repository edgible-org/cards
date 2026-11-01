# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# sync-in is on none, so this goes through the public hostname: a wrong password is refused and
# the admin Sync-in made at its first start signs in.
set -eu
B="https://$HOSTNAME_SYNC_IN"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/login" -H "$H" \
    -d "{\"login\":\"$SYNC_IN_ADMIN_USER\",\"password\":\"$1\"}"
}
code=$(signin "wrong-$SYNC_IN_ADMIN_PASSWORD")
case "$code" in 200|201) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$SYNC_IN_ADMIN_PASSWORD")
case "$code" in 200|201) ;; *) echo "the admin's sign-in answered $code"; exit 1 ;; esac
