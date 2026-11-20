# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# Sign-up is closed again after setup, and the admin test/setup.sh made signs in.
set -eu
password=$(cat karakeep-test-admin-password)
B="https://$HOSTNAME_KARAKEEP"; H='Content-Type: application/json'
post() { curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/auth/$1" -H "$H" -H "Origin: $B" -d "$2"; }
stranger='{"name":"stranger","email":"stranger@example.com","password":"stranger-password"}'
code=$(post sign-up/email "$stranger")
case "$code" in 2*) echo "a stranger's sign-up answered $code"; exit 1 ;; esac
# Even if the request was refused oddly, the stranger must not be able to sign in.
code=$(post sign-in/email '{"email":"stranger@example.com","password":"stranger-password"}')
case "$code" in 2*) echo "the stranger signed in ($code)"; exit 1 ;; esac
code=$(post sign-in/email "{\"email\":\"admin@example.com\",\"password\":\"wrong-$password\"}")
case "$code" in 2*) echo "a wrong password signed in ($code)"; exit 1 ;; esac
code=$(post sign-in/email "{\"email\":\"admin@example.com\",\"password\":\"$password\"}")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
