# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# paperless-ngx is on org, so this asks the app on the machine: the admin Paperless made at
# its first start gets a token, and a wrong password is refused.
set -eu
B="http://127.0.0.1:$PAPERLESS_NGX_PORT"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/token/" \
  -d "username=$PAPERLESS_NGX_ADMIN_USER" -d "password=wrong-$PAPERLESS_NGX_ADMIN_PASSWORD")
[ "$code" = 400 ] || { echo "a wrong password answered $code"; exit 1; }
curl -fsS -X POST "$B/api/token/" -d "username=$PAPERLESS_NGX_ADMIN_USER" \
  -d "password=$PAPERLESS_NGX_ADMIN_PASSWORD" | grep -q '"token"'
