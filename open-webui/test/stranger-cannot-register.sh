# A check for test-card, run after Verify with card.env and the card's made secrets exported.
# open-webui is on org, which stops strangers at Edgible's sign-in, but it has accounts of its
# own, so this goes through the port on this machine: the admin made at first start signs in, a
# wrong password is refused, and a stranger cannot make an account.
set -eu
B="http://127.0.0.1:$OPEN_WEBUI_PORT"; H='Content-Type: application/json'
signin() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auths/signin" -H "$H" \
    -d "{\"email\":\"$OPEN_WEBUI_ADMIN_EMAIL\",\"password\":\"$1\"}"
}
code=$(signin "wrong-$OPEN_WEBUI_ADMIN_PASSWORD")
case "$code" in 200) echo "a wrong password answered $code"; exit 1 ;; esac
code=$(signin "$OPEN_WEBUI_ADMIN_PASSWORD")
[ "$code" = 200 ] || { echo "the admin's sign-in answered $code"; exit 1; }
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/v1/auths/signup" -H "$H" \
  -d '{"name":"stranger","email":"stranger@example.com","password":"stranger-pass-123"}')
[ "$code" != 200 ] || { echo "a stranger could register"; exit 1; }
echo "admin signs in, a wrong password and a stranger's sign-up are refused"
