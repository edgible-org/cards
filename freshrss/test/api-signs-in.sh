# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# freshrss is on org with /api/* left to FreshRSS's own login, so this signs in through the
# hostname the way a reader app does: the admin's name with the API password the card made
# gets a token, and a wrong password does not.
set -eu
B="https://$HOSTNAME_FRESHRSS/api/greader.php"
bad=$(curl -sS -o /dev/null -w '%{http_code}' --data-urlencode "Email=$FRESHRSS_ADMIN_USER" \
  --data-urlencode "Passwd=wrong-$FRESHRSS_API_PASSWORD" "$B/accounts/ClientLogin")
[ "$bad" = 401 ] || { echo "a wrong API password answered $bad"; exit 1; }
curl -fsS --data-urlencode "Email=$FRESHRSS_ADMIN_USER" --data-urlencode "Passwd=$FRESHRSS_API_PASSWORD" \
  "$B/accounts/ClientLogin" | grep -q '^Auth='
