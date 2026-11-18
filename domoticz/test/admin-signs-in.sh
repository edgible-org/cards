# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# domoticz-app is on none, so this goes through the public hostname: a wrong password is refused,
# the admin prepare.sh made signs in, and a caller with no sign-in cannot read the users.
set -eu
B="https://$HOSTNAME_DOMOTICZ_APP/json.htm"
enc() { printf %s "$1" | sed 's/=/%3D/g; s/+/%2B/g; s,/,%2F,g'; }
md5() { if command -v md5sum >/dev/null 2>&1; then printf %s "$1" | md5sum | cut -d' ' -f1; else printf %s "$1" | md5 -q; fi; }
login() {
  u=$(enc "$(printf %s "$DOMOTICZ_ADMIN_USER" | base64 | tr -d '\n')")
  curl -s -X POST "$B?type=command&param=logincheck" -F "username=$u" -F "password=$(md5 "$1")" -F rememberme=false
}
login "wrong-$DOMOTICZ_ADMIN_PASSWORD" | grep -q '"status" *: *"OK"' && { echo "a wrong password signed in"; exit 1; }
login "$DOMOTICZ_ADMIN_PASSWORD" | grep -q '"status" *: *"OK"' || { echo "the admin could not sign in"; exit 1; }
curl -s "$B?type=command&param=getusers" | grep -q '"status" *: *"OK"' && { echo "users readable without a sign-in"; exit 1; }
exit 0
