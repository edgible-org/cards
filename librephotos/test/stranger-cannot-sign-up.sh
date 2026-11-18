# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# librephotos is on none, so a stranger can reach it: nobody can make an account, and the
# admin made at start is the only one.
set -eu
B="https://$HOSTNAME_LIBREPHOTOS"; H='Content-Type: application/json'
curl -fsS "$B/api/firsttimesetup" | tr -d ' ' | grep -q '"isFirstTimeSetup":false' \
  || { echo "librephotos has no admin yet"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/user/" -H "$H" \
  -d '{"username":"stranger","password":"Str4nger-pass-123","email":"s@example.com","first_name":"S","last_name":"S"}')
case "$code" in 401|403) ;; *) echo "making an account answered $code"; exit 1 ;; esac
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/token/obtain" -H "$H" \
  -d '{"username":"stranger","password":"Str4nger-pass-123"}')
[ "$code" = 401 ] || { echo "the stranger's account answered $code"; exit 1; }
