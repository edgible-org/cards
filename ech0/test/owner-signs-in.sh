# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# ech0 is on none, so this goes through the public hostname: the owner test/setup.sh made signs
# in, a wrong password does not, and sign-up is closed, so no stranger can make an account.
set -eu
B="https://$HOSTNAME_ECH0/api"
H='Content-Type: application/json'
password=$(cat ech0-test-owner-password)
code=$(curl -sS -o /dev/null -w '%{http_code}' -X POST "$B/login" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"wrong-$password\"}")
case "$code" in 2*) echo "a wrong password answered $code"; exit 1 ;; esac
curl -fsS -X POST "$B/login" -H "$H" \
  -d "{\"username\":\"admin\",\"password\":\"$password\"}" | jq -e '.data.access_token | length > 0' >/dev/null
curl -fsS "$B/settings" | jq -e '.data.allow_register == false' >/dev/null
