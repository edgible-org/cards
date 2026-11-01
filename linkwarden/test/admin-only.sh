# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# Sign-up is closed to strangers, and the admin prepare.sh made signs in.
set -eu
B="https://$HOSTNAME_LINKWARDEN"; H='Content-Type: application/json'
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/users" -H "$H" \
  -d '{"name":"stranger","username":"stranger","password":"stranger-password"}')
[ "$code" = 400 ] || { echo "sign-up answered $code"; exit 1; }
jar=$(mktemp); trap 'rm -f "$jar"' EXIT
# Linkwarden's session holds only the user's id, so a signed-in session has one and a refused sign-in has none.
login() {
  rm -f "$jar"
  csrf=$(curl -fsS -c "$jar" "$B/api/v1/auth/csrf" | sed -n 's/.*"csrfToken":"\([^"]*\)".*/\1/p')
  [ -n "$csrf" ] || { echo "no CSRF token"; exit 1; }
  curl -sS -b "$jar" -c "$jar" -o /dev/null -X POST "$B/api/v1/auth/callback/credentials" \
    --data-urlencode "csrfToken=$csrf" --data-urlencode "username=$LINKWARDEN_ADMIN_USER" \
    --data-urlencode "password=$1" --data-urlencode "json=true"
  curl -fsS -b "$jar" "$B/api/v1/auth/session"
}
bad=$(login "wrong-$LINKWARDEN_ADMIN_PASSWORD")
case "$bad" in *'"id"'*) echo "a wrong password signed in"; exit 1 ;; esac
good=$(login "$LINKWARDEN_ADMIN_PASSWORD")
case "$good" in *'"id"'*) ;; *) echo "the admin's sign-in gave no session: $good"; exit 1 ;; esac
