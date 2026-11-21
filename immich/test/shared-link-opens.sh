# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# A shared link opens for someone outside the organisation: the admin test/setup.sh made shares
# an album, and its /share/ page and the web app's files it loads answer with no Edgible sign-in.
set -eu
B="https://$HOSTNAME_IMMICH"; H='Content-Type: application/json'
field() { python3 -c 'import json, sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"; }
token=$(curl -fsS -X POST "$B/api/auth/login" -H "$H" \
  -d "{\"email\":\"admin@example.com\",\"password\":\"$(cat immich-test-admin-password)\"}" | field accessToken)
[ -n "$token" ] || { echo "the admin got no token"; exit 1; }
album=$(curl -fsS -X POST "$B/api/albums" -H "$H" -H "Authorization: Bearer $token" -d '{"albumName":"card-kit share"}' | field id)
[ -n "$album" ] || { echo "no album made"; exit 1; }
key=$(curl -fsS -X POST "$B/api/shared-links" -H "$H" -H "Authorization: Bearer $token" \
  -d "{\"type\":\"ALBUM\",\"albumId\":\"$album\"}" | field key)
[ -n "$key" ] || { echo "no shared link made"; exit 1; }
page=$(mktemp); trap 'rm -f "$page"' EXIT
code=$(curl -sS -o "$page" -w '%{http_code} %{redirect_url}' "$B/share/$key")
case "$code" in 200*) ;; *) echo "the shared link answered $code"; exit 1 ;; esac
asset=$(grep -o '/_app/immutable/[^"]*\.js' "$page" | head -1)
[ -n "$asset" ] || { echo "the shared page names no web app file"; exit 1; }
code=$(curl -sS -o /dev/null -w '%{http_code}' "$B$asset")
[ "$code" = 200 ] || { echo "$asset answered $code"; exit 1; }
curl -fsS "$B/api/shared-links/me?key=$key" | grep -q '"album"' || { echo "the shared link's album did not load with its key"; exit 1; }
